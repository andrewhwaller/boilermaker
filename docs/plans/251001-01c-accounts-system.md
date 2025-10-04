# Flexible Accounts System - Final Specification

**Date:** 2025-10-01
**Status:** Production Ready
**Iteration:** 3 (Final - incorporating DHH approval notes)

---

## What

Move from one account per user to many accounts per user via memberships, with session-based account tracking.

## Why

Users need to belong to multiple teams/accounts and switch between them.

## How

1. Add `sessions.account_id` to track current account in session
2. Remove `users.account_id` (users no longer belong to one account)
3. Set `Current.account` in ApplicationController
4. Replace all `Current.user.account` → `Current.account` references
5. Add account switcher when user has multiple accounts
6. Always ask for account name in registration

## Database

### Migration 1: Add account_id to sessions

```ruby
class AddAccountIdToSessions < ActiveRecord::Migration[8.0]
  def change
    add_reference :sessions, :account, foreign_key: true
  end
end
```

### Migration 2: Remove account_id from users

```ruby
class RemoveAccountIdFromUsers < ActiveRecord::Migration[8.0]
  def up
    remove_foreign_key :users, :accounts if foreign_key_exists?(:users, :accounts)
    remove_index :users, :account_id if index_exists?(:users, :account_id)
    remove_column :users, :account_id
  end

  def down
    add_reference :users, :account, foreign_key: true
  end
end
```

---

## New Features

### 1. Current.account Attribute

**File:** `app/models/current.rb`

```ruby
class Current < ActiveSupport::CurrentAttributes
  attribute :session, :account
  attribute :user_agent, :ip_address, :theme_name

  delegate :user, to: :session, allow_nil: true
end
```

### 2. Set Current Account in ApplicationController

**File:** `app/controllers/application_controller.rb`

Add before_action and method:

```ruby
before_action :set_current_account

def set_current_account
  return unless Current.session
  Current.account = Current.session.account || Current.user.accounts.first!
end
```

### 3. Account Switching Controller

**File:** `app/controllers/account_switches_controller.rb` (NEW)

```ruby
class AccountSwitchesController < ApplicationController
  def create
    account = Current.user.accounts.find(params[:account_id])
    Current.session.update!(account: account)
    redirect_back fallback_location: root_path, notice: "Switched to #{account.name}"
  end
end
```

### 4. Account Switcher Component

**File:** `app/components/account_switcher.rb` (NEW)

```ruby
class Components::AccountSwitcher < Components::Base
  include Phlex::Rails::Helpers::ButtonTo

  def initialize(current_account:, user:)
    @current_account = current_account
    @user = user
  end

  def view_template
    render Components::DropdownMenu.new(trigger_text: trigger_text) do
      @user.accounts.each do |account|
        if account == @current_account
          div(class: "px-4 py-2 bg-base-200 text-sm font-mono") do
            plain account.name
            span(class: "ml-2 text-xs text-base-content/60") { "CURRENT" }
          end
        else
          button_to switch_account_path(account_id: account.id),
            method: :post,
            class: "w-full text-left px-4 py-2 text-sm hover:bg-base-200" do
            plain account.name
          end
        end
      end
    end
  end

  private

  def trigger_text
    @current_account&.name || "Select account"
  end
end
```

### 5. Update Navigation Component

**File:** `app/components/navigation.rb`

Update authenticated_controls method:

```ruby
def authenticated_controls
  if Current.user.accounts.many?
    render Components::AccountSwitcher.new(
      current_account: Current.account,
      user: Current.user
    )
  else
    account_dropdown  # existing single-account dropdown
  end
end
```

### 6. Routes

**File:** `config/routes.rb`

Add:

```ruby
post "switch_account", to: "account_switches#create", as: :switch_account
```

---

## Changed Behavior

### Registration

**File:** `app/controllers/registrations_controller.rb`

Update create action:

```ruby
def create
  @user = User.new(user_params)

  ActiveRecord::Base.transaction do
    @user.save!

    # Create account with provided name
    account_name = params[:account_name].presence || "Personal"
    @account = Account.create!(name: account_name)

    # Create owner membership
    AccountMembership.create!(
      user: @user,
      account: @account,
      roles: { owner: true, admin: true, member: true }
    )

    # Create session with account
    session_record = @user.sessions.create!(account: @account)
    cookies.signed.permanent[:session_token] = { value: session_record.id, httponly: true }

    send_email_verification
  end

  redirect_to root_path, notice: "Welcome! You have signed up successfully"
rescue ActiveRecord::RecordInvalid => e
  @user.errors.add(:base, e.message) unless @user.errors.any?
  render Views::Registrations::New.new(user: @user), status: :unprocessable_entity
end
```

**File:** `app/views/registrations/new.rb`

Add account name field:

```ruby
form_with(url: sign_up_path, class: "space-y-4") do |form|
  FormGroup(
    label_text: "Account name",
    input_type: :text,
    name: "account_name",
    id: "account_name",
    placeholder: "Personal"
  )

  # ... rest of form fields ...
end
```

### Session Creation

**File:** `app/controllers/sessions_controller.rb`

Update create action to set account:

```ruby
def create
  if @user = User.authenticate_by(email: params[:email], password: params[:password])
    @session = @user.sessions.create!(account: @user.accounts.first!)
    cookies.signed.permanent[:session_token] = { value: @session.id, httponly: true }
    redirect_to root_path, notice: "Signed in successfully"
  else
    # ... error handling
  end
end
```

### Session Model

**File:** `app/models/session.rb`

```ruby
class Session < ApplicationRecord
  belongs_to :user
  belongs_to :account, optional: true
end
```

No callbacks needed - account set explicitly in controllers.

### Account Model

**File:** `app/models/account.rb`

Add session association:

```ruby
has_many :sessions, dependent: :nullify
```

### User Model

**File:** `app/models/user.rb`

No changes needed. Already has:
- `has_many :account_memberships`
- `has_many :accounts, through: :account_memberships`

### Authorization Updates

All files using `Current.user.account`:
- `app/controllers/account/dashboards_controller.rb`
- `app/controllers/account/invitations_controller.rb`
- `app/controllers/account/users_controller.rb`
- `app/controllers/account/settings_controller.rb`
- `app/views/account/dashboards/show.rb`
- `app/views/account/users/edit.rb`
- `app/views/account/users/show.rb`
- `app/views/account/invitations/index.rb`
- `app/components/account/user_table.rb`

Replace `Current.user.account` with `Current.account`.
Replace `Current.user.account.users` with `Current.account.members`.

---

## Testing

Write integration tests only:

### Test 1: Account created on signup

```ruby
test "registration creates account and membership" do
  post sign_up_path, params: {
    email: "user@example.com",
    password: "password123",
    password_confirmation: "password123",
    account_name: "My Team"
  }

  user = User.find_by(email: "user@example.com")
  account = user.accounts.first

  assert_equal "My Team", account.name
  assert user.account_memberships.first.owner?
  assert_equal account, Session.last.account
end
```

### Test 2: User can switch accounts

```ruby
test "user can switch between accounts" do
  user = users(:john)
  account1 = accounts(:acme)
  account2 = accounts(:widgets)

  AccountMembership.create!(user: user, account: account1, roles: {member: true})
  AccountMembership.create!(user: user, account: account2, roles: {member: true})

  sign_in_as(user)
  post switch_account_path(account_id: account2.id)

  assert_equal account2, Current.user.sessions.last.account
  assert_redirected_to root_path
end
```

### Test 3: User cannot access other accounts

```ruby
test "user cannot switch to account they don't belong to" do
  user = users(:john)
  other_account = accounts(:other)

  sign_in_as(user)

  assert_raises(ActiveRecord::RecordNotFound) do
    post switch_account_path(account_id: other_account.id)
  end
end
```

### Test 4: Current.account persists across requests

```ruby
test "current account persists in session" do
  user = users(:john)
  account = accounts(:acme)

  session = user.sessions.create!(account: account)
  cookies.signed[:session_token] = session.id

  get root_path
  assert_equal account, Current.account
end
```

### Test 5: Fails loudly when user has no accounts

```ruby
test "fails loudly when user has no accounts" do
  user = User.create!(email: "orphan@example.com", password: "password123")
  # Don't create any accounts or memberships

  session = user.sessions.create!
  cookies.signed[:session_token] = session.id

  assert_raises(ActiveRecord::RecordNotFound) do
    get root_path  # Should crash in set_current_account
  end
end
```

---

## Future/Deferred

Features to add later when actually needed:

1. **Create new account after signup** - Add `AccountsController#new/create` if users ask for it
2. **Account deletion** - Wait until someone needs to delete an account
3. **Account settings/editing** - Use existing `Account::SettingsController`
4. **URL-based account scoping** - Only if multi-tab account switching is requested
5. **Granular permissions** - Current owner/admin/member roles likely sufficient

---

## Implementation Phases

### Phase 1: Core Changes (Day 1)

1. Run migration: Add `sessions.account_id`
2. Run migration: Remove `users.account_id`
3. Update `Current` model (add account attribute)
4. Update `ApplicationController` (add `set_current_account`)
5. Update `Session` model (add account association)
6. Update `Account` model (add sessions association)
7. Replace all `Current.user.account` → `Current.account` in controllers/views
8. Update `RegistrationsController` to create account + membership
9. Update `SessionsController` to set account on session
10. Update registration view to include account name field
11. Run tests, fix failures

### Phase 2: Account Switching (Day 2)

1. Create `AccountSwitchesController`
2. Create `AccountSwitcher` component
3. Update `Navigation` component to use switcher
4. Add route for account switching
5. Write integration tests
6. Manual testing of switching flow

### Phase 3: Polish (Half Day)

1. Update `Account::BaseController` authorization
2. Test edge cases (user with no accounts should fail loudly)
3. Verify all existing features work with `Current.account`
4. Documentation updates

**Total Estimated Time: 2.5 days**

---

## Files Changed/Created

### New Files (4)
- `db/migrate/YYYYMMDDHHMMSS_add_account_id_to_sessions.rb` - Session account tracking
- `db/migrate/YYYYMMDDHHMMSS_remove_account_id_from_users.rb` - Remove direct user→account
- `app/controllers/account_switches_controller.rb` - Account switching (1 action)
- `app/components/account_switcher.rb` - Dropdown component (~40 lines)

### Modified Files (Core)
- `app/models/current.rb` - Add account attribute
- `app/models/session.rb` - Add account association
- `app/models/account.rb` - Add sessions association
- `app/controllers/application_controller.rb` - Add set_current_account
- `app/controllers/registrations_controller.rb` - Create account + membership
- `app/controllers/sessions_controller.rb` - Set account on session
- `app/views/registrations/new.rb` - Add account name field
- `app/components/navigation.rb` - Use account switcher
- `config/routes.rb` - Add switch_account route

### Modified Files (Refactoring)
All files using `Current.user.account`:
- `app/controllers/account/dashboards_controller.rb`
- `app/controllers/account/invitations_controller.rb`
- `app/controllers/account/users_controller.rb`
- `app/controllers/account/settings_controller.rb`
- `app/views/account/dashboards/show.rb`
- `app/views/account/users/edit.rb`
- `app/views/account/users/show.rb`
- `app/views/account/invitations/index.rb`
- `app/components/account/user_table.rb`

**Total Files:** ~20 files modified, 4 files created

---

## Key Differences from Iteration 1

### Removed (60-70% scope reduction)

1. ❌ `account_type` column and enum
2. ❌ Personal vs team account modes
3. ❌ Account conversion controllers/views
4. ❌ `AccountsController` (except future: new/create if needed)
5. ❌ All configuration options (`personal_accounts`, `allow_account_creation`, etc)
6. ❌ `Account.create_personal_for` factory method
7. ❌ `User#personal_account`, `team_accounts`, `default_account` helper methods
8. ❌ ApplicationHelper account methods
9. ❌ Separate account management views (index, show, edit)
10. ❌ Composite index on sessions (unnecessary)
11. ❌ Backfill migration (greenfield project)
12. ❌ Session `set_default_account` callback

### Simplified

1. ✅ Registration always asks for account name (no conditional logic)
2. ✅ `set_current_account` is one line with explicit failure
3. ✅ Session account set explicitly in controllers (no callbacks)
4. ✅ Testing focuses on integration tests, not implementation details
5. ✅ 2-3 implementation phases instead of 8
6. ✅ ~150 lines of new code instead of 400+
7. ✅ 4 new files instead of 15+

### Kept (Core Value)

1. ✅ Add `sessions.account_id` for session-based tracking
2. ✅ Remove `users.account_id` for many-to-many via memberships
3. ✅ `Current.account` attribute
4. ✅ `AccountSwitchesController` for switching
5. ✅ Account switcher component
6. ✅ Membership-based access model

---

## Changes from Iteration 2

### 1. Added 5th Integration Test
Added test for user-with-no-accounts edge case to verify fail-loudly principle.

### 2. Simplified Registration Form Help Text
Removed redundant help text from account name field. The placeholder "Personal" is sufficient guidance.

### 3. Confirmed Scope Decisions
- Keeping "Personal" default fallback in registration (sensible for users who skip the field)
- Deferring AccountsController#new/create until users request it
- Account switcher remains simple (no metadata bloat)

---

## Success Criteria

1. ✅ User can sign up and provide account name
2. ✅ Account and membership created on registration
3. ✅ Session stores current account
4. ✅ `Current.account` set on every request
5. ✅ User can switch between accounts (if they have multiple)
6. ✅ All `Current.user.account` references replaced with `Current.account`
7. ✅ Authorization uses `Current.account`
8. ✅ Existing features (invitations, users management) work unchanged
9. ✅ Integration tests pass (5 tests covering all critical paths)
10. ✅ Fails loudly when user has no accounts (indicates bug)

---

**Total Specification: ~450 lines (vs 1,905 in iteration 1)**

**Reduction: 76% smaller spec, 70% less implementation work**

**Status: APPROVED - Ready for implementation**
