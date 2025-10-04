# Flexible Accounts System - Iteration 4 (Starter Kit Complete)

## What

A many-to-many accounts system where users can belong to multiple accounts, with support for both personal accounts (one user) and team accounts (multiple users). Designed as a feature-complete starter kit that developers can configure for personal-only, team-only, or hybrid modes.

## Why

**Boilermaker is a starter kit, not a product.** This changes the design requirements:

- **No real users to learn from** - We can't ship minimal and iterate based on user feedback
- **Developers are the users** - They need configuration options at setup time
- **Feature completeness required** - Devs need both personal and team account capabilities available
- **Configuration over iteration** - Provide a boolean flag to enable/disable personal accounts, not "defer until users ask"

The iteration 2-3 approach (strip everything down) was correct for a product but wrong for a starter kit. Developers need:
1. Personal account auto-creation when configured
2. Team account creation UI
3. Account conversion capabilities (personal ↔ team)
4. Clear configuration to control registration behavior

## Configuration

Single boolean configuration in `config/application.rb`:

```ruby
config.personal_accounts = true  # Enable personal account auto-creation on signup
config.personal_accounts = false # Disable personal accounts, require team invite/creation
```

This controls:
- Whether new signups get a personal account automatically
- Registration flow (simple signup vs. create-team-during-signup)
- Available account conversion options

## Database Changes

### Migration 1: Add account_id to sessions

```ruby
class AddAccountIdToSessions < ActiveRecord::Migration[8.0]
  def change
    add_reference :sessions, :account, null: true, foreign_key: true, index: true
    add_index :sessions, [:user_id, :account_id]
  end
end
```

**Why:** Track which account each session is accessing. Supports account switching without re-authentication.

### Migration 2: Remove account_id from users

```ruby
class RemoveAccountIdFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_reference :users, :account, foreign_key: true, index: true
  end
end
```

**Why:** Users can belong to multiple accounts. Single account_id is incorrect model.

### Migration 3: Add personal boolean to accounts

```ruby
class AddPersonalToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :personal, :boolean, default: false, null: false
    add_index :accounts, :personal
  end
end
```

**Why:** Need to distinguish personal accounts (one owner) from team accounts (multiple members) for:
- Conversion validation (can't convert personal → team if other members exist)
- UI differences (personal accounts show different management options)
- Account listing (group by type in account switcher)

### Migration 4: Add owner_id to accounts

```ruby
class AddOwnerToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_reference :accounts, :owner, null: false, foreign_key: { to_table: :users }, index: true
  end
end
```

**Why:** Every account has exactly one owner. This replaces the "owner" role in AccountMembership:
- Simpler ownership checks (`account.owner == user` vs `membership.owner?`)
- Separate concerns: `owner_id` for ownership, membership roles for permissions
- Required field ensures every account has an owner
- Personal accounts: `owner_id` = the single user
- Team accounts: `owner_id` = team creator/owner

## Core Features

### 1. Session-Based Account Tracking

Each session tracks the active account via `sessions.account_id`. The `Current.account` is resolved from the current session.

```ruby
# app/models/current.rb
class Current < ActiveSupport::CurrentAttributes
  attribute :session, :user, :account

  def account
    super || session&.account || user&.personal_account
  end
end
```

**Fallback order:** session.account → user.personal_account (when enabled) → nil

### 2. Account Switching

Users can switch between their accounts without re-authentication. Switching updates `session.account_id`.

```ruby
# POST /account_switches
# params: { account_id: 123 }
```

**Validation:** User must be a member of the target account.

### 3. Personal Account Auto-Creation

When `config.personal_accounts = true`, new signups automatically get a personal account.

```ruby
# app/controllers/registrations_controller.rb
def create
  user = User.create!(user_params)

  if Rails.configuration.personal_accounts
    account = user.accounts.create!(
      name: "#{user.name}'s Account",
      personal: true,
      owner: user
    )
  end

  # ...
end
```

**Note:** When `personal_accounts = false`, users land on "Create Team" page after signup.

### 4. Team Account Creation

Users can create new team accounts at any time.

```ruby
# POST /accounts
# params: { account: { name: "Acme Corp" } }
```

**Behavior:**
- Creates account with `personal: false` and `owner: Current.user`
- Creates membership for creator with role: :admin
- Redirects to account settings

### 5. Account Conversion

Convert between personal and team accounts with validation.

```ruby
# POST /accounts/:id/convert_to_team
# POST /accounts/:id/convert_to_personal
```

**Validation:**
- Personal → Team: Must be owner, any membership count OK
- Team → Personal: Must be owner, must have exactly one member (self)

**UI:** Shown in account settings with clear warnings about implications.

### 6. Account Management

- **Account switcher** - Dropdown showing all user's accounts, grouped by personal/team
- **Account settings** - Name, conversion options, danger zone
- **Account list** - View all accounts user belongs to

## Models

### Current

```ruby
# app/models/current.rb
class Current < ActiveSupport::CurrentAttributes
  attribute :session, :user, :account

  def account
    super || session&.account || fallback_account
  end

  private

  def fallback_account
    return nil unless Rails.configuration.personal_accounts
    user&.personal_account
  end
end
```

### Account

```ruby
# app/models/account.rb
class Account < ApplicationRecord
  belongs_to :owner, class_name: "User"
  has_many :account_memberships, dependent: :destroy
  has_many :users, through: :account_memberships

  validates :name, presence: true
  validates :personal, inclusion: { in: [true, false] }
  validates :owner, presence: true

  # Personal account query
  scope :personal, -> { where(personal: true) }
  scope :team, -> { where(personal: false) }

  def personal?
    personal
  end

  def team?
    !personal
  end

  # Conversion methods
  def can_convert_to_team?(user)
    personal? && owner == user
  end

  def can_convert_to_personal?(user)
    team? && owner == user && account_memberships.count == 1
  end

  def convert_to_team!
    raise "Already a team account" if team?
    update!(personal: false)
  end

  def convert_to_personal!
    raise "Already a personal account" if personal?
    raise "Cannot convert: multiple members" if account_memberships.count > 1
    update!(personal: true)
  end
end
```

### User

```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_many :sessions, dependent: :destroy
  has_many :account_memberships, dependent: :destroy
  has_many :accounts, through: :account_memberships
  has_many :owned_accounts, class_name: "Account", foreign_key: :owner_id, dependent: :destroy

  # Personal account lookup (when feature enabled)
  def personal_account
    return nil unless Rails.configuration.personal_accounts
    owned_accounts.personal.first
  end

  # Check if user can access account
  def can_access?(account)
    accounts.include?(account)
  end
end
```

### Session

```ruby
# app/models/session.rb
class Session < ApplicationRecord
  belongs_to :user
  belongs_to :account, optional: true

  validates :user_agent, presence: true
  validates :ip_address, presence: true

  before_validation :set_default_account, on: :create

  private

  def set_default_account
    return if account_id.present?
    return unless Rails.configuration.personal_accounts

    self.account = user.personal_account
  end
end
```

### AccountMembership

```ruby
# app/models/account_membership.rb
class AccountMembership < ApplicationRecord
  belongs_to :account
  belongs_to :user

  # Note: "owner" role removed - use account.owner_id instead
  enum :role, { member: 0, admin: 1 }

  validates :user_id, uniqueness: { scope: :account_id }
  validates :role, presence: true
end
```

## Controllers

### AccountsController

```ruby
# app/controllers/accounts_controller.rb
class AccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_account, only: [:show, :edit, :update, :destroy]
  before_action :require_owner, only: [:edit, :update, :destroy]

  def index
    @personal_accounts = Current.user.accounts.personal.order(:name)
    @team_accounts = Current.user.accounts.team.order(:name)
  end

  def show
  end

  def new
    @account = Account.new
  end

  def create
    @account = Account.new(account_params)
    @account.personal = false
    @account.owner = Current.user

    if @account.save
      Current.user.account_memberships.create!(account: @account, role: :admin)
      redirect_to @account, notice: "Team created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @account.update(account_params)
      redirect_to @account, notice: "Account updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @account.destroy
    redirect_to accounts_path, notice: "Account deleted successfully."
  end

  private

  def set_account
    @account = Current.user.accounts.find(params[:id])
  end

  def require_owner
    unless @account.owner == Current.user
      redirect_to @account, alert: "Only account owners can perform this action."
    end
  end

  def account_params
    params.require(:account).permit(:name)
  end
end
```

### AccountSwitchesController

```ruby
# app/controllers/account_switches_controller.rb
class AccountSwitchesController < ApplicationController
  before_action :authenticate_user!

  def create
    account = Current.user.accounts.find(params[:account_id])
    Current.session.update!(account: account)

    redirect_to root_path, notice: "Switched to #{account.name}"
  end
end
```

### AccountConversionsController

```ruby
# app/controllers/account_conversions_controller.rb
class AccountConversionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_account
  before_action :require_owner

  def to_team
    if @account.can_convert_to_team?(Current.user)
      @account.convert_to_team!
      redirect_to @account, notice: "Converted to team account. You can now invite members."
    else
      redirect_to @account, alert: "Cannot convert this account to a team."
    end
  end

  def to_personal
    if @account.can_convert_to_personal?(Current.user)
      @account.convert_to_personal!
      redirect_to @account, notice: "Converted to personal account."
    else
      redirect_to @account, alert: "Cannot convert: remove other members first."
    end
  end

  private

  def set_account
    @account = Current.user.accounts.find(params[:account_id])
  end

  def require_owner
    unless @account.owner == Current.user
      redirect_to @account, alert: "Only account owners can convert accounts."
    end
  end
end
```

### RegistrationsController (Updated)

```ruby
# app/controllers/registrations_controller.rb
class RegistrationsController < ApplicationController
  def create
    user = User.new(user_params)

    if user.save
      account = create_personal_account_if_enabled(user)
      session = user.sessions.create!(
        user_agent: request.user_agent,
        ip_address: request.remote_ip,
        account: account
      )

      cookies.signed.permanent[:session_token] = { value: session.id, httponly: true }

      if Rails.configuration.personal_accounts
        redirect_to root_path, notice: "Welcome to #{Rails.application.class.module_parent_name}!"
      else
        redirect_to new_account_path, notice: "Welcome! Create your team to get started."
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def create_personal_account_if_enabled(user)
    return nil unless Rails.configuration.personal_accounts

    user.accounts.create!(
      name: "#{user.name}'s Account",
      personal: true,
      owner: user
    )
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :name)
  end
end
```

## Views/Components

### Account Switcher Component

```ruby
# app/components/account_switcher_component.rb
class AccountSwitcherComponent < ApplicationComponent
  def initialize(user:, current_account:)
    @user = user
    @current_account = current_account
  end

  def template
    div class: "account-switcher" do
      button(type: "button", class: "dropdown-toggle") do
        text @current_account&.name || "Select Account"
      end

      div class: "dropdown-menu" do
        if personal_accounts.any?
          div class: "dropdown-section" do
            h6 { "Personal" }
            personal_accounts.each do |account|
              render_account_link(account)
            end
          end
        end

        if team_accounts.any?
          div class: "dropdown-section" do
            h6 { "Teams" }
            team_accounts.each do |account|
              render_account_link(account)
            end
          end
        end

        div class: "dropdown-divider"

        a href: new_account_path, class: "dropdown-item" do
          text "Create Team"
        end

        a href: accounts_path, class: "dropdown-item" do
          text "Manage Accounts"
        end
      end
    end
  end

  private

  def personal_accounts
    @personal_accounts ||= @user.accounts.personal.order(:name)
  end

  def team_accounts
    @team_accounts ||= @user.accounts.team.order(:name)
  end

  def render_account_link(account)
    a(
      href: account_switches_path(account_id: account.id),
      data: { turbo_method: :post },
      class: ["dropdown-item", ("active" if account == @current_account)]
    ) do
      text account.name
    end
  end
end
```

### Account Settings View

```erb
<!-- app/views/accounts/edit.html.erb -->
<h1>Account Settings</h1>

<%= form_with model: @account do |f| %>
  <%= f.label :name %>
  <%= f.text_field :name %>

  <%= f.submit "Update Account" %>
<% end %>

<% if @account.personal? %>
  <section>
    <h2>Convert to Team</h2>
    <p>Convert this personal account to a team account to invite members.</p>

    <%= button_to "Convert to Team",
                  account_conversion_to_team_path(@account),
                  method: :post,
                  data: { confirm: "Convert #{@account.name} to a team account?" } %>
  </section>
<% else %>
  <% if @account.can_convert_to_personal?(Current.user) %>
    <section>
      <h2>Convert to Personal</h2>
      <p>Convert this team account to a personal account. This will prevent inviting new members.</p>

      <%= button_to "Convert to Personal",
                    account_conversion_to_personal_path(@account),
                    method: :post,
                    data: { confirm: "Convert #{@account.name} to a personal account?" } %>
    </section>
  <% else %>
    <section>
      <h2>Convert to Personal</h2>
      <p>Cannot convert: remove all other members first (must be only member).</p>
    </section>
  <% end %>
<% end %>

<section class="danger-zone">
  <h2>Danger Zone</h2>
  <%= button_to "Delete Account",
                @account,
                method: :delete,
                data: { confirm: "Are you sure? This cannot be undone." } %>
</section>
```

### Accounts Index View

```erb
<!-- app/views/accounts/index.html.erb -->
<h1>Your Accounts</h1>

<% if @personal_accounts.any? %>
  <section>
    <h2>Personal Accounts</h2>
    <ul>
      <% @personal_accounts.each do |account| %>
        <li>
          <%= link_to account.name, account %>
          <% if account.owner == Current.user %>
            <span class="badge">Owner</span>
          <% end %>
        </li>
      <% end %>
    </ul>
  </section>
<% end %>

<% if @team_accounts.any? %>
  <section>
    <h2>Team Accounts</h2>
    <ul>
      <% @team_accounts.each do |account| %>
        <li>
          <%= link_to account.name, account %>
          <% if account.owner == Current.user %>
            <span class="badge">Owner</span>
          <% else %>
            <% membership = Current.user.account_memberships.find_by(account: account) %>
            <span class="badge"><%= membership.role.titleize %></span>
          <% end %>
        </li>
      <% end %>
    </ul>
  </section>
<% end %>

<%= link_to "Create Team", new_account_path, class: "button" %>
```

## Routes

```ruby
# config/routes.rb
Rails.application.routes.draw do
  # Account switching
  resources :account_switches, only: [:create]

  # Account management
  resources :accounts do
    # Account conversion
    post "convert_to_team", to: "account_conversions#to_team", as: :conversion_to_team
    post "convert_to_personal", to: "account_conversions#to_personal", as: :conversion_to_personal
  end
end
```

## Implementation Phases

### Phase 1: Database & Core Models (Day 1)
- Run migrations (add sessions.account_id, remove users.account_id, add accounts.personal, add accounts.owner_id)
- Update Current model with account resolution
- Update Account model with owner association, personal/team scopes, and conversion methods
- Update AccountMembership model (remove "owner" role)
- Update User model with owned_accounts association and personal_account lookup
- Update Session model with default account setting

**Validation:** Rails console tests
```ruby
user = User.first
user.personal_account # Returns personal account when enabled
user.personal_account.owner == user # => true
account = Account.create!(name: "Test", personal: false, owner: user)
account.team? # => true
account.owner == user # => true
```

### Phase 2: Account Switching & Registration (Day 2)
- Implement AccountSwitchesController
- Update RegistrationsController with personal account creation
- Test account switching between personal/team accounts
- Test registration with personal_accounts = true/false

**Validation:**
- Sign up → get personal account (when enabled)
- Sign up → redirect to create team (when disabled)
- Switch between accounts without re-auth

### Phase 3: Account Management (Day 3)
- Implement AccountsController (CRUD)
- Create account switcher component
- Create account settings view
- Create accounts index view

**Validation:**
- Create team account
- View all accounts
- Update account name
- Delete account

### Phase 4: Account Conversion (Day 4)
- Implement AccountConversionsController
- Add conversion UI to account settings
- Test conversion validations
- Test conversion state changes

**Validation:**
- Convert personal → team (allowed when owner)
- Convert team → personal (allowed when owner + solo member)
- Prevent invalid conversions

## Testing

### Integration Tests

```ruby
# test/integration/account_switching_test.rb
class AccountSwitchingTest < ActionDispatch::IntegrationTest
  test "user can switch between personal and team accounts" do
    user = users(:john)
    personal = accounts(:john_personal)
    team = accounts(:acme)

    sign_in user

    # Default to personal account
    assert_equal personal, Current.account

    # Switch to team
    post account_switches_path(account_id: team.id)
    follow_redirect!
    assert_equal team, Current.account

    # Switch back to personal
    post account_switches_path(account_id: personal.id)
    follow_redirect!
    assert_equal personal, Current.account
  end

  test "user cannot switch to account they don't belong to" do
    user = users(:john)
    other_account = accounts(:competitors_team)

    sign_in user

    assert_raises(ActiveRecord::RecordNotFound) do
      post account_switches_path(account_id: other_account.id)
    end
  end
end

# test/integration/account_conversion_test.rb
class AccountConversionTest < ActionDispatch::IntegrationTest
  test "owner can convert personal account to team" do
    user = users(:john)
    account = accounts(:john_personal)

    sign_in user

    assert account.personal?

    post account_conversion_to_team_path(account)
    account.reload

    assert account.team?
  end

  test "owner can convert solo team account to personal" do
    user = users(:john)
    account = accounts(:solo_team)

    sign_in user

    assert account.team?
    assert_equal 1, account.account_memberships.count

    post account_conversion_to_personal_path(account)
    account.reload

    assert account.personal?
  end

  test "cannot convert team with multiple members to personal" do
    user = users(:john)
    account = accounts(:acme) # Has multiple members

    sign_in user

    assert account.team?
    assert_operator account.account_memberships.count, :>, 1

    post account_conversion_to_personal_path(account)
    follow_redirect!

    assert_match /cannot convert/i, flash[:alert]
    account.reload
    assert account.team?
  end
end

# test/integration/registration_with_personal_accounts_test.rb
class RegistrationWithPersonalAccountsTest < ActionDispatch::IntegrationTest
  test "new user gets personal account when feature enabled" do
    Rails.configuration.personal_accounts = true

    post registrations_path, params: {
      user: {
        email: "new@example.com",
        password: "password123",
        password_confirmation: "password123",
        name: "New User"
      }
    }

    user = User.find_by(email: "new@example.com")
    assert user.present?

    personal = user.personal_account
    assert personal.present?
    assert personal.personal?
    assert_equal "New User's Account", personal.name
  end

  test "new user does not get personal account when feature disabled" do
    Rails.configuration.personal_accounts = false

    post registrations_path, params: {
      user: {
        email: "new@example.com",
        password: "password123",
        password_confirmation: "password123",
        name: "New User"
      }
    }

    user = User.find_by(email: "new@example.com")
    assert user.present?
    assert_equal 0, user.accounts.count

    follow_redirect!
    assert_equal new_account_path, path
  end
end

# test/integration/account_management_test.rb
class AccountManagementTest < ActionDispatch::IntegrationTest
  test "user can create team account" do
    user = users(:john)
    sign_in user

    assert_difference "Account.count", 1 do
      post accounts_path, params: {
        account: { name: "New Team" }
      }
    end

    account = Account.find_by(name: "New Team")
    assert account.team?
    assert_equal user, account.owner
  end

  test "user can view all their accounts" do
    user = users(:john)
    sign_in user

    get accounts_path
    assert_response :success

    assert_select "h2", "Personal Accounts"
    assert_select "h2", "Team Accounts"
  end

  test "owner can update account name" do
    user = users(:john)
    account = accounts(:john_personal)
    sign_in user

    patch account_path(account), params: {
      account: { name: "Updated Name" }
    }

    account.reload
    assert_equal "Updated Name", account.name
  end

  test "non-owner cannot update account" do
    user = users(:jane)
    account = accounts(:john_personal)
    sign_in user

    patch account_path(account), params: {
      account: { name: "Hacked Name" }
    }

    follow_redirect!
    assert_match /only account owners/i, flash[:alert]
  end

  test "owner can delete account" do
    user = users(:john)
    account = accounts(:solo_team)
    sign_in user

    assert_difference "Account.count", -1 do
      delete account_path(account)
    end
  end
end
```

### Model Tests

```ruby
# test/models/account_test.rb
class AccountTest < ActiveSupport::TestCase
  test "personal scope returns personal accounts" do
    assert_includes Account.personal, accounts(:john_personal)
    assert_not_includes Account.personal, accounts(:acme)
  end

  test "team scope returns team accounts" do
    assert_includes Account.team, accounts(:acme)
    assert_not_includes Account.team, accounts(:john_personal)
  end

  test "can_convert_to_team? returns true for personal account owner" do
    account = accounts(:john_personal)
    user = users(:john)

    assert account.can_convert_to_team?(user)
  end

  test "can_convert_to_personal? returns true for solo team owner" do
    account = accounts(:solo_team)
    user = users(:john)

    assert_equal 1, account.account_memberships.count
    assert account.can_convert_to_personal?(user)
  end

  test "can_convert_to_personal? returns false for multi-member team" do
    account = accounts(:acme)
    user = users(:john)

    assert_operator account.account_memberships.count, :>, 1
    assert_not account.can_convert_to_personal?(user)
  end

  test "convert_to_team! changes personal to team" do
    account = accounts(:john_personal)

    assert account.personal?
    account.convert_to_team!
    assert account.team?
  end

  test "convert_to_personal! changes team to personal" do
    account = accounts(:solo_team)

    assert account.team?
    account.convert_to_personal!
    assert account.personal?
  end

  test "convert_to_personal! raises when multiple members" do
    account = accounts(:acme)

    assert_raises(RuntimeError, "Cannot convert: multiple members") do
      account.convert_to_personal!
    end
  end
end

# test/models/user_test.rb
class UserTest < ActiveSupport::TestCase
  test "personal_account returns personal account when feature enabled" do
    Rails.configuration.personal_accounts = true
    user = users(:john)

    personal = user.personal_account
    assert personal.present?
    assert personal.personal?
  end

  test "personal_account returns nil when feature disabled" do
    Rails.configuration.personal_accounts = false
    user = users(:john)

    assert_nil user.personal_account
  end

  test "can_access? returns true for user's account" do
    user = users(:john)
    account = accounts(:acme)

    assert user.can_access?(account)
  end

  test "can_access? returns false for other account" do
    user = users(:john)
    account = accounts(:competitors_team)

    assert_not user.can_access?(account)
  end
end

# test/models/session_test.rb
class SessionTest < ActiveSupport::TestCase
  test "sets default account to personal account on create when enabled" do
    Rails.configuration.personal_accounts = true
    user = users(:john)

    session = user.sessions.create!(
      user_agent: "Test",
      ip_address: "127.0.0.1"
    )

    assert_equal user.personal_account, session.account
  end

  test "does not set default account when feature disabled" do
    Rails.configuration.personal_accounts = false
    user = users(:john)

    session = user.sessions.create!(
      user_agent: "Test",
      ip_address: "127.0.0.1"
    )

    assert_nil session.account
  end
end
```

### Fixtures

```yaml
# test/fixtures/accounts.yml
john_personal:
  name: "John's Account"
  personal: true
  owner: john

jane_personal:
  name: "Jane's Account"
  personal: true
  owner: jane

acme:
  name: "Acme Corp"
  personal: false
  owner: john

solo_team:
  name: "Solo Team"
  personal: false
  owner: john

competitors_team:
  name: "Competitor Inc"
  personal: false
  owner: other_user

# test/fixtures/account_memberships.yml
# Note: "owner" role removed - ownership is via accounts.owner_id

john_personal_member:
  account: john_personal
  user: john
  role: admin

jane_personal_member:
  account: jane_personal
  user: jane
  role: admin

john_acme_admin:
  account: acme
  user: john
  role: admin

jane_acme_member:
  account: acme
  user: jane
  role: member

john_solo_admin:
  account: solo_team
  user: john
  role: admin
```

## Files Changed/Created

### New Files (8)
- `db/migrate/[timestamp]_add_account_id_to_sessions.rb`
- `db/migrate/[timestamp]_remove_account_id_from_users.rb`
- `db/migrate/[timestamp]_add_personal_to_accounts.rb`
- `db/migrate/[timestamp]_add_owner_to_accounts.rb`
- `app/controllers/account_switches_controller.rb`
- `app/controllers/account_conversions_controller.rb`
- `app/controllers/accounts_controller.rb`
- `app/components/account_switcher_component.rb`

### Modified Files (12)
- `app/models/current.rb` - Add account resolution with fallback
- `app/models/account.rb` - Add owner association, personal/team scopes, conversion methods
- `app/models/account_membership.rb` - Remove "owner" role from enum
- `app/models/user.rb` - Add owned_accounts association, personal_account lookup, can_access?
- `app/models/session.rb` - Add account association, default account callback
- `app/controllers/registrations_controller.rb` - Add personal account creation with owner
- `config/routes.rb` - Add account routes, conversion routes, switches
- `config/application.rb` - Add personal_accounts configuration
- `test/models/account_test.rb` - Add conversion tests
- `test/models/user_test.rb` - Add personal_account tests
- `test/models/session_test.rb` - Add default account tests
- `test/fixtures/accounts.yml` - Add personal boolean and owner_id

### New Views (4)
- `app/views/accounts/index.html.erb`
- `app/views/accounts/new.html.erb`
- `app/views/accounts/edit.html.erb`
- `app/views/accounts/show.html.erb`

### New Tests (4)
- `test/integration/account_switching_test.rb`
- `test/integration/account_conversion_test.rb`
- `test/integration/registration_with_personal_accounts_test.rb`
- `test/integration/account_management_test.rb`

**Total:** 28 files (8 new, 12 modified, 4 new views, 4 new tests)

## Migration Path from Iteration 3

If implementing iteration 3 (session-based, no personal column):

1. Run migrations: Add `personal` column and `owner_id` column
2. Backfill data:
   - Set `personal` appropriately for existing accounts
   - Set `owner_id` from existing "owner" role memberships
3. Remove "owner" role from AccountMembership enum (update to admin where needed)
4. Deploy Account conversion controllers
5. Deploy Account management UI
6. Update registration flow

Minimal data migration required - mostly additive changes.

## Key Architectural Decisions

### Why `owner_id` instead of "owner" role in AccountMembership?

**Simpler and clearer separation of concerns:**
- Every account has exactly one owner (enforced by `null: false`)
- Ownership checks are straightforward: `account.owner == user`
- Membership roles (`admin`, `member`) are purely for permissions, not ownership
- No confusion about whether owner needs a membership record
- Personal accounts: `owner_id` = the single user
- Team accounts: `owner_id` = team creator/owner

### Why `personal` boolean instead of `account_type` enum?

**Simpler.** Two states (personal/team) don't need enum overhead. Boolean is more Rails-like for binary choices.

### Why keep conversion features in starter kit?

**Developers need options.** A user might start with a personal account and later want to collaborate. Forcing them to create a new account and migrate data is poor UX. Provide the conversion path up front.

### Why single `personal_accounts` config instead of multiple options?

**One decision point.** More configs = more combinations to test and document. The boolean covers the main use cases:
- `true` = "Personal-first" (e.g., Notion, GitHub)
- `false` = "Team-only" (e.g., Slack, enterprise tools)

Developers can customize further if needed, but this gives them a working starting point.

### Why allow personal accounts to become teams?

**Growth path.** Solo founders start personal, then hire. Don't force them to recreate everything in a "team" account. Let the account evolve with their business.

### Why require solo membership for team → personal conversion?

**Data integrity.** Converting a multi-member team to personal would orphan other members. Requiring solo membership prevents this edge case.

## Comparison to Iterations 1-3

### Iteration 1 (1,905 lines)
- ❌ `account_type` enum (3 states: personal, team, enterprise)
- ❌ Multiple configuration flags
- ❌ Factory methods with config checks
- ❌ Over-abstracted helpers
- ✅ Account conversion
- ✅ Account management UI

### Iteration 2-3 (450 lines)
- ✅ Session-based Current.account
- ✅ No users.account_id
- ✅ Simple architecture
- ❌ No account conversion (deferred)
- ❌ No account management UI (deferred)
- ❌ No personal/team distinction
- ❌ No configuration options

### Iteration 4 (This Spec - ~850 lines)
- ✅ Session-based Current.account (from iteration 3)
- ✅ No users.account_id (from iteration 3)
- ✅ Simple architecture (from iteration 3)
- ✅ `personal` boolean (simpler than iteration 1 enum)
- ✅ Account conversion (restored from iteration 1)
- ✅ Account management UI (restored from iteration 1)
- ✅ Single config flag (simpler than iteration 1)
- ✅ Integration test focus (from iteration 3)

**Result:** Feature-complete starter kit without the over-engineering of iteration 1 or the "defer everything" approach of iteration 2-3.

## Implementation Estimate

- **Phase 1 (Database & Models):** 1 day
- **Phase 2 (Switching & Registration):** 1 day
- **Phase 3 (Account Management):** 1 day
- **Phase 4 (Conversion):** 1 day

**Total:** 4 days for complete implementation with tests.

Realistic for a starter kit where all features should be present and working out of the box.
