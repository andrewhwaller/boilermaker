# Application Architecture

This document describes the architecture, design patterns, and development philosophy of Boilermaker, a modern Rails 8 application built following "The Rails Way."

## Table of Contents

1. [Technology Stack](#technology-stack)
2. [Application Architecture](#application-architecture)
3. [Key Design Patterns](#key-design-patterns)
4. [Key Concepts](#key-concepts)
5. [Development Practices](#development-practices)
6. [Related Documentation](#related-documentation)

## Technology Stack

Boilermaker is built on Rails 8 with a carefully selected set of modern technologies that embrace Rails conventions while providing a contemporary developer experience.

### Core Framework

- **Ruby on Rails 8.0.3** - Full-stack web framework
  - ActiveRecord for database interaction
  - ActionController for request handling
  - ActionMailer for email delivery
  - ActionCable for WebSockets (via Solid Cable)
  - ActiveJob for background processing (via Solid Queue)

### Database & Persistence

- **SQLite 3** - Default database for development and testing
  - Configurable for PostgreSQL/MySQL in production
  - Database-backed caching via Solid Cache
  - Simple deployment with single-file database

### Solid Adapters (Rails 8 Modern Defaults)

- **solid_cache** - Database-backed caching (replaces Redis/Memcached)
- **solid_queue** - Database-backed job queue (replaces Sidekiq/Resque)
- **solid_cable** - Database-backed WebSockets (replaces Redis for ActionCable)

These Solid adapters eliminate the need for separate infrastructure services, simplifying deployment while maintaining production-ready performance.

### View Layer

- **Phlex 2.3** - Pure Ruby view components
  - Type-safe HTML generation
  - Component-based architecture
  - No ERB or template languages
  - Full Ruby tooling support (refactoring, autocomplete, etc.)

### Frontend Stack

- **Importmap** - JavaScript module management (no Node.js required)
- **Turbo** - SPA-like experience without complex JavaScript
  - Turbo Drive for full page navigation
  - Turbo Frames for independent page sections
  - Turbo Streams for real-time updates
- **Stimulus** - Lightweight JavaScript framework for progressive enhancement
  - Organized in `/app/javascript/controllers/`
  - Connects to HTML via data attributes
  - Minimal, focused JavaScript behavior

### Styling

- **Tailwind CSS** - Utility-first CSS framework
  - Configured via `/app/assets/stylesheets/application.tailwind.css`
  - Custom 5-theme system (paper, terminal, blueprint, brutalist, dos)
  - Responsive design utilities
- **Custom Theme System** - CSS variable-based theming
  - 5 distinct visual themes with unique personalities
  - Light/dark polarity toggle within each theme
  - Theme-specific components (CommandBar, SectionMarker, FnBar, KeyboardHint)
  - Configured via `config/boilermaker.yml`

### Asset Pipeline

- **Propshaft** - Modern Rails asset pipeline
  - Simpler than Sprockets
  - Designed for HTTP/2
  - Digest-based asset fingerprinting

### Production Serving

- **Puma** - Multi-threaded web server
- **Thruster** - HTTP/2 asset caching and compression
  - X-Sendfile support
  - Automatic gzip compression
  - Asset caching headers

### Authentication & Security

- **BCrypt** - Password hashing via `has_secure_password`
- **ROTP** - Time-based One-Time Passwords (TOTP) for 2FA
- **RQRCode** - QR code generation for 2FA setup
- **Hashid Rails** - Obfuscated model IDs in URLs
- Session-based authentication (no JWT)
- Built-in CSRF protection

### Multi-Tenant Account System

- Configurable personal or team accounts
- Role-based permissions (admin, member)
- Account switching
- Invitation system
- See [accounts_system.md](accounts_system.md) for details

### Development Tools

- **Overmind** - Process manager for Procfile-based development
- **Hotwire Spark** - Live reload for development
- **Letter Opener Web** - Preview emails in browser during development
- **Debug** - Ruby debugging
- **Web Console** - Interactive console on exception pages

### Testing Tools

- **Minitest** - Default Rails testing framework
- **Capybara** - System testing (browser automation)
- **Selenium WebDriver** - Browser driver for system tests

### Code Quality

- **Brakeman** - Static security analysis
- **RuboCop Rails Omakase** - Ruby style guide enforcement

### Deployment

- **Kamal** - Docker-based deployment tool
  - Deploy anywhere with Docker
  - Zero-downtime deployments
  - Built-in SSL support

## Application Architecture

Boilermaker follows a traditional Rails MVC architecture enhanced with modern patterns for view composition and interactive behavior.

### Request Flow

The typical request lifecycle in Boilermaker:

1. **Request arrives** at Puma web server
2. **Rails routing** matches request to controller action
3. **Before actions** run (authentication, account context, theme)
4. **Controller** processes request, interacts with models
5. **Phlex component** renders response with data from controller
6. **HTML response** includes Stimulus data attributes for enhancement
7. **Client-side** Stimulus controllers attach and provide interactive behavior
8. **Turbo** intercepts form submissions and link clicks for SPA-like experience

### Directory Structure

See [file_system_structure.md](file_system_structure.md) for complete directory organization.

Key locations:

```
app/
├── components/           # Phlex UI components
│   ├── base.rb          # Base component class
│   ├── button.rb        # Reusable components
│   ├── navigation.rb
│   └── account/         # Feature-specific components
├── views/               # Phlex view classes (replaces ERB)
│   ├── layouts/
│   │   └── application.rb
│   ├── home/
│   └── registrations/
├── controllers/         # Rails controllers
│   ├── application_controller.rb
│   ├── account/         # Namespaced controllers
│   └── home_controller.rb
├── models/             # ActiveRecord models
│   ├── user.rb
│   ├── account.rb
│   └── current.rb      # Request-scoped context
├── javascript/
│   └── controllers/    # Stimulus controllers
└── assets/
    └── stylesheets/    # Tailwind CSS
```

### How Phlex Components Work

Phlex replaces ERB templates with Ruby classes that generate HTML:

**Traditional ERB (we don't use this):**
```erb
<div class="card">
  <h1><%= @user.name %></h1>
  <p><%= @user.email %></p>
</div>
```

**Phlex Component (our approach):**
```ruby
# app/components/user_card.rb
class UserCard < Components::Base
  def initialize(user:)
    @user = user
  end

  def template
    div(class: "card") do
      h1 { @user.name }
      p { @user.email }
    end
  end
end

# In controller
render UserCard.new(user: @user)
```

Benefits of Phlex:
- Full Ruby tooling (syntax checking, autocomplete, refactoring)
- Type safety through Ruby (catch errors before runtime)
- Easy component composition and reuse
- No context switching between Ruby and ERB
- Better performance (compiled Ruby, no template parsing)

### How Stimulus Enhances Behavior

Stimulus adds JavaScript behavior to Phlex-rendered HTML via data attributes:

```ruby
# Phlex component with Stimulus controller
def template
  div(data: { controller: "dropdown" }) do
    button(data: { action: "click->dropdown#toggle" }) { "Menu" }
    div(data: { dropdown_target: "menu" }, class: "hidden") do
      # Menu items
    end
  end
end
```

```javascript
// app/javascript/controllers/dropdown_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  toggle() {
    this.menuTarget.classList.toggle("hidden")
  }
}
```

Stimulus provides:
- Organized, reusable JavaScript behavior
- Clear connection between HTML and JavaScript via data attributes
- No need for jQuery or complex frameworks
- Progressive enhancement (works without JavaScript, enhanced with it)

### How Turbo Provides SPA-Like Experience

Turbo intercepts navigation and form submissions to provide fast page updates without full reloads:

**Turbo Drive** - Faster page navigation:
```ruby
# Normal link - Turbo intercepts and loads via AJAX
link_to "Dashboard", dashboard_path
# Entire page updates without full reload
```

**Turbo Frames** - Independent page sections:
```ruby
# Phlex component with Turbo Frame
turbo_frame_tag "messages" do
  @messages.each do |message|
    render MessageComponent.new(message: message)
  end
end

# Clicking links inside frame only updates that section
link_to "Next", messages_path(page: 2), data: { turbo_frame: "messages" }
```

**Turbo Streams** - Real-time updates:
```ruby
# Controller responds with Turbo Stream
def create
  @message = Message.create(message_params)
  respond_to do |format|
    format.turbo_stream # Renders create.turbo_stream.erb
  end
end

# Turbo Stream template updates specific elements
turbo_stream.append "messages", @message
```

## Key Design Patterns

Boilermaker follows Rails conventions and emphasizes simplicity over abstraction.

### The Rails Way Philosophy

**Fat Models, Skinny Controllers:**
```ruby
# GOOD - Business logic in model
class User < ApplicationRecord
  def can_convert_account_to_team?(account)
    account.owner == self && account.personal?
  end
end

# Controller stays simple
def convert_to_team
  if Current.user.can_convert_account_to_team?(@account)
    @account.convert_to_team!
    redirect_to @account, notice: "Converted to team"
  end
end

# BAD - Business logic in controller
def convert_to_team
  if @account.owner == Current.user && @account.personal?
    @account.update!(personal: false)
    # ... more logic
  end
end
```

**Convention Over Configuration:**
```ruby
# GOOD - Follow Rails naming conventions
class AccountsController < ApplicationController
  def show
    @account = Current.user.accounts.find(params[:id])
  end
end

# BAD - Fighting Rails conventions
class AccountsController < ApplicationController
  def display_account
    @account_object = Account.where(id: params[:account_id]).first
  end
end
```

**No Unnecessary Abstractions:**
```ruby
# GOOD - Direct Rails patterns
class Account < ApplicationRecord
  belongs_to :owner, class_name: "User"
  has_many :members, through: :account_memberships

  def convert_to_team!
    update!(personal: false)
  end
end

# BAD - Over-engineered service objects
class AccountConversionService
  def initialize(account, user)
    @account = account
    @user = user
  end

  def call
    return unless valid?
    AccountConverter.new(@account).convert!
  end
  # ... unnecessary abstraction
end
```

**When to Use Service Objects:**
Use service objects only when:
- Complex multi-model transactions are required
- Third-party API integration needs encapsulation
- Business logic truly doesn't belong in any single model

For most cases, models and controllers are sufficient.

### Authorization Patterns

Boilermaker uses Rails associations for authorization - the simplest and most secure approach.

**Association-Based Authorization (Recommended):**
```ruby
# GOOD - Raises RecordNotFound if user doesn't have access
@account = Current.user.accounts.find(params[:id])
# User can only find accounts they belong to

# GOOD - Scoping through associations
@posts = Current.account.posts.where(published: true)
# Only shows posts from current account
```

**Permission Checking (When Needed):**
```ruby
# Check if user is account admin
unless Current.user.account_admin_for?(Current.account)
  redirect_to root_path, alert: "Access denied"
end

# Check if user owns account
unless @account.owner == Current.user
  redirect_to root_path, alert: "Only account owner can delete"
end
```

**Controller-Level Authorization:**
```ruby
# Use before_action for consistent authorization
class Account::BaseController < ApplicationController
  before_action :require_account_admin

  private

  def require_account_admin
    unless Current.account && Current.user&.account_admin_for?(Current.account)
      redirect_to root_path, alert: "Access denied"
    end
  end
end

# Child controllers inherit authorization
class Account::UsersController < Account::BaseController
  # Automatically requires account admin
end
```

**Anti-Patterns to Avoid:**
```ruby
# BAD - Manual permission checking everywhere
def show
  @account = Account.find(params[:id])
  unless @account.members.include?(Current.user)
    redirect_to root_path, alert: "Access denied"
    return
  end
  # ... action logic
end

# BAD - Complex permission objects
class PermissionChecker
  def can_user_access_account?(user, account)
    AccountPermission.new(user, account).allowed?
  end
end
```

### View Architecture with Phlex

Phlex views are organized into components and view classes.

**Components (Reusable UI Elements):**
```ruby
# app/components/button.rb
class Button < Components::Base
  def initialize(variant: :primary, **attrs)
    @variant = variant
    super(**attrs)
  end

  def template(&block)
    button(class: button_classes, **@attrs, &block)
  end

  private

  def button_classes
    classes = "btn"
    classes += " btn-primary" if @variant == :primary
    classes += " btn-secondary" if @variant == :secondary
    classes
  end
end

# Usage in views
render Button.new(type: "submit") { "Save Changes" }
```

**View Classes (Page-Specific Views):**
```ruby
# app/views/accounts/show.rb
class Views::Accounts::Show < Views::Base
  include Phlex::Rails::Helpers::LinkTo

  def initialize(account:)
    @account = account
  end

  def template
    div(class: "container mx-auto p-4") do
      h1(class: "text-2xl font-bold") { @account.name }

      if @account.team?
        render MembersList.new(account: @account)
      end

      div(class: "mt-4") do
        link_to "Edit", edit_account_path(@account), class: "btn btn-primary"
      end
    end
  end
end

# In controller
def show
  @account = Current.user.accounts.find(params[:id])
  render Views::Accounts::Show.new(account: @account)
end
```

**Component Composition:**
```ruby
# Build complex UIs by composing components
class DashboardView < Views::Base
  def initialize(user:, recent_activity:)
    @user = user
    @recent_activity = recent_activity
  end

  def template
    div(class: "grid grid-cols-12 gap-4") do
      div(class: "col-span-8") do
        render ActivityFeed.new(activities: @recent_activity)
      end

      div(class: "col-span-4") do
        render UserCard.new(user: @user)
        render QuickActions.new
      end
    end
  end
end
```

See [phlex_architecture.md](phlex_architecture.md) for more details.

### Multi-Tenant Account System

The account system provides multi-tenancy with flexible personal and team account support.

**Account Types:**
- **Personal Accounts** - Single-user workspaces (when enabled)
- **Team Accounts** - Multi-user collaborative workspaces

**Key Models:**
```ruby
User
├── has_many :account_memberships
├── has_many :accounts (through: :account_memberships)
└── has_many :owned_accounts (as owner)

Account
├── belongs_to :owner (User)
├── has_many :account_memberships
└── has_many :members (through: :account_memberships)

AccountMembership
├── belongs_to :user
├── belongs_to :account
└── stores :roles (JSON: { "admin": true, "member": true })
```

**Request Context:**
Every request has an active account:
```ruby
# Set in ApplicationController
Current.account = Current.session.account || Current.user.accounts.first!

# Use in controllers and views
@posts = Current.account.posts
@members = Current.account.members
```

**Authorization:**
```ruby
# Check account access
Current.user.can_access?(account)  # Is user a member?

# Check admin privileges
Current.user.account_admin_for?(account)  # Has admin role?

# Check ownership
account.owner == Current.user  # Is user the owner?
```

**Scoping Data:**
```ruby
# GOOD - Always scope by account
@projects = Current.account.projects.includes(:owner)

# BAD - Not scoped to account
@projects = Project.all  # Exposes all accounts' data!
```

See [accounts_system.md](accounts_system.md) for complete documentation.

### Testing Philosophy

Boilermaker uses Minitest with a focus on real database interactions.

**No Mocking Database Calls:**
```ruby
# GOOD - Test with real database
test "creates account with membership" do
  user = users(:one)
  account = Account.create!(name: "Test Team", owner: user)

  assert account.persisted?
  assert_equal user, account.owner
end

# BAD - Mocking database
test "creates account" do
  user = users(:one)
  Account.expects(:create!).returns(mock_account)
  # ... doesn't test real behavior
end
```

**Controller Integration Tests:**
```ruby
# Test full request/response cycle
test "creates account and redirects" do
  sign_in users(:one)

  assert_difference "Account.count", 1 do
    post accounts_url, params: { account: { name: "New Team" } }
  end

  assert_redirected_to account_path(Account.last)
  assert_equal "New Team", Account.last.name
end
```

**Component Tests:**
```ruby
# Test Phlex component rendering
test "renders button component" do
  component = Button.new(variant: :primary, type: "submit")

  output = render_inline(component) { "Click me" }

  assert_includes output, "btn btn-primary"
  assert_includes output, 'type="submit"'
  assert_includes output, "Click me"
end
```

**System Tests:**
```ruby
# Test full user flows with browser
test "user switches accounts" do
  sign_in_as users(:one)

  visit accounts_path
  click_on "Team Account"

  assert_selector "h1", text: "Team Account"
  assert_current_path account_dashboard_path
end
```

**Fixtures Over Factories:**
```ruby
# test/fixtures/users.yml
one:
  email: user1@example.com
  password_digest: <%= BCrypt::Password.create('password') %>
  verified: true

# Usage in tests
test "user can sign in" do
  user = users(:one)
  post session_url, params: {
    email: user.email,
    password: 'password'
  }
  assert_redirected_to root_path
end
```

## Key Concepts

### Current Context

The `Current` class provides request-scoped attributes set by ApplicationController.

**Definition:**
```ruby
# app/models/current.rb
class Current < ActiveSupport::CurrentAttributes
  attribute :session, :account
  attribute :user_agent, :ip_address, :theme_name

  delegate :user, to: :session, allow_nil: true
end
```

**Setting Context (ApplicationController):**
```ruby
before_action :set_current_request_details
before_action :authenticate
before_action :set_current_account

def set_current_request_details
  Current.user_agent = request.user_agent
  Current.ip_address = request.ip
end

def authenticate
  if session_record = Session.find_by_id(cookies.signed[:session_token])
    Current.session = session_record
  end
end

def set_current_account
  Current.account = Current.session.account || Current.user.accounts.first!
end
```

**Using Current Context:**
```ruby
# In controllers
def index
  @posts = Current.account.posts.order(created_at: :desc)
end

# In models
class Post < ApplicationRecord
  belongs_to :author, class_name: "User"

  before_create do
    self.author = Current.user
  end
end

# In views
def template
  p { "Welcome, #{Current.user.email}!" }
end
```

**Available Attributes:**
- `Current.user` - Authenticated user (delegated from session)
- `Current.session` - Session record
- `Current.account` - Active account for request
- `Current.user_agent` - Request user agent
- `Current.ip_address` - Request IP
- `Current.theme_name` - UI theme name

### Authentication

Session-based authentication using signed cookies.

**Sign In Flow:**
```ruby
# sessions_controller.rb
def create
  if user = User.authenticate_by(email: params[:email], password: params[:password])
    @session = user.sessions.create!
    cookies.signed.permanent[:session_token] = { value: @session.id, httponly: true }
    redirect_to root_path
  else
    flash.now[:alert] = "Invalid email or password"
    render :new
  end
end
```

**Authentication Check:**
```ruby
# application_controller.rb
def authenticate
  if session_record = Session.find_by_id(cookies.signed[:session_token])
    Current.session = session_record
  else
    redirect_to sign_in_path
  end
end
```

**Two-Factor Authentication (TOTP):**
```ruby
# When 2FA is enabled
def create
  user = User.authenticate_by(email: params[:email], password: params[:password])

  if user&.otp_required?
    # Require TOTP verification
    session[:awaiting_totp_user_id] = user.id
    redirect_to totp_verification_path
  else
    # Create session normally
  end
end
```

**Email Verification:**
```ruby
# Users must verify email before full access
before_action :ensure_verified

def ensure_verified
  redirect_to identity_email_verification_path unless Current.user&.verified?
end
```

**Password Requirements:**
```ruby
# Configurable in config/boilermaker.yml
validates :password,
  allow_nil: true,
  length: { minimum: -> { Boilermaker.config.password_min_length } }
```

**Sign Out:**
```ruby
def destroy
  Current.session.destroy
  cookies.delete(:session_token)
  redirect_to sign_in_path
end
```

### Background Jobs

Background job processing using SolidQueue (database-backed).

**Job Definition:**
```ruby
# app/jobs/user_welcome_job.rb
class UserWelcomeJob < ApplicationJob
  queue_as :default

  def perform(user)
    UserMailer.with(user: user).welcome_email.deliver_now
  end
end
```

**Enqueuing Jobs:**
```ruby
# Immediate execution
UserWelcomeJob.perform_now(user)

# Background execution
UserWelcomeJob.perform_later(user)

# Scheduled execution
UserWelcomeJob.set(wait: 1.hour).perform_later(user)
```

**Mailer Jobs:**
```ruby
# Mailers automatically use background jobs
UserMailer.with(user: user).welcome_email.deliver_later

# Can specify queue and time
UserMailer.with(user: user)
  .welcome_email
  .deliver_later(wait: 10.minutes, queue: :mailers)
```

**Job Configuration:**
```ruby
# config/environments/production.rb
config.active_job.queue_adapter = :solid_queue

# All jobs use database (no Redis/Sidekiq needed)
```

### Configuration System

Application configuration via YAML files.

**Configuration File:**
```yaml
# config/boilermaker.yml
default:
  app:
    name: Boilermaker
    support_email: support@example.com
  features:
    user_registration: true
    personal_accounts: false
    two_factor_authentication: false

development:
  features:
    personal_accounts: true  # Override for development

production:
  features:
    personal_accounts: false
```

**Accessing Configuration:**
```ruby
# Check feature flags
Boilermaker.config.personal_accounts?
Boilermaker.config.user_registration?

# Get configuration values
Boilermaker.config.app_name
Boilermaker.config.support_email

# Use in conditionals
if Boilermaker.config.two_factor_authentication?
  # Show 2FA setup
end
```

**Using in Models:**
```ruby
class Session < ApplicationRecord
  before_create :set_default_account

  private

  def set_default_account
    return if account_id.present?

    if Boilermaker.config.personal_accounts?
      self.account = user.personal_account
    else
      self.account = user.accounts.first
    end
  end
end
```

## Development Practices

### Database Migrations

Follow Rails conventions for migrations.

**Creating Migrations:**
```bash
# Generate migration
rails generate migration AddRoleToUsers role:string

# Generate model with migration
rails generate model Post title:string body:text account:references

# Run migrations
rails db:migrate

# Rollback last migration
rails db:rollback
```

**Migration Best Practices:**
```ruby
# GOOD - Reversible migration
class AddPublishedToPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :posts, :published, :boolean, default: false, null: false
    add_index :posts, :published
  end
end

# GOOD - Irreversible migration with up/down
class MigrateUserData < ActiveRecord::Migration[8.0]
  def up
    User.where(role: nil).update_all(role: 'member')
  end

  def down
    # Can't reverse data migration
    raise ActiveRecord::IrreversibleMigration
  end
end

# BAD - No default value
class AddPublishedToPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :posts, :published, :boolean  # Allows NULL
  end
end
```

**Never in Development:**
- Don't run `rails db:drop` (destroys development data)
- Don't run `rails db:reset` (wipes database)
- Write additive or safely reversible migrations only

### Adding New Features

Follow this workflow when adding features:

**1. Model First (if needed):**
```bash
# Generate model with associations
rails generate model Comment post:references user:references body:text

# Add validations and methods
# app/models/comment.rb
class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :user

  validates :body, presence: true, length: { minimum: 10 }

  scope :recent, -> { order(created_at: :desc) }
end
```

**2. Controller:**
```bash
# Generate controller
rails generate controller Comments

# Implement actions
class CommentsController < ApplicationController
  def create
    @post = Current.account.posts.find(params[:post_id])
    @comment = @post.comments.build(comment_params)
    @comment.user = Current.user

    if @comment.save
      redirect_to @post, notice: "Comment added"
    else
      render :new
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end
end
```

**3. Routes:**
```ruby
# config/routes.rb
resources :posts do
  resources :comments, only: [:create, :destroy]
end
```

**4. Views (Phlex):**
```ruby
# app/views/comments/form.rb
class Views::Comments::Form < Views::Base
  include Phlex::Rails::Helpers::FormWith

  def initialize(post:, comment:)
    @post = post
    @comment = comment
  end

  def template
    form_with(model: [@post, @comment]) do |f|
      f.text_area :body, rows: 4, class: "textarea"
      f.submit "Add Comment", class: "btn btn-primary"
    end
  end
end
```

**5. Tests:**
```ruby
# test/models/comment_test.rb
test "creates comment" do
  post = posts(:one)
  comment = post.comments.create!(
    user: users(:one),
    body: "Great post!"
  )

  assert comment.persisted?
  assert_equal post, comment.post
end

# test/controllers/comments_controller_test.rb
test "creates comment and redirects" do
  sign_in users(:one)
  post = posts(:one)

  assert_difference "Comment.count", 1 do
    post post_comments_url(post), params: {
      comment: { body: "Test comment" }
    }
  end

  assert_redirected_to post
end
```

### Component Organization

Organize Phlex components by feature and reusability.

**Shared Components:**
```
app/components/
├── base.rb                    # Base component class
├── button.rb                  # Shared button
├── input.rb                   # Shared input
├── card.rb                    # Shared card layout
└── navigation.rb              # Global navigation
```

**Feature-Specific Components:**
```
app/components/
└── account/
    ├── member_card.rb         # Account member display
    ├── invitation_form.rb     # Invitation UI
    └── user_table.rb          # Member list table
```

**Component Guidelines:**
- Keep components focused and single-purpose
- Accept data via initialization, not globals
- Use composition over inheritance
- Include only needed Rails helpers
- Pass through HTML attributes with `**attrs`

### Testing Approach

Write tests for every new feature and function.

**Test Coverage Requirements:**
- Models: Business logic, validations, associations
- Controllers: Request/response, authorization, edge cases
- Components: Rendering with different data states
- System: Critical user flows end-to-end

**Test Organization:**
```
test/
├── models/
│   ├── user_test.rb
│   └── account_test.rb
├── controllers/
│   ├── accounts_controller_test.rb
│   └── sessions_controller_test.rb
├── components/
│   ├── button_test.rb
│   └── account/
│       └── member_card_test.rb
└── system/
    └── account_switching_test.rb
```

**Running Tests:**
```bash
# All tests
rails test

# Specific file
rails test test/models/user_test.rb

# Specific test
rails test test/models/user_test.rb:10

# System tests
rails test:system
```

## Related Documentation

- **[File System Structure](file_system_structure.md)** - Directory organization and conventions
- **[Accounts System](accounts_system.md)** - Multi-tenant architecture details
- **[Phlex Architecture](phlex_architecture.md)** - View layer patterns and best practices
- **[Tailwind Usage](tailwind_usage.md)** - Styling conventions and utilities
- **[UI Design Guide](UI_DESIGN_GUIDE.md)** - Design system and component library

---

This architecture prioritizes Rails conventions, simplicity, and developer productivity. When in doubt, follow The Rails Way and avoid unnecessary abstractions.
