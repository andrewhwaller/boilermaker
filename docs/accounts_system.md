# Multi-Tenant Account System

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Account Types](#account-types)
4. [User Flows](#user-flows)
5. [Authorization Model](#authorization-model)
6. [Controllers & Routes](#controllers--routes)
7. [Key Models & Methods](#key-models--methods)
8. [Testing](#testing)
9. [Configuration](#configuration)

## Overview

The multi-tenant account system provides flexible organizational structures for users. It supports both **personal accounts** (individual user workspaces) and **team accounts** (shared collaborative workspaces). This system enables:

- Users to belong to multiple accounts
- Account owners to manage teams and invite members
- Seamless switching between different accounts
- Role-based permissions within accounts
- Conversion between personal and team accounts

### Why It Exists

Multi-tenancy allows a single application to serve many organizations while maintaining data isolation and appropriate access controls. Users can manage their personal work separately from team projects, and organizations can control membership and permissions.

### Key Concepts

- **Account**: A workspace that contains data and has members
- **Owner**: The user who created and owns an account
- **Member**: A user who belongs to an account
- **Membership**: The join record linking users to accounts with role permissions
- **Session**: Tied to both a user and their currently active account

## Architecture

### Data Model

```
User
├── has_many :sessions
├── has_many :account_memberships
├── has_many :accounts (through: :account_memberships)
└── has_many :owned_accounts (class_name: "Account", foreign_key: :owner_id)

Account
├── belongs_to :owner (class_name: "User")
├── has_many :account_memberships
├── has_many :members (through: :account_memberships, source: :user)
└── has_many :sessions

AccountMembership
├── belongs_to :user
├── belongs_to :account
└── stores :roles (JSON)

Session
├── belongs_to :user
└── belongs_to :account (optional: true)
```

### Database Schema

**accounts table:**
```ruby
t.string  :name, null: false
t.boolean :personal, default: false, null: false
t.integer :owner_id, null: false
t.timestamps

# Indexes
index [:owner_id]
index [:personal]

# Foreign Keys
foreign_key :users, column: :owner_id
```

**account_memberships table:**
```ruby
t.integer :user_id, null: false
t.integer :account_id, null: false
t.json    :roles, default: {}, null: false
t.timestamps

# Indexes
index [:user_id]
index [:account_id]
index [:user_id, :account_id], unique: true

# Foreign Keys
foreign_key :users
foreign_key :accounts
```

**sessions table:**
```ruby
t.integer :user_id, null: false
t.integer :account_id
t.string  :user_agent
t.string  :ip_address
t.timestamps

# Indexes
index [:user_id]
index [:account_id]
index [:user_id, :account_id]

# Foreign Keys
foreign_key :users
foreign_key :accounts
```

### Current Context

The application uses `Current` (ActiveSupport::CurrentAttributes) to maintain request-scoped context:

```ruby
# app/models/current.rb
class Current < ActiveSupport::CurrentAttributes
  attribute :session, :account
  attribute :user_agent, :ip_address, :theme_name

  delegate :user, to: :session, allow_nil: true
end
```

Within any request:
- `Current.user` - The authenticated user
- `Current.account` - The active account for this session
- `Current.session` - The session record

## Account Types

### Personal Accounts

**Characteristics:**
- One owner, one member (the owner)
- Created automatically during user registration when `personal_accounts: true`
- Intended for individual work
- Can be converted to team accounts
- Named "Personal" by default

**When to use:**
- Individual user workspaces
- Personal projects
- Solo development

**Configuration:**
```yaml
# config/boilermaker.yml
features:
  personal_accounts: true
```

### Team Accounts

**Characteristics:**
- One owner, multiple members
- Created explicitly by users or during registration when `personal_accounts: false`
- Supports invitations and role-based permissions
- Can be converted back to personal (if only one member remains)
- Named "{email}'s Team" by default or custom name

**When to use:**
- Organizations
- Collaborative projects
- Multi-user workspaces

**Configuration:**
```yaml
# config/boilermaker.yml
features:
  personal_accounts: false
```

## User Flows

### Registration Flow

When a user registers, an account is automatically created based on configuration:

**With personal_accounts enabled:**
```ruby
# 1. User signs up
user = User.create!(email: "user@example.com", password: "password")

# 2. Personal account is created
account = Account.create!(
  name: "Personal",
  personal: true,
  owner: user
)

# 3. Membership is created with admin privileges
AccountMembership.create!(
  user: user,
  account: account,
  roles: { "admin" => true, "member" => true }
)

# 4. Session is created with account
session = user.sessions.create!(account: account)
```

**With personal_accounts disabled:**
```ruby
# Team account is created instead
account = Account.create!(
  name: "#{user.email}'s Team",
  personal: false,
  owner: user
)
# ... rest is the same
```

### Account Switching Flow

Users can switch between accounts they belong to:

```ruby
# 1. User requests to switch accounts
# POST /account_switches
# params: { account_id: "abc123" }

# 2. Controller validates access
account = Current.user.accounts.find_by!(id: params[:account_id])

# 3. Session is updated
Current.session.update!(account: account)

# 4. User is redirected and now operates in new account context
```

### Team Invitation Flow

Account admins can invite new members:

```ruby
# 1. Admin invites user by email
# POST /account/invitations
# params: { email: "newuser@example.com", message: "Join our team!" }

# 2. System finds or creates user
user = User.find_or_initialize_by(email: email)
if user.new_record?
  user.password = SecureRandom.base58
  user.verified = false
  user.save!
end

# 3. Membership is created
AccountMembership.create!(
  user: user,
  account: Current.account,
  roles: { "member" => true, "admin" => false }
)

# 4. Invitation email is sent
UserMailer.with(user: user, inviter: Current.user, message: message)
  .invitation_instructions
  .deliver_later

# 5. User receives email with password reset link
# 6. User sets password and verifies email
# 7. User can now access the account
```

### Account Conversion Flow

Owners can convert between personal and team accounts:

**Personal to Team:**
```ruby
# Preconditions:
# - Account must be personal
# - User must be the owner

account.convert_to_team!
# Now the owner can invite additional members
```

**Team to Personal:**
```ruby
# Preconditions:
# - Account must be team
# - User must be the owner
# - Account must have exactly one membership (the owner)

# First remove all other members
account.account_memberships.where.not(user: owner).destroy_all

# Then convert
account.convert_to_personal!
```

## Authorization Model

### Ownership

Every account has exactly one owner (`account.owner_id`). The owner:
- Created the account
- Can edit account settings
- Can delete the account
- Can convert between personal/team types
- Can invite and remove members
- Has implicit admin privileges

### Membership Roles

Roles are stored as JSON in `account_memberships.roles`:

```ruby
{
  "admin" => true,   # Can manage account and members
  "member" => true   # Can access account data
}
```

**Available roles:**
- `admin` - Account administration privileges
- `member` - Basic account access

### Permission Checking

**Check if user can access account:**
```ruby
Current.user.can_access?(account)
# Returns true if user is a member
```

**Check if user is account admin:**
```ruby
Current.user.account_admin_for?(account)
# Returns true if:
# - User is app-level admin (app_admin: true), OR
# - User has admin: true in their membership roles
```

**Get user's membership:**
```ruby
membership = Current.user.membership_for(account)
membership.admin?  # => true/false
membership.member? # => true/false
```

**Check if user owns account:**
```ruby
account.owner == Current.user
```

### App-Level Admins

Users with `app_admin: true` have superuser privileges:
- Implicit admin access to all accounts
- Can masquerade as other users
- Access to admin dashboard
- Bypass account-level permission checks

### Controller Authorization

**Account-scoped controllers** inherit from `Account::BaseController`:

```ruby
# app/controllers/account/base_controller.rb
class Account::BaseController < ApplicationController
  before_action :require_account_admin

  private

  def require_account_admin
    unless Current.account && Current.user&.account_admin_for?(Current.account)
      redirect_to root_path, alert: "Access denied. Admin privileges required."
    end
  end
end
```

This ensures only account admins can:
- Manage account settings
- Invite/remove members
- View member lists
- Configure account preferences

## Controllers & Routes

### AccountsController

Manages user's account list and team account CRUD operations.

**Routes:**
```ruby
GET    /accounts           # index  - List user's accounts
GET    /accounts/new       # new    - Team creation form
POST   /accounts           # create - Create new team
GET    /accounts/:id       # show   - View account details
GET    /accounts/:id/edit  # edit   - Edit account (owner only)
PATCH  /accounts/:id       # update - Update account (owner only)
DELETE /accounts/:id       # destroy - Delete account (owner only)
```

**Key actions:**

**index** - Lists all accounts user belongs to:
```ruby
def index
  @personal_accounts = Current.user.accounts.personal.order(:name)
  @team_accounts = Current.user.accounts.team.order(:name)
end
```

**create** - Creates new team account:
```ruby
def create
  @account = Account.new(account_params)
  @account.personal = false  # Always team
  @account.owner = Current.user

  if @account.save
    # Create admin membership
    Current.user.account_memberships.create!(
      account: @account,
      roles: { "admin" => true, "member" => true }
    )
    redirect_to @account
  end
end
```

### AccountSwitchesController

Handles switching between accounts.

**Routes:**
```ruby
POST /account_switches  # create - Switch to different account
```

**create** - Switches session to different account:
```ruby
def create
  account = Current.user.accounts.find_by!(id: params[:account_id])
  Current.session.update!(account: account)
  redirect_to root_path, notice: "Switched to #{account.name}"
end
```

### AccountConversionsController

Handles conversion between personal and team accounts.

**Routes:**
```ruby
POST /accounts/:account_id/convert_to_team     # to_team - Convert personal to team
POST /accounts/:account_id/convert_to_personal # to_personal - Convert team to personal
```

**to_team** - Converts personal account to team:
```ruby
def to_team
  if @account.can_convert_to_team?(Current.user)
    @account.convert_to_team!
    redirect_to @account, notice: "Converted to team account. You can now invite members."
  else
    redirect_to @account, alert: "Cannot convert this account to a team."
  end
end
```

**to_personal** - Converts team account to personal:
```ruby
def to_personal
  if @account.can_convert_to_personal?(Current.user)
    @account.convert_to_personal!
    redirect_to @account, notice: "Converted to personal account."
  else
    redirect_to @account, alert: "Cannot convert: remove other members first."
  end
end
```

### Account::BaseController

Base controller for account-scoped admin actions.

**Purpose:** Enforces admin-only access for account management.

**Before actions:**
- `require_account_admin` - Ensures user has admin privileges for `Current.account`

**Child controllers:**
- `Account::DashboardsController`
- `Account::UsersController`
- `Account::InvitationsController`
- `Account::SettingsController`

### Account::InvitationsController

Manages team member invitations (admin only).

**Routes:**
```ruby
GET    /account/invitations     # index   - List pending invitations
GET    /account/invitations/new # new     - Invitation form
POST   /account/invitations     # create  - Send invitation
DELETE /account/invitations/:id # destroy - Cancel invitation
```

**create** - Invites user by email:
```ruby
def create
  email = params[:email]&.strip&.downcase

  # Find or create user
  user = User.find_or_initialize_by(email: email)
  if user.new_record?
    user.password = SecureRandom.base58
    user.verified = false
    user.save!
  end

  # Create membership
  membership = AccountMembership.find_or_create_by!(
    user: user,
    account: Current.account
  )
  membership.update!(roles: { "member" => true, "admin" => false })

  # Send invitation
  send_invitation_instructions(user, params[:message])
end
```

### Account Namespace Routes

**Dashboard:**
```ruby
GET   /account       # account/dashboards#show   - Account dashboard
PATCH /account       # account/dashboards#update - Update account
```

**Users (Admin only):**
```ruby
GET    /account/users          # index   - List account members
GET    /account/users/:id      # show    - View member details
GET    /account/users/:id/edit # edit    - Edit member roles
PATCH  /account/users/:id      # update  - Update member roles
DELETE /account/users/:id      # destroy - Remove member
```

**Settings (Admin only):**
```ruby
GET   /account/settings      # show   - View account settings
GET   /account/settings/edit # edit   - Edit settings form
PATCH /account/settings      # update - Update settings
```

## Key Models & Methods

### Account Model

**Associations:**
```ruby
belongs_to :owner, class_name: "User"
has_many :account_memberships, dependent: :destroy
has_many :members, through: :account_memberships, source: :user
has_many :sessions, dependent: :nullify
```

**Validations:**
```ruby
validates :name, presence: true
validates :personal, inclusion: { in: [true, false] }
validates :owner, presence: true
```

**Scopes:**
```ruby
Account.personal  # => Returns personal accounts
Account.team      # => Returns team accounts
```

**Instance Methods:**

`personal?` / `team?`
```ruby
account.personal? # => true if personal account
account.team?     # => true if team account
```

`can_convert_to_team?(user)`
```ruby
# Returns true if:
# - Account is personal
# - User is the owner
account.can_convert_to_team?(current_user)
```

`can_convert_to_personal?(user)`
```ruby
# Returns true if:
# - Account is team
# - User is the owner
# - Account has exactly 1 member
account.can_convert_to_personal?(current_user)
```

`convert_to_team!`
```ruby
# Converts personal account to team
# Raises if already a team account
account.convert_to_team!
```

`convert_to_personal!`
```ruby
# Converts team account to personal
# Raises if already personal or has multiple members
account.convert_to_personal!
```

### User Model

**Associations:**
```ruby
has_many :sessions, dependent: :destroy
has_many :account_memberships, dependent: :destroy
has_many :accounts, through: :account_memberships
has_many :owned_accounts, class_name: "Account", foreign_key: :owner_id, dependent: :destroy
```

**Account-Related Methods:**

`personal_account`
```ruby
# Returns user's personal account (if personal_accounts enabled)
# Returns nil if feature disabled or no personal account exists
user.personal_account
```

`can_access?(account)`
```ruby
# Returns true if user is a member of the account
user.can_access?(account)
```

`membership_for(account)`
```ruby
# Returns AccountMembership record for the account
# Returns nil if not a member
membership = user.membership_for(account)
```

`account_admin_for?(account)`
```ruby
# Returns true if:
# - User is app-level admin (app_admin: true), OR
# - User has admin role in account membership
user.account_admin_for?(account)
```

`app_admin?`
```ruby
# Returns true if user has app-level admin privileges
user.app_admin?
```

### AccountMembership Model

**Associations:**
```ruby
belongs_to :user
belongs_to :account
```

**Constants:**
```ruby
ROLE_KEYS = %w[admin member].freeze
```

**Validations:**
```ruby
validate :validate_roles_shape
# Ensures roles is a Hash with valid keys and boolean values
```

**Scopes:**
```ruby
AccountMembership.for_account(account)
AccountMembership.for_user(user)
AccountMembership.with_role(:admin, true)  # Find memberships with specific role
AccountMembership.with_role(:member, false) # Find memberships without role
```

**Instance Methods:**

`role?(key)`
```ruby
# Check if membership has specific role
membership.role?(:admin)  # => true/false
membership.role?(:member) # => true/false
```

`admin?` / `member?`
```ruby
# Convenience methods for checking roles
membership.admin?  # => true if roles['admin'] == true
membership.member? # => true if roles['member'] == true
```

`grant!(key)`
```ruby
# Grants role to membership
membership.grant!(:admin)
# Updates: roles: { "admin" => true, ... }
```

`revoke!(key)`
```ruby
# Revokes role from membership
membership.revoke!(:admin)
# Updates: roles: { "admin" => false, ... }
```

### Session Model

**Associations:**
```ruby
belongs_to :user
belongs_to :account, optional: true
```

**Callbacks:**
```ruby
before_create :set_default_account

# Sets account to user's personal account if:
# - account_id is not already set
# - personal_accounts feature is enabled
```

### ApplicationController

**Account-Related Filters:**

`set_current_account`
```ruby
# Before action that sets Current.account
# Uses session.account or falls back to user's first account
def set_current_account
  return unless Current.session
  Current.account = Current.session.account || Current.user.accounts.first!
end
```

This ensures every request has an active account context.

## Testing

### Testing Account Creation

```ruby
# test/models/account_test.rb
test "creates personal account" do
  user = users(:one)
  account = Account.create!(
    name: "Personal",
    personal: true,
    owner: user
  )

  assert account.personal?
  assert_equal user, account.owner
end

test "creates team account" do
  user = users(:one)
  account = Account.create!(
    name: "My Team",
    personal: false,
    owner: user
  )

  assert account.team?
  assert_equal user, account.owner
end
```

### Testing Account Conversion

```ruby
test "converts personal to team" do
  account = accounts(:personal_one)
  user = account.owner

  assert account.can_convert_to_team?(user)
  account.convert_to_team!

  assert account.team?
  refute account.personal?
end

test "converts team to personal when single member" do
  account = accounts(:team_one)
  user = account.owner

  # Ensure only one member
  account.account_memberships.where.not(user: user).destroy_all

  assert account.can_convert_to_personal?(user)
  account.convert_to_personal!

  assert account.personal?
  refute account.team?
end

test "cannot convert team to personal with multiple members" do
  account = accounts(:team_one)
  user = account.owner

  # Create additional member
  other_user = users(:two)
  AccountMembership.create!(
    user: other_user,
    account: account,
    roles: { "member" => true }
  )

  refute account.can_convert_to_personal?(user)

  assert_raises(RuntimeError) do
    account.convert_to_personal!
  end
end
```

### Testing Account Switching

```ruby
# test/controllers/account_switches_controller_test.rb
test "switches to different account" do
  sign_in users(:one)
  other_account = accounts(:team_one)

  # Ensure user is member
  AccountMembership.create!(
    user: users(:one),
    account: other_account,
    roles: { "member" => true }
  )

  post account_switches_url, params: { account_id: other_account.id }

  assert_redirected_to root_path
  assert_equal other_account, @controller.send(:Current).session.account
end

test "cannot switch to account user is not member of" do
  sign_in users(:one)
  other_account = accounts(:team_two)

  assert_raises(ActiveRecord::RecordNotFound) do
    post account_switches_url, params: { account_id: other_account.id }
  end
end
```

### Testing Invitations

```ruby
# test/controllers/account/invitations_controller_test.rb
test "invites new user to account" do
  sign_in users(:admin)
  account = accounts(:team_one)
  Current.session.update!(account: account)

  assert_difference "User.count", 1 do
    assert_difference "AccountMembership.count", 1 do
      post account_invitations_url, params: {
        email: "newuser@example.com",
        message: "Join us!"
      }
    end
  end

  new_user = User.find_by(email: "newuser@example.com")
  assert_not new_user.verified?
  assert account.members.include?(new_user)

  membership = new_user.membership_for(account)
  assert membership.member?
  refute membership.admin?
end

test "invites existing user to account" do
  sign_in users(:admin)
  account = accounts(:team_one)
  Current.session.update!(account: account)
  existing_user = users(:two)

  assert_no_difference "User.count" do
    assert_difference "AccountMembership.count", 1 do
      post account_invitations_url, params: {
        email: existing_user.email
      }
    end
  end

  assert account.members.include?(existing_user)
end
```

### Testing Authorization

```ruby
# test/models/user_test.rb
test "can_access? returns true for member" do
  user = users(:one)
  account = accounts(:team_one)

  AccountMembership.create!(
    user: user,
    account: account,
    roles: { "member" => true }
  )

  assert user.can_access?(account)
end

test "can_access? returns false for non-member" do
  user = users(:one)
  account = accounts(:team_two)

  refute user.can_access?(account)
end

test "account_admin_for? returns true for admin" do
  user = users(:one)
  account = accounts(:team_one)

  AccountMembership.create!(
    user: user,
    account: account,
    roles: { "admin" => true, "member" => true }
  )

  assert user.account_admin_for?(account)
end

test "account_admin_for? returns true for app admin" do
  user = users(:app_admin)
  account = accounts(:team_one)

  assert user.app_admin?
  assert user.account_admin_for?(account)
end
```

### Test Fixtures

```yaml
# test/fixtures/accounts.yml
personal_one:
  name: Personal
  personal: true
  owner: one

team_one:
  name: Team Alpha
  personal: false
  owner: admin

team_two:
  name: Team Beta
  personal: false
  owner: two

# test/fixtures/account_memberships.yml
one_in_personal:
  user: one
  account: personal_one
  roles: { "admin": true, "member": true }

admin_in_team_one:
  user: admin
  account: team_one
  roles: { "admin": true, "member": true }

one_in_team_one:
  user: one
  account: team_one
  roles: { "member": true, "admin": false }

# test/fixtures/users.yml
one:
  email: user1@example.com
  password_digest: <%= BCrypt::Password.create('password') %>
  verified: true
  app_admin: false

admin:
  email: admin@example.com
  password_digest: <%= BCrypt::Password.create('password') %>
  verified: true
  app_admin: false

app_admin:
  email: superadmin@example.com
  password_digest: <%= BCrypt::Password.create('password') %>
  verified: true
  app_admin: true
```

### Test Helpers

```ruby
# test/test_helper.rb

# Sign in as user with account context
def sign_in_with_account(user, account)
  session = user.sessions.create!(account: account)
  cookies.signed[:session_token] = session.id
  Current.session = session
  Current.account = account
end

# Create account with membership
def create_account_with_membership(user:, name:, personal: false, admin: true)
  account = Account.create!(name: name, personal: personal, owner: user)
  AccountMembership.create!(
    user: user,
    account: account,
    roles: { "admin" => admin, "member" => true }
  )
  account
end
```

## Configuration

### Boilermaker Config

```yaml
# config/boilermaker.yml
default:
  features:
    personal_accounts: false  # Use team accounts by default

development:
  features:
    personal_accounts: true   # Enable personal accounts in dev

production:
  features:
    personal_accounts: false  # Use team accounts in production
```

### Accessing Configuration

```ruby
# Check if personal accounts are enabled
Boilermaker.config.personal_accounts?
# => true/false

# This affects:
# - Registration flow (creates personal vs team account)
# - Session default account selection
# - User#personal_account method availability
```

### Feature Flags Impact

**When `personal_accounts: true`:**
- New users get a personal account named "Personal"
- `User#personal_account` returns the user's personal account
- Sessions default to personal account
- Users can still create additional team accounts
- Personal accounts can be converted to teams

**When `personal_accounts: false`:**
- New users get a team account named "{email}'s Team"
- `User#personal_account` returns `nil`
- Sessions default to first available account
- All accounts are teams by default
- Teams can be converted to personal (if single member)

### Migration Considerations

**Adding accounts to existing application:**

1. Run migrations to create tables
2. Create accounts for existing users:
```ruby
# db/seeds.rb or migration
User.find_each do |user|
  account = Account.create!(
    name: Boilermaker.config.personal_accounts? ? "Personal" : "#{user.email}'s Team",
    personal: Boilermaker.config.personal_accounts?,
    owner: user
  )

  AccountMembership.create!(
    user: user,
    account: account,
    roles: { "admin" => true, "member" => true }
  )

  # Update existing sessions
  user.sessions.update_all(account_id: account.id)
end
```

### Security Considerations

**Data Isolation:**
- Always scope queries by `Current.account` for account-scoped data
- Use `Account::BaseController` for admin-only actions
- Verify account membership before allowing access

**Example of properly scoped query:**
```ruby
# Good - scoped to current account
@posts = Current.account.posts.order(created_at: :desc)

# Bad - not scoped, exposes all posts
@posts = Post.order(created_at: :desc)
```

**Owner vs Admin:**
- Use `account.owner == user` for owner-only actions (delete, convert)
- Use `user.account_admin_for?(account)` for admin actions (invite, settings)
- App admins bypass account-level checks

### Performance Tips

**Eager Loading:**
```ruby
# Load accounts with owner and members
accounts = Account.includes(:owner, :members)

# Load user with accounts and memberships
user = User.includes(account_memberships: :account).find(id)
```

**Counter Caches:**
```ruby
# Add to accounts table
add_column :accounts, :members_count, :integer, default: 0

# Update Account model
has_many :account_memberships, dependent: :destroy, counter_cache: :members_count
```

**Database Indexes:**
Ensure these indexes exist (they should from migrations):
- `accounts(owner_id)` - Fast owner lookups
- `accounts(personal)` - Fast personal/team filtering
- `account_memberships(user_id, account_id)` - Unique constraint and fast lookups
- `sessions(user_id, account_id)` - Fast session queries

---

## Related Documentation

- [Architecture](architecture.md) - Application architecture and patterns
- [File System Structure](file_system_structure.md) - Project organization
- [Authentication System](authentication.md) - User authentication (if exists)
- [Authorization](authorization.md) - Permission system (if exists)
