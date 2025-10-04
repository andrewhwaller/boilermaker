# Technical Specification: Flexible Accounts System

**Date:** 2025-10-01
**Status:** Draft
**Related Issues:** N/A

## Overview

This specification describes implementing a flexible accounts system similar to Jumpstart Rails, allowing the application to operate in two modes:

1. **Personal accounts mode** (`features.personal_accounts: true`): Users receive personal accounts on signup and can create/join team accounts
2. **Team-only mode** (`features.personal_accounts: false`): Team accounts only, no personal accounts

The implementation moves from the current single-account-per-user model to a multi-account model where users access accounts via memberships and switch between accounts using session-based tracking.

## Goals

- Remove the `users.account_id` foreign key column entirely
- Add `accounts.account_type` enum column to distinguish personal vs team accounts
- Implement `Current.account` for session-based account tracking
- Refactor all `Current.user.account` references to use `Current.account`
- Create account switching UI and functionality
- Support configuration-driven account creation flows
- Enable account type conversion (personal ↔ team)

## Non-Goals

- Invitation system changes (already working, minimal updates needed)
- URL-based account scoping (exists in `AccountMiddleware` but not required for MVP)
- Account billing or subscription features
- Account deletion/archival

---

## 1. Database Changes

### 1.1 Migration: Add account_type to accounts

**File:** `db/migrate/YYYYMMDDHHMMSS_add_account_type_to_accounts.rb`

```ruby
class AddAccountTypeToAccounts < ActiveRecord::Migration[8.0]
  def change
    # Use string column for SQLite compatibility
    add_column :accounts, :account_type, :string, null: false, default: "team"

    add_index :accounts, :account_type
  end
end
```

**Rationale:** Using string column instead of enum for SQLite compatibility. Default to "team" for existing records. Valid values: `"personal"`, `"team"`.

### 1.2 Migration: Remove account_id from users

**File:** `db/migrate/YYYYMMDDHHMMSS_remove_account_id_from_users.rb`

```ruby
class RemoveAccountIdFromUsers < ActiveRecord::Migration[8.0]
  def up
    # Remove foreign key first
    remove_foreign_key :users, :accounts if foreign_key_exists?(:users, :accounts)

    # Remove index
    remove_index :users, :account_id if index_exists?(:users, :account_id)

    # Remove column
    remove_column :users, :account_id
  end

  def down
    # Reversible migration for safety
    add_reference :users, :account, null: true, foreign_key: true

    # Backfill account_id from first membership (if reverting)
    execute <<-SQL
      UPDATE users
      SET account_id = (
        SELECT account_id
        FROM account_memberships
        WHERE account_memberships.user_id = users.id
        LIMIT 1
      )
    SQL

    change_column_null :users, :account_id, false
  end
end
```

**Rationale:** Safe removal with reversible migration. The `down` method backfills from memberships if migration needs reverting.

### 1.3 Data Migration: Ensure all existing accounts are marked as team

**File:** `db/migrate/YYYYMMDDHHMMSS_backfill_account_types.rb`

```ruby
class BackfillAccountTypes < ActiveRecord::Migration[8.0]
  def up
    # All existing accounts default to team type (set in previous migration)
    # This migration placeholder for future personal account detection logic

    # If we want to detect likely personal accounts based on single user:
    # execute <<-SQL
    #   UPDATE accounts
    #   SET account_type = 'personal'
    #   WHERE id IN (
    #     SELECT account_id
    #     FROM account_memberships
    #     GROUP BY account_id
    #     HAVING COUNT(*) = 1
    #   )
    # SQL
  end

  def down
    # No-op, account_type column defaults to 'team'
  end
end
```

**Rationale:** Greenfield project, so default to team is fine. Can uncomment detection logic if needed for existing production data.

### 1.4 Migration: Add account_id to sessions

**File:** `db/migrate/YYYYMMDDHHMMSS_add_account_id_to_sessions.rb`

```ruby
class AddAccountIdToSessions < ActiveRecord::Migration[8.0]
  def change
    add_reference :sessions, :account, null: true, foreign_key: true
    add_index :sessions, [:user_id, :account_id]
  end
end
```

**Rationale:** Store current account in session record for persistence across requests. Null allowed for backwards compatibility during migration.

### 1.5 Updated Schema (Expected State)

```ruby
create_table "accounts" do |t|
  t.string "name", null: false
  t.string "account_type", null: false, default: "team"
  t.timestamps
  t.index ["account_type"]
end

create_table "account_memberships" do |t|
  t.references :user, null: false, foreign_key: true
  t.references :account, null: false, foreign_key: true
  t.json :roles, null: false, default: {}
  t.timestamps
  t.index ["user_id", "account_id"], unique: true
end

create_table "users" do |t|
  t.string "email", null: false
  t.string "password_digest", null: false
  # ... other fields ...
  # account_id REMOVED
  t.timestamps
  t.index ["email"], unique: true
end

create_table "sessions" do |t|
  t.references :user, null: false, foreign_key: true
  t.references :account, null: true, foreign_key: true
  # ... other fields ...
  t.timestamps
  t.index ["user_id"]
  t.index ["user_id", "account_id"]
end
```

---

## 2. Model Changes

### 2.1 Account Model

**File:** `app/models/account.rb`

```ruby
class Account < ApplicationRecord
  include Hashid::Rails

  # Associations
  has_many :account_memberships, dependent: :destroy
  has_many :members, through: :account_memberships, source: :user
  has_many :sessions, dependent: :nullify  # When account deleted, clear session account_id

  # Validations
  validates :name, presence: true
  validates :account_type, presence: true, inclusion: { in: %w[personal team] }

  # Scopes
  scope :personal, -> { where(account_type: "personal") }
  scope :team, -> { where(account_type: "team") }

  # Type checking
  def personal?
    account_type == "personal"
  end

  def team?
    account_type == "team"
  end

  # Conversion methods
  def convert_to_team!
    update!(account_type: "team")
  end

  def convert_to_personal!
    # Validation: personal accounts should only have one owner
    if members.count > 1
      errors.add(:base, "Cannot convert to personal account with multiple members")
      return false
    end

    update!(account_type: "personal")
  end

  # Factory method: create personal account for user
  def self.create_personal_for(user)
    return unless Boilermaker.config.personal_accounts?

    account_name = Boilermaker.config.get("accounts.default_account_name") || "Personal"
    account = create!(
      name: "#{account_name} (#{user.email})",
      account_type: "personal"
    )

    # Create owner membership
    AccountMembership.create!(
      user: user,
      account: account,
      roles: { owner: true, admin: true, member: true }
    )

    account
  end

  # Owner helpers
  def owner
    memberships.with_role(:owner).first&.user
  end

  def owner?(user)
    memberships.for_user(user).any?(&:owner?)
  end

  private

  def memberships
    account_memberships
  end
end
```

**Key Changes:**
- Remove `has_many :users` (users no longer belong directly to accounts)
- Add `account_type` validation and helper methods
- Add conversion methods with validation
- Add `create_personal_for` factory method
- Add `has_many :sessions` for session tracking
- Remove `create_default_for_user` (replaced by `create_personal_for`)

### 2.2 User Model

**File:** `app/models/user.rb`

```ruby
class User < ApplicationRecord
  include Hashid::Rails

  # Associations
  has_many :account_memberships, dependent: :destroy
  has_many :accounts, through: :account_memberships
  has_many :sessions, dependent: :destroy
  has_many :recovery_codes, dependent: :destroy
  has_secure_password

  # Remove: belongs_to :account

  # Validations
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, allow_nil: true, length: { minimum: -> { Boilermaker.config.password_min_length } }

  normalizes :email, with: -> { _1.strip.downcase }

  # Scopes
  scope :unverified, -> { where(verified: false) }
  scope :verified, -> { where(verified: true) }

  # Callbacks
  before_validation if: :email_changed?, on: :update do
    self.verified = false
  end

  before_create do
    self.otp_secret = ROTP::Base32.random if otp_secret.blank?
  end

  after_update if: :password_digest_previously_changed? do
    sessions.where.not(id: Current.session).delete_all
  end

  # Account access methods
  def personal_account
    accounts.personal.first
  end

  def team_accounts
    accounts.team
  end

  def default_account
    personal_account || accounts.first
  end

  # Returns the membership for a given account
  def membership_for(account)
    account_memberships.find_by(account_id: account&.id)
  end

  # Check if user is admin for specific account
  def account_admin_for?(account = nil)
    return true if app_admin?

    target_account = account || Current.account
    membership_for(target_account)&.admin? || false
  end

  # Check if user is owner of specific account
  def account_owner_for?(account = nil)
    return true if app_admin?

    target_account = account || Current.account
    membership_for(target_account)&.owner? || false
  end

  # App admin helper
  def app_admin?
    app_admin
  end

  # Check if user has access to account
  def can_access?(account)
    app_admin? || accounts.include?(account)
  end
end
```

**Key Changes:**
- Remove `belongs_to :account`
- Add `personal_account`, `team_accounts`, `default_account` helper methods
- Update `account_admin_for?` to use `Current.account` or explicit account parameter
- Add `account_owner_for?` method
- Add `can_access?` method for authorization

### 2.3 Current Model

**File:** `app/models/current.rb`

```ruby
class Current < ActiveSupport::CurrentAttributes
  attribute :session
  attribute :account  # NEW
  attribute :user_agent, :ip_address, :theme_name

  delegate :user, to: :session, allow_nil: true

  # Resets are handled automatically by CurrentAttributes
  # after each request completes
end
```

**Key Changes:**
- Add `account` attribute for session-based account tracking

### 2.4 Session Model

**File:** `app/models/session.rb`

```ruby
class Session < ApplicationRecord
  belongs_to :user
  belongs_to :account, optional: true  # NEW

  before_create :set_default_account

  private

  def set_default_account
    self.account ||= user.default_account
  end
end
```

**Key Changes:**
- Add `belongs_to :account` (optional for backwards compatibility)
- Add callback to set default account on session creation

### 2.5 AccountMembership Model

**File:** `app/models/account_membership.rb`

No changes required. Model already has all needed functionality:
- Role management (owner, admin, member)
- Scopes for filtering by account/user
- Helper methods (`owner?`, `admin?`, `member?`)

---

## 3. Session Management & Current Account

### 3.1 ApplicationController Updates

**File:** `app/controllers/application_controller.rb`

```ruby
class ApplicationController < ActionController::Base
  include Rails.application.routes.url_helpers

  before_action :assign_theme_from_cookie
  before_action :set_current_request_details
  before_action :authenticate
  before_action :set_current_account  # NEW
  before_action :ensure_verified

  layout "application"

  private

  def authenticate
    if session_record = Session.find_by_id(cookies.signed[:session_token])
      Current.session = session_record
    else
      redirect_to sign_in_path
    end
  end

  # NEW METHOD
  def set_current_account
    return unless Current.session

    # Use account from session, or fall back to user's default account
    account = Current.session.account || Current.user.default_account

    # Verify user has access to this account
    if account && Current.user.can_access?(account)
      Current.account = account
    else
      # Fallback to first available account
      Current.account = Current.user.accounts.first

      # Update session to track the account
      Current.session.update(account: Current.account) if Current.account
    end
  end

  def ensure_verified
    redirect_to identity_email_verification_path unless Current.user&.verified?
  end

  def set_current_request_details
    Current.user_agent = request.user_agent
    Current.ip_address = request.ip
  end

  def assign_theme_from_cookie
    name = cookies[:theme_name].to_s.strip
    Current.theme_name = resolve_theme_name(name)
  rescue
    Current.theme_name = resolve_theme_name(nil)
  end

  def resolve_theme_name(name)
    return name if [Boilermaker::Config.theme_light_name, Boilermaker::Config.theme_dark_name].include?(name)
    return name if Boilermaker::Themes::ALL.include?(name)
    if defined?(Boilermaker::Themes) && Boilermaker::Themes::BUILTINS.include?(name)
      return name
    end
    Boilermaker::Config.theme_light_name
  end
end
```

**Key Changes:**
- Add `set_current_account` before_action
- Set `Current.account` from session or user's default
- Validate user has access to the account
- Update session with current account for persistence

### 3.2 Account Switching Controller

**File:** `app/controllers/account_switches_controller.rb` (NEW)

```ruby
class AccountSwitchesController < ApplicationController
  def create
    account = Current.user.accounts.find_by(id: params[:account_id])

    unless account
      redirect_back fallback_location: root_path, alert: "Account not found or access denied."
      return
    end

    # Update current session to track new account
    Current.session.update!(account: account)
    Current.account = account

    redirect_back fallback_location: root_path, notice: "Switched to #{account.name}"
  end
end
```

**Purpose:** Handle account switching via POST requests from account switcher dropdown.

---

## 4. Controller Refactoring

### 4.1 Replace Current.user.account with Current.account

The following files contain `Current.user.account` references and need refactoring:

**Files to update:**
1. `/app/controllers/account/dashboards_controller.rb`
2. `/app/controllers/account/invitations_controller.rb`
3. `/app/controllers/account/users_controller.rb`
4. `/app/controllers/account/settings_controller.rb`
5. `/app/views/account/dashboards/show.rb`
6. `/app/views/account/users/edit.rb`
7. `/app/views/account/users/show.rb`
8. `/app/views/account/invitations/index.rb`
9. `/app/components/account/user_table.rb`

**Example Refactor:**

Before:
```ruby
@pending_users = Current.user.account.users.where(verified: false)
```

After:
```ruby
@pending_users = Current.account.members.where(verified: false)
```

**Pattern:**
- `Current.user.account` → `Current.account`
- `Current.user.account.users` → `Current.account.members`
- Verify authorization uses `Current.user.account_admin_for?(Current.account)` or just `Current.user.account_admin_for?` (defaults to Current.account)

### 4.2 Account::BaseController Updates

**File:** `app/controllers/account/base_controller.rb`

```ruby
class Account::BaseController < ApplicationController
  before_action :require_account_admin
  before_action :ensure_current_account  # NEW

  private

  def require_account_admin
    unless Current.user&.account_admin_for?(Current.account)
      redirect_to root_path, alert: "Access denied. Admin privileges required."
    end
  end

  # NEW METHOD
  def ensure_current_account
    unless Current.account
      redirect_to root_path, alert: "No account selected."
    end
  end
end
```

**Key Changes:**
- Add `ensure_current_account` to verify account is set
- Update authorization to explicitly check against `Current.account`

---

## 5. Registration Flow

### 5.1 RegistrationsController Updates

**File:** `app/controllers/registrations_controller.rb`

```ruby
class RegistrationsController < ApplicationController
  skip_before_action :authenticate
  skip_before_action :ensure_verified
  skip_before_action :set_current_account  # NEW

  def new
    @user = User.new
    render Views::Registrations::New.new(user: @user)
  end

  def create
    @user = User.new(user_params)

    ActiveRecord::Base.transaction do
      # Save user first
      @user.save!

      # Create account based on configuration
      if Boilermaker.config.personal_accounts?
        # Personal accounts mode: create personal account
        account = Account.create_personal_for(@user)
      else
        # Team-only mode: create team account with provided name
        account_name = params[:account_name].presence || "Team"
        account = Account.create!(name: account_name, account_type: "team")

        # Create owner membership
        AccountMembership.create!(
          user: @user,
          account: account,
          roles: { owner: true, admin: true, member: true }
        )
      end

      # Create session with account
      session_record = @user.sessions.create!(account: account)
      cookies.signed.permanent[:session_token] = { value: session_record.id, httponly: true }

      send_email_verification
    end

    redirect_to root_path, notice: "Welcome! You have signed up successfully"
  rescue ActiveRecord::RecordInvalid => e
    @user.errors.add(:base, e.message) unless @user.errors.any?
    render Views::Registrations::New.new(user: @user), status: :unprocessable_entity
  end

  private

  def user_params
    params.permit(:email, :password, :password_confirmation)
  end

  def send_email_verification
    UserMailer.with(user: @user).email_verification.deliver_later
  end
end
```

**Key Changes:**
- Skip `set_current_account` before_action (not authenticated yet)
- Use `Account.create_personal_for(@user)` in personal accounts mode
- Create team account with membership in team-only mode
- Create session with account reference
- Wrap in transaction for atomicity

### 5.2 Registration View Updates

**File:** `app/views/registrations/new.rb`

```ruby
module Views
  module Registrations
    class New < Views::Base
      include Phlex::Rails::Helpers::FormWith
      include Phlex::Rails::Helpers::LinkTo

      def initialize(user:)
        @user = user
      end

      def view_template
        page_with_title("Sign up") do
          centered_container do
            card do
              h1(class: "font-semibold text-base-content mb-6") { "Sign up" }

              form_errors(@user) if @user.errors.any?

              form_with(url: sign_up_path, class: "space-y-4") do |form|
                # Conditionally show account name field
                unless personal_accounts_enabled?
                  FormGroup(
                    label_text: "Team name",
                    input_type: :text,
                    name: "account_name",
                    id: "account_name",
                    required: true,
                    help_text: "Choose a name for your team account."
                  )
                end

                EmailField(
                  name: "email",
                  id: "user_email",
                  value: @user.email,
                  autofocus: true
                )

                PasswordField(
                  label_text: "Password",
                  name: "password",
                  id: "user_password",
                  help_text: "#{Boilermaker.config.password_min_length} characters minimum."
                )

                PasswordField(
                  label_text: "Password confirmation",
                  name: "password_confirmation",
                  id: "user_password_confirmation"
                )

                SubmitButton("Sign up")
              end

              AuthLinks(links: [
                { text: "Already have an account? Sign in", path: sign_in_path }
              ])
            end
          end
        end
      end

      private

      attr_reader :user

      def personal_accounts_enabled?
        Boilermaker.config.personal_accounts?
      end
    end
  end
end
```

**Key Changes:**
- Conditionally render "Team name" field when `personal_accounts: false`
- Update help text to clarify team vs personal mode
- Remove field name prefix `user[]` for cleaner params

---

## 6. View & Component Changes

### 6.1 Account Switcher Component

**File:** `app/components/account_switcher.rb` (NEW)

```ruby
class Components::AccountSwitcher < Components::Base
  include Phlex::Rails::Helpers::ButtonTo
  include ApplicationHelper

  def initialize(current_account:, user:)
    @current_account = current_account
    @user = user
  end

  def view_template
    render Components::DropdownMenu.new(trigger_text: account_trigger_text) do
      # Current account indicator
      div(class: "px-4 py-2 text-xs text-base-content/60 font-mono tracking-wider border-b border-base-300/50") do
        "CURRENT ACCOUNT"
      end

      # List user's accounts
      @user.accounts.each do |account|
        if account.id == @current_account&.id
          # Current account (disabled)
          div(class: "px-4 py-2 text-sm font-mono bg-base-200") do
            account_item_content(account, current: true)
          end
        else
          # Switchable account
          button_to switch_account_path(account_id: account.id),
            method: :post,
            class: "w-full text-left px-4 py-2 text-sm font-mono hover:bg-base-200 transition-colors" do
            account_item_content(account)
          end
        end
      end

      # Separator
      div(class: "h-px bg-base-300/50 my-1")

      # Create new team account link
      render Components::DropdownMenuItem.new(
        new_account_path,
        "Create team account",
        class: "text-primary"
      )
    end
  end

  private

  def account_trigger_text
    if @current_account
      truncate_text(@current_account.name, 20)
    else
      "Select account"
    end
  end

  def account_item_content(account, current: false)
    div(class: "flex items-center justify-between") do
      div do
        div(class: "font-medium") { truncate_text(account.name, 25) }
        div(class: "text-xs text-base-content/60") do
          badge_text = account.personal? ? "PERSONAL" : "TEAM"
          badge_text += " • CURRENT" if current
          badge_text
        end
      end

      if account.owner?(@user)
        span(class: "text-xs text-primary") { "OWNER" }
      end
    end
  end

  def truncate_text(text, length)
    text.length > length ? "#{text[0...length]}..." : text
  end
end
```

**Purpose:** Dropdown component for switching between user's accounts.

### 6.2 Navigation Component Updates

**File:** `app/components/navigation.rb`

Update the `authenticated_controls` method:

```ruby
def authenticated_controls
  if show_account_dropdown?
    # Replace account dropdown with account switcher
    if Current.account && Current.user.accounts.count > 1
      render Components::AccountSwitcher.new(
        current_account: Current.account,
        user: Current.user
      )
    else
      # Single account, show account dropdown as before
      account_dropdown
    end
  else
    sign_out_button
  end
end
```

**Key Changes:**
- Use `AccountSwitcher` when user has multiple accounts
- Fall back to existing dropdown for single account users

### 6.3 Sidebar Navigation Updates

**File:** `app/components/sidebar_navigation.rb`

Add account switcher to footer section:

```ruby
def footer_section
  div(class: "p-4 border-t border-base-300/50 space-y-3") do
    # Account switcher (if multiple accounts)
    if Current.user.present? && Current.account && Current.user.accounts.count > 1
      render Components::AccountSwitcher.new(
        current_account: Current.account,
        user: Current.user
      )
    end

    div(class: "flex justify-center") do
      render Components::ThemeToggle.new(show_label: true, position: :sidebar)
    end

    if Current.user.present?
      button_to session_path("current"),
        method: :delete,
        class: "btn btn-ghost btn-sm normal-case font-mono text-xs tracking-wider border-0 rounded-none text-error hover:bg-error/10 w-full text-center" do
        "EXIT SYSTEM"
      end
    end
  end
end
```

### 6.4 Account Management Views

**File:** `app/controllers/accounts_controller.rb` (NEW)

```ruby
class AccountsController < ApplicationController
  def index
    @accounts = Current.user.accounts.order(created_at: :desc)
    render Views::Accounts::Index.new(accounts: @accounts)
  end

  def show
    @account = Current.user.accounts.find(params[:id])
    render Views::Accounts::Show.new(account: @account)
  rescue ActiveRecord::RecordNotFound
    redirect_to accounts_path, alert: "Account not found or access denied."
  end

  def new
    @account = Account.new
    render Views::Accounts::New.new(account: @account)
  end

  def create
    @account = Account.new(account_params.merge(account_type: "team"))

    ActiveRecord::Base.transaction do
      @account.save!

      # Create owner membership for current user
      AccountMembership.create!(
        user: Current.user,
        account: @account,
        roles: { owner: true, admin: true, member: true }
      )
    end

    redirect_to account_path(@account), notice: "Team account created successfully."
  rescue ActiveRecord::RecordInvalid
    render Views::Accounts::New.new(account: @account), status: :unprocessable_entity
  end

  def edit
    @account = Current.user.accounts.find(params[:id])

    unless Current.user.account_admin_for?(@account)
      redirect_to account_path(@account), alert: "Admin privileges required."
      return
    end

    render Views::Accounts::Edit.new(account: @account)
  end

  def update
    @account = Current.user.accounts.find(params[:id])

    unless Current.user.account_admin_for?(@account)
      redirect_to account_path(@account), alert: "Admin privileges required."
      return
    end

    if @account.update(account_params)
      redirect_to account_path(@account), notice: "Account updated successfully."
    else
      render Views::Accounts::Edit.new(account: @account), status: :unprocessable_entity
    end
  end

  private

  def account_params
    params.require(:account).permit(:name)
  end
end
```

**File:** `app/views/accounts/index.rb` (NEW)

```ruby
module Views
  module Accounts
    class Index < Views::Base
      include Phlex::Rails::Helpers::LinkTo

      def initialize(accounts:)
        @accounts = accounts
      end

      def view_template
        page_with_title("Your Accounts") do
          container do
            div(class: "space-y-6") do
              # Header with create button
              div(class: "flex justify-between items-center") do
                h1(class: "text-2xl font-bold") { "Your Accounts" }

                a(
                  href: new_account_path,
                  class: "btn btn-primary btn-sm"
                ) { "Create Team Account" }
              end

              # Accounts list
              if @accounts.any?
                div(class: "grid gap-4 md:grid-cols-2 lg:grid-cols-3") do
                  @accounts.each do |account|
                    account_card(account)
                  end
                end
              else
                empty_state
              end
            end
          end
        end
      end

      private

      def account_card(account)
        a(
          href: account_path(account),
          class: "card bg-base-100 border border-base-300 hover:border-primary transition-colors"
        ) do
          div(class: "card-body") do
            div(class: "flex justify-between items-start") do
              div do
                h2(class: "card-title text-lg") { account.name }
                p(class: "text-sm text-base-content/60") do
                  account.personal? ? "Personal Account" : "Team Account"
                end
              end

              render Components::Badge.new(
                text: account.personal? ? "Personal" : "Team",
                color: account.personal? ? "primary" : "secondary"
              )
            end

            div(class: "mt-4 text-xs text-base-content/60") do
              "#{account.members.count} member(s)"
            end
          end
        end
      end

      def empty_state
        div(class: "text-center py-12") do
          p(class: "text-base-content/60") { "No accounts found." }
        end
      end
    end
  end
end
```

**File:** `app/views/accounts/new.rb` (NEW)

```ruby
module Views
  module Accounts
    class New < Views::Base
      include Phlex::Rails::Helpers::FormWith

      def initialize(account:)
        @account = account
      end

      def view_template
        page_with_title("Create Team Account") do
          centered_container do
            card do
              h1(class: "text-xl font-bold mb-6") { "Create Team Account" }

              form_errors(@account) if @account.errors.any?

              form_with(model: @account, url: accounts_path, class: "space-y-4") do |form|
                FormGroup(
                  label_text: "Team name",
                  input_type: :text,
                  name: "account[name]",
                  id: "account_name",
                  required: true,
                  autofocus: true,
                  help_text: "Choose a name for your team account."
                )

                div(class: "flex gap-2") do
                  SubmitButton("Create Account")

                  a(
                    href: accounts_path,
                    class: "btn btn-ghost"
                  ) { "Cancel" }
                end
              end
            end
          end
        end
      end

      private

      attr_reader :account
    end
  end
end
```

### 6.5 Account Conversion UI

**File:** `app/controllers/account_conversions_controller.rb` (NEW)

```ruby
class AccountConversionsController < ApplicationController
  before_action :set_account
  before_action :require_owner

  def new
    render Views::AccountConversions::New.new(account: @account)
  end

  def create
    target_type = params[:target_type]

    unless %w[personal team].include?(target_type)
      redirect_to account_path(@account), alert: "Invalid account type."
      return
    end

    if target_type == "personal"
      convert_to_personal
    else
      convert_to_team
    end
  end

  private

  def set_account
    @account = Current.user.accounts.find(params[:account_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to accounts_path, alert: "Account not found or access denied."
  end

  def require_owner
    unless Current.user.account_owner_for?(@account)
      redirect_to account_path(@account), alert: "Owner privileges required for account conversion."
    end
  end

  def convert_to_personal
    if @account.convert_to_personal!
      redirect_to account_path(@account), notice: "Account converted to personal account."
    else
      redirect_to account_path(@account), alert: @account.errors.full_messages.join(", ")
    end
  end

  def convert_to_team
    @account.convert_to_team!
    redirect_to account_path(@account), notice: "Account converted to team account."
  end
end
```

**File:** `app/views/account_conversions/new.rb` (NEW)

```ruby
module Views
  module AccountConversions
    class New < Views::Base
      include Phlex::Rails::Helpers::FormWith
      include Phlex::Rails::Helpers::ButtonTo

      def initialize(account:)
        @account = account
      end

      def view_template
        page_with_title("Convert Account Type") do
          centered_container do
            card do
              h1(class: "text-xl font-bold mb-6") { "Convert Account Type" }

              div(class: "space-y-6") do
                # Current type
                div do
                  p(class: "text-sm text-base-content/60") { "Current type:" }
                  p(class: "text-lg font-semibold") do
                    @account.personal? ? "Personal Account" : "Team Account"
                  end
                end

                # Conversion options
                if @account.personal?
                  personal_to_team_form
                else
                  team_to_personal_form
                end
              end
            end
          end
        end
      end

      private

      def personal_to_team_form
        div(class: "space-y-4") do
          p(class: "text-sm") do
            "Converting to a team account will allow you to invite multiple members."
          end

          button_to "Convert to Team Account",
            account_conversion_path(@account),
            method: :post,
            params: { target_type: "team" },
            class: "btn btn-primary",
            data: { confirm: "Are you sure you want to convert this to a team account?" }
        end
      end

      def team_to_personal_form
        div(class: "space-y-4") do
          if @account.members.count > 1
            div(class: "alert alert-warning") do
              p { "Cannot convert to personal account with multiple members." }
              p(class: "text-sm mt-2") do
                "Remove all members except yourself before converting to a personal account."
              end
            end
          else
            p(class: "text-sm") do
              "Converting to a personal account will restrict this account to a single user."
            end

            button_to "Convert to Personal Account",
              account_conversion_path(@account),
              method: :post,
              params: { target_type: "personal" },
              class: "btn btn-primary",
              data: { confirm: "Are you sure you want to convert this to a personal account?" }
          end
        end
      end
    end
  end
end
```

---

## 7. Routes

**File:** `config/routes.rb`

Add the following routes:

```ruby
Rails.application.routes.draw do
  # ... existing routes ...

  # Account switching
  post "switch_account", to: "account_switches#create", as: :switch_account

  # Account management (user-level, not admin)
  resources :accounts, only: [:index, :show, :new, :create, :edit, :update] do
    resource :conversion, only: [:new, :create], controller: "account_conversions"
  end

  # Account admin (existing, keep as-is)
  get "account", to: "account/dashboards#show", as: :account
  patch "account", to: "account/dashboards#update"
  scope :account, module: :account, as: :account do
    resources :users, only: [:index, :show, :edit, :update, :destroy]
    resources :invitations, only: [:index, :new, :create, :destroy]
    resource :settings, only: [:show, :edit, :update]
  end

  # ... rest of routes ...
end
```

**Route Summary:**
- `GET /accounts` - List user's accounts
- `GET /accounts/:id` - View account details
- `GET /accounts/new` - Create new team account form
- `POST /accounts` - Create team account
- `GET /accounts/:id/edit` - Edit account (admin only)
- `PATCH /accounts/:id` - Update account (admin only)
- `GET /accounts/:id/conversion/new` - Account conversion form
- `POST /accounts/:id/conversion` - Convert account type
- `POST /switch_account` - Switch current account

---

## 8. Configuration Updates

### 8.1 Boilermaker Configuration

**File:** `config/boilermaker.yml`

Add new configuration options:

```yaml
default:
  app:
    name: Boilermaker
    version: 1.0.0
    support_email: support@example.com
  features:
    user_registration: true
    password_reset: true
    two_factor_authentication: false
    multi_tenant: false
    personal_accounts: true  # NEW: Enable personal accounts mode
  accounts:  # NEW SECTION
    default_account_name: "Personal"  # Name prefix for personal accounts
    allow_account_creation: true      # Allow users to create new team accounts
    allow_type_conversion: true        # Allow converting personal ↔ team

development:
  # ... environment-specific overrides ...
```

**File:** `lib/boilermaker/config.rb`

Add convenience methods:

```ruby
# Add to Config class
def allow_account_creation?
  get("accounts.allow_account_creation") != false  # Default true
end

def allow_type_conversion?
  get("accounts.allow_type_conversion") != false  # Default true
end
```

---

## 9. Helper Methods

### 9.1 Application Helper Updates

**File:** `app/helpers/application_helper.rb`

```ruby
module ApplicationHelper
  # Existing helpers...

  # Account helpers
  def current_account
    Current.account
  end

  def current_account_name
    current_account&.name || "No Account"
  end

  def personal_accounts_enabled?
    Boilermaker.config.personal_accounts?
  end

  def user_has_multiple_accounts?
    Current.user&.accounts&.count.to_i > 1
  end

  def account_type_badge(account)
    if account.personal?
      render Components::Badge.new(text: "Personal", color: "primary")
    else
      render Components::Badge.new(text: "Team", color: "secondary")
    end
  end
end
```

---

## 10. Testing Strategy

### 10.1 Model Tests

**Tests to write:**

1. **Account model** (`test/models/account_test.rb`):
   - Validate account_type inclusion
   - Test `personal?` and `team?` methods
   - Test `convert_to_team!` and `convert_to_personal!`
   - Test `create_personal_for` factory method
   - Test conversion validation (cannot convert team with multiple members)
   - Test owner methods

2. **User model** (`test/models/user_test.rb`):
   - Test `personal_account`, `team_accounts`, `default_account` methods
   - Test `membership_for` with different accounts
   - Test `account_admin_for?` with explicit account parameter
   - Test `account_owner_for?` method
   - Test `can_access?` authorization

3. **Session model** (`test/models/session_test.rb`):
   - Test `set_default_account` callback
   - Test account association

### 10.2 Controller Tests

**Tests to write:**

1. **RegistrationsController** (`test/controllers/registrations_controller_test.rb`):
   - Test personal account creation when `personal_accounts: true`
   - Test team account creation when `personal_accounts: false`
   - Test membership creation with owner role
   - Test session created with account reference

2. **AccountsController** (`test/controllers/accounts_controller_test.rb`):
   - Test index shows user's accounts
   - Test show requires account access
   - Test create team account
   - Test authorization for edit/update

3. **AccountSwitchesController** (`test/controllers/account_switches_controller_test.rb`):
   - Test switching between user's accounts
   - Test session updated with new account
   - Test authorization (cannot switch to account without access)

4. **AccountConversionsController** (`test/controllers/account_conversions_controller_test.rb`):
   - Test personal → team conversion
   - Test team → personal conversion
   - Test validation error when team has multiple members
   - Test owner-only authorization

### 10.3 Integration Tests

**Tests to write:**

1. **Account switching flow** (`test/integration/account_switching_test.rb`):
   - User with multiple accounts can switch
   - Current.account persists across requests
   - Account switcher shows correct accounts

2. **Registration flow** (`test/integration/registration_flow_test.rb`):
   - Personal accounts mode creates personal account
   - Team-only mode requires team name
   - User can access account after signup

3. **Invitation flow** (`test/integration/invitation_flow_test.rb`):
   - Invitations scoped to Current.account (not Current.user.account)
   - Invited users added to correct account

### 10.4 Component Tests

**Tests to write:**

1. **AccountSwitcher component** (`test/components/account_switcher_test.rb`):
   - Renders user's accounts
   - Shows current account indicator
   - Shows account type badges
   - Shows owner badge

2. **Navigation component** (`test/components/navigation_test.rb`):
   - Shows account switcher when multiple accounts
   - Shows single account dropdown when one account

### 10.5 Tests to Update

**Existing tests that need updates:**

1. All controller tests using `Current.user.account`:
   - Update to use `Current.account`
   - Ensure test setup creates account memberships

2. Fixture/factory updates:
   - Remove direct `user.account` associations
   - Create via memberships instead

3. Integration tests:
   - Update assertions expecting `user.account`
   - Use `Current.account` or `user.default_account`

---

## 11. Edge Cases & Validation

### 11.1 Account Conversion Validations

**Personal → Team:**
- ✅ Always allowed
- No restrictions on member count
- Preserves existing memberships

**Team → Personal:**
- ❌ Not allowed if `members.count > 1`
- Error message: "Cannot convert to personal account with multiple members"
- Owner must remove other members first

### 11.2 Account Access & Authorization

**Scenarios:**

1. **User with no accounts:**
   - Edge case: Should not happen in normal flow
   - Fallback: Redirect to account creation or show error
   - Prevention: Registration always creates account + membership

2. **User deletes their last account:**
   - Not supported in MVP (no account deletion)
   - Future: Require user to have at least one account

3. **Session references deleted account:**
   - Session.account uses `optional: true`
   - `set_current_account` falls back to `user.default_account`
   - Session updated with new account

4. **User switches to account they don't have access to:**
   - `AccountSwitchesController` validates via `Current.user.accounts.find`
   - Returns 404 or redirect with error

5. **Current.account is nil:**
   - `Account::BaseController` has `ensure_current_account` guard
   - Redirects to root with error message

### 11.3 Invitation System Updates

**Required changes:**

1. `Account::InvitationsController` (lines 5, 26, 29, 36, 56):
   - Replace `Current.user.account` with `Current.account`
   - Example: Line 5 becomes `@pending_users = Current.account.members.where(verified: false)`

2. Ensure invited users created with membership to `Current.account`:
   - Already correct at line 36: `AccountMembership.find_or_create_by!(user: user, account: Current.account)`

### 11.4 Session Management Edge Cases

**Scenarios:**

1. **User signs in from new device:**
   - New session created
   - `set_default_account` callback sets account to user's default
   - Persists across requests

2. **User switches account then signs out:**
   - Session destroyed
   - No lingering account preference (fresh start on next sign-in)

3. **Multiple browser tabs with different accounts:**
   - Not supported (session is shared across tabs)
   - Last switched account wins
   - Future enhancement: URL-based scoping via AccountMiddleware

---

## 12. Implementation Order

Recommended implementation sequence to minimize breakage:

### Phase 1: Database & Models (Foundation)
1. Run migration: Add `account_type` to accounts
2. Run migration: Add `account_id` to sessions
3. Update `Account` model (add methods, validations)
4. Update `User` model (add helper methods, keep `belongs_to :account` temporarily)
5. Update `Session` model (add association, callback)
6. Update `Current` model (add account attribute)
7. Run tests, fix model-level failures

### Phase 2: Session Management
1. Update `ApplicationController` (add `set_current_account`)
2. Create `AccountSwitchesController`
3. Add routes for account switching
4. Run tests, fix controller-level failures

### Phase 3: Registration Flow
1. Update `RegistrationsController` (account creation logic)
2. Update `Views::Registrations::New` (conditional team name field)
3. Test registration in both modes
4. Run tests, fix registration failures

### Phase 4: Refactor Current.user.account References
1. Update `Account::BaseController`
2. Update all account-scoped controllers (replace references)
3. Update all account-scoped views (replace references)
4. Update components (replace references)
5. Run tests, fix scoping failures

### Phase 5: Remove users.account_id
1. Run migration: Remove `account_id` from users
2. Remove `belongs_to :account` from User model
3. Run all tests, verify nothing breaks
4. Fix any lingering references

### Phase 6: Account Management UI
1. Create `AccountsController`
2. Create account views (index, show, new, edit)
3. Create `AccountSwitcher` component
4. Update navigation components
5. Add account switcher to navigation
6. Test account creation and switching

### Phase 7: Account Conversion
1. Create `AccountConversionsController`
2. Create conversion views
3. Add conversion routes
4. Test conversions in both directions
5. Test validation (team with multiple members)

### Phase 8: Polish & Edge Cases
1. Test all edge cases
2. Update documentation
3. Add configuration options
4. Test with different config settings
5. Final integration testing

---

## 13. Migration Path for Existing Data

**For greenfield/new projects:**
- No data migration needed
- New registrations follow new flow
- Seed data should create accounts with `account_type` set

**For existing production data (if applicable):**

1. **Backfill account types:**
   ```sql
   UPDATE accounts SET account_type = 'team' WHERE account_type IS NULL;
   ```

2. **Create memberships for existing users:**
   ```ruby
   User.find_each do |user|
     next if user.account_memberships.exists?

     AccountMembership.create!(
       user: user,
       account_id: user.account_id,
       roles: { owner: true, admin: true, member: true }
     )
   end
   ```

3. **Backfill session accounts:**
   ```ruby
   Session.where(account_id: nil).find_each do |session|
     session.update(account: session.user.default_account)
   end
   ```

4. **Remove users.account_id** (only after memberships created)

---

## 14. Configuration Reference

### 14.1 Personal Accounts Mode

**Config:**
```yaml
features:
  personal_accounts: true
accounts:
  default_account_name: "Personal"
  allow_account_creation: true
  allow_type_conversion: true
```

**Behavior:**
- Registration creates personal account automatically
- Account name field hidden in registration form
- Users can create additional team accounts via UI
- Account switcher shown in navigation
- Users can convert personal ↔ team (with validation)

### 14.2 Team-Only Mode

**Config:**
```yaml
features:
  personal_accounts: false
accounts:
  allow_account_creation: true
  allow_type_conversion: false  # Optional: disable conversion
```

**Behavior:**
- Registration requires team name input
- All accounts created as team type
- Users can create additional team accounts
- No personal accounts
- Account conversion disabled (optional)

---

## 15. Future Enhancements (Out of Scope)

1. **URL-based account scoping:**
   - Use existing `AccountMiddleware` for `/account_id/path` routing
   - Would allow different accounts in different browser tabs
   - Requires refactoring current session-based approach

2. **Account roles & permissions:**
   - Granular permissions beyond owner/admin/member
   - Custom roles per account type
   - Role-based feature access

3. **Account deletion:**
   - Soft delete with archival
   - Transfer ownership before deletion
   - Orphan prevention

4. **Account invitations improvements:**
   - Send invitations to specific account (not just current)
   - Bulk invitations
   - Invitation expiration

5. **Account settings:**
   - Per-account customization
   - Account-level feature toggles
   - Branding per account

6. **Multi-tenancy:**
   - Combine with `multi_tenant` feature flag
   - Data isolation per account
   - Subdomain routing

---

## 16. Testing Checklist

- [ ] User can sign up with personal account (personal mode)
- [ ] User can sign up with team account (team-only mode)
- [ ] User receives owner membership on account creation
- [ ] Session stores current account
- [ ] Current.account set correctly on each request
- [ ] User can switch between accounts
- [ ] Account switcher shows all user's accounts
- [ ] Account switcher indicates current account
- [ ] User can create new team account
- [ ] User can view account details
- [ ] User can edit account (admin only)
- [ ] User cannot access accounts they don't belong to
- [ ] User can convert personal → team
- [ ] User can convert team → personal (single member)
- [ ] User cannot convert team → personal (multiple members)
- [ ] Invitations scoped to Current.account
- [ ] All `Current.user.account` references replaced
- [ ] Navigation shows account switcher (multiple accounts)
- [ ] Navigation shows single account name (one account)
- [ ] Session persists account across sign out/sign in
- [ ] Edge case: User with no account handled gracefully
- [ ] Edge case: Session with deleted account handled
- [ ] Configuration toggle works (personal vs team mode)

---

## 17. Documentation Updates Required

**Files to create/update:**

1. `/docs/architecture.md`:
   - Add section on accounts system
   - Document personal vs team modes
   - Explain Current.account usage

2. `/docs/overview.md`:
   - Add link to accounts documentation
   - Update feature list

3. `README.md`:
   - Update configuration examples
   - Document account modes

4. New file: `/docs/accounts.md`:
   - Comprehensive accounts system guide
   - Configuration options
   - User flows (registration, switching, conversion)
   - Developer guide (accessing accounts, authorization)

---

## 18. Success Criteria

This implementation is considered successful when:

1. ✅ All migrations run without errors
2. ✅ All tests pass (models, controllers, integration)
3. ✅ Zero references to `Current.user.account` in codebase
4. ✅ `users.account_id` column removed
5. ✅ Registration works in both personal and team modes
6. ✅ Account switching works across all scenarios
7. ✅ Account conversion works with proper validation
8. ✅ Invitations continue to work with Current.account
9. ✅ Authorization checks use Current.account
10. ✅ Configuration toggle changes registration behavior
11. ✅ No breaking changes to existing user workflows
12. ✅ All edge cases handled gracefully

---

## Appendix A: File Checklist

**New Files:**
- `db/migrate/YYYYMMDDHHMMSS_add_account_type_to_accounts.rb`
- `db/migrate/YYYYMMDDHHMMSS_add_account_id_to_sessions.rb`
- `db/migrate/YYYYMMDDHHMMSS_remove_account_id_from_users.rb`
- `db/migrate/YYYYMMDDHHMMSS_backfill_account_types.rb`
- `app/controllers/account_switches_controller.rb`
- `app/controllers/accounts_controller.rb`
- `app/controllers/account_conversions_controller.rb`
- `app/components/account_switcher.rb`
- `app/views/accounts/index.rb`
- `app/views/accounts/show.rb`
- `app/views/accounts/new.rb`
- `app/views/accounts/edit.rb`
- `app/views/account_conversions/new.rb`
- `test/controllers/account_switches_controller_test.rb`
- `test/controllers/accounts_controller_test.rb`
- `test/controllers/account_conversions_controller_test.rb`
- `test/components/account_switcher_test.rb`
- `test/integration/account_switching_test.rb`
- `/docs/accounts.md`

**Modified Files:**
- `app/models/account.rb`
- `app/models/user.rb`
- `app/models/current.rb`
- `app/models/session.rb`
- `app/controllers/application_controller.rb`
- `app/controllers/account/base_controller.rb`
- `app/controllers/registrations_controller.rb`
- `app/controllers/account/dashboards_controller.rb`
- `app/controllers/account/invitations_controller.rb`
- `app/controllers/account/users_controller.rb`
- `app/controllers/account/settings_controller.rb`
- `app/views/registrations/new.rb`
- `app/views/account/dashboards/show.rb`
- `app/views/account/users/edit.rb`
- `app/views/account/users/show.rb`
- `app/views/account/invitations/index.rb`
- `app/components/account/user_table.rb`
- `app/components/navigation.rb`
- `app/components/sidebar_navigation.rb`
- `app/helpers/application_helper.rb`
- `lib/boilermaker/config.rb`
- `config/boilermaker.yml`
- `config/routes.rb`
- `test/models/account_test.rb`
- `test/models/user_test.rb`
- `test/controllers/registrations_controller_test.rb`
- All controller tests using `Current.user.account`

---

## Appendix B: Quick Reference

**Model Methods:**

```ruby
# Account
account.personal?           # => true/false
account.team?               # => true/false
account.convert_to_team!    # => true or raises
account.convert_to_personal! # => true or false (with validation)
account.owner               # => User or nil
account.owner?(user)        # => true/false
Account.create_personal_for(user) # => Account

# User
user.personal_account       # => Account or nil
user.team_accounts          # => ActiveRecord::Relation
user.default_account        # => Account (personal or first)
user.membership_for(account) # => AccountMembership or nil
user.account_admin_for?(account) # => true/false
user.account_owner_for?(account) # => true/false
user.can_access?(account)   # => true/false

# Current
Current.account             # => Account
Current.user                # => User
Current.session             # => Session
```

**Configuration:**

```ruby
Boilermaker.config.personal_accounts?     # => true/false
Boilermaker.config.allow_account_creation? # => true/false
Boilermaker.config.allow_type_conversion?  # => true/false
```

**Routes:**

```ruby
accounts_path                    # GET /accounts
account_path(account)            # GET /accounts/:id
new_account_path                 # GET /accounts/new
edit_account_path(account)       # GET /accounts/:id/edit
switch_account_path(account_id:) # POST /switch_account
new_account_conversion_path(account) # GET /accounts/:id/conversion/new
account_conversion_path(account)     # POST /accounts/:id/conversion
```

---

**End of Specification**
