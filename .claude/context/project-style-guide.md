---
created: 2025-08-30T20:18:02Z
last_updated: 2025-08-30T20:18:02Z
version: 1.0
author: Claude Code PM System
---

# Project Style Guide

## Code Style & Conventions

### Ruby Style Guide
Following **RuboCop Rails Omakase** configuration for consistent Ruby/Rails styling:

```ruby
# Preferred method definitions
def authenticate_user!
  redirect_to login_path unless current_user
end

# Class organization
class User < ApplicationRecord
  # Constants first
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  # Associations
  belongs_to :account
  has_many :sessions, dependent: :destroy

  # Validations
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }

  # Callbacks
  before_save :normalize_email

  # Instance methods
  private

  def normalize_email
    self.email = email.downcase.strip
  end
end
```

### File Organization Patterns

#### Directory Structure Conventions
```
app/
├── components/           # Phlex view components
│   ├── base.rb          # Base component class
│   ├── ui/              # UI-specific components
│   │   ├── button.rb    # Singular naming for components
│   │   └── form_group.rb # Snake_case for multi-word components
│   └── layouts/         # Layout components
├── models/
│   ├── concerns/        # Shared model behavior
│   │   └── account_scoped.rb # Descriptive concern names
│   └── user.rb         # Singular model names
└── mailers/
    ├── application_mailer.rb # Base classes with full name
    └── user_mailer.rb       # Domain-specific mailers
```

#### File Naming Conventions
- **Ruby Files:** `snake_case.rb`
- **Component Files:** `snake_case.rb` (e.g., `form_group.rb`, `submit_button.rb`)
- **Model Files:** Singular names (e.g., `user.rb`, `account.rb`)
- **Test Files:** `{model}_test.rb` or `{feature}_test.rb`

### Naming Conventions

#### Classes and Modules
```ruby
# Component classes - descriptive names
class FormGroup < ApplicationComponent
class SubmitButton < ApplicationComponent  
class NavigationMenu < ApplicationComponent

# Model classes - business domain names
class User < ApplicationRecord
class Account < ApplicationRecord
class RecoveryCode < ApplicationRecord

# Service classes - verb_noun pattern
class AuthenticateUser
class GenerateRecoveryCodes
class SendWelcomeEmail
```

#### Methods and Variables
```ruby
# Method names - descriptive and clear intent
def authenticate_with_password(email, password)
def generate_recovery_codes!
def current_user_can_edit?(resource)

# Variable names - clear and contextual
current_user = authenticate_user
recovery_codes = generate_backup_codes
authentication_token = SecureRandom.hex(32)

# Boolean methods - predicate naming
def authenticated?
def expired?
def account_owner?
```

#### Constants
```ruby
# Application-level constants
class ApplicationRecord < ActiveRecord::Base
  ENCRYPTION_ALGORITHM = 'AES-256-CBC'
  TOKEN_EXPIRES_IN = 24.hours
  MAX_LOGIN_ATTEMPTS = 5
end

# Component-level constants  
class FormGroup < ApplicationComponent
  DEFAULT_CSS_CLASSES = 'mb-6'
  ERROR_CSS_CLASSES = 'text-red-600 text-sm mt-1'
end
```

## Component Development Patterns

### Phlex Component Structure
```ruby
class ComponentName < ApplicationComponent
  # Constants at top
  DEFAULT_CLASSES = 'base-classes'
  
  # Initialize with clear parameter names
  def initialize(title:, content: nil, classes: DEFAULT_CLASSES, **options)
    @title = title
    @content = content
    @classes = classes
    @options = options
  end

  private

  # Clear, single-purpose methods
  def render_title
    h2(class: title_classes) { @title }
  end

  def render_content
    return unless @content
    
    div(class: content_classes) { @content }
  end

  def title_classes
    # Build classes methodically
    base_classes = 'text-xl font-semibold'
    modifier_classes = @options[:highlighted] ? ' text-blue-600' : ''
    "#{base_classes}#{modifier_classes}"
  end
end
```

### Component Usage Patterns
```ruby
# In other components - clear parameter passing
class PageLayout < ApplicationComponent
  def template
    div(class: 'container mx-auto px-4') do
      render Navigation.new(current_user: @current_user)
      
      main(class: 'py-8') do
        yield if block_given?
      end
      
      render Footer.new(year: Date.current.year)
    end
  end
end
```

## Database & Model Conventions

### Migration Style
```ruby
class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      # Required fields first
      t.string :email, null: false
      t.string :name, null: false
      
      # Optional fields
      t.string :phone
      t.text :bio
      
      # Foreign keys
      t.references :account, null: false, foreign_key: true
      
      # Rails conventions
      t.timestamps
    end
    
    # Indexes after table creation
    add_index :users, :email, unique: true
    add_index :users, [:account_id, :email], unique: true
  end
end
```

### Model Organization
```ruby
class User < ApplicationRecord
  # Include concerns early
  include AccountScoped
  
  # Constants
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  
  # Associations - belongs_to first, then has_many
  belongs_to :account
  has_many :sessions, dependent: :destroy
  has_many :recovery_codes, dependent: :destroy
  
  # Validations - group by attribute
  validates :email, presence: true, 
                   format: { with: VALID_EMAIL_REGEX },
                   uniqueness: { scope: :account_id }
  validates :name, presence: true, length: { maximum: 100 }
  
  # Callbacks - in lifecycle order
  before_validation :normalize_email
  before_save :generate_authentication_token
  
  # Scopes - descriptive names
  scope :active, -> { where(active: true) }
  scope :recent, -> { order(created_at: :desc) }
  
  # Class methods
  def self.find_by_credentials(email, password)
    # Implementation
  end
  
  # Instance methods - public first
  def full_display_name
    "#{name} (#{email})"
  end
  
  def generate_recovery_codes!
    # Implementation  
  end
  
  private
  
  # Private methods at bottom
  def normalize_email
    self.email = email&.downcase&.strip
  end
end
```

## Testing Conventions

### Test Organization
```ruby
require "test_helper"

class UserTest < ActiveSupport::TestCase
  # Setup at top
  def setup
    @account = accounts(:default)
    @user = users(:john)
  end
  
  # Group tests by functionality
  test "validates email presence" do
    user = User.new(name: "Test User")
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end
  
  test "normalizes email before saving" do
    user = User.create!(
      account: @account,
      name: "Test User", 
      email: "  TEST@EXAMPLE.COM  "
    )
    assert_equal "test@example.com", user.email
  end
  
  # Descriptive test names explaining behavior
  test "generates recovery codes when requested" do
    initial_count = @user.recovery_codes.count
    @user.generate_recovery_codes!
    
    assert_equal initial_count + 8, @user.recovery_codes.count
    assert @user.recovery_codes.all?(&:persisted?)
  end
end
```

### System Test Patterns
```ruby
require "application_system_test_case"

class AuthenticationTest < ApplicationSystemTestCase
  test "user can sign in with valid credentials" do
    # Given - clear test setup
    user = users(:john)
    
    # When - user actions
    visit login_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "password123"
    click_button "Sign In"
    
    # Then - expected outcomes
    assert_text "Welcome back, #{user.name}"
    assert_current_path dashboard_path
  end
end
```

## Styling & CSS Conventions

### Tailwind CSS Usage
```ruby
# Component styling - organized class groups
class Button < ApplicationComponent
  private
  
  def button_classes
    [
      # Layout
      'inline-flex items-center justify-center',
      # Spacing  
      'px-4 py-2',
      # Typography
      'text-sm font-medium',
      # Colors
      'bg-blue-600 text-white',
      # Interactive states
      'hover:bg-blue-700 focus:ring-2 focus:ring-blue-500',
      # Borders and effects
      'rounded-md shadow-sm',
      # Responsive
      'sm:px-6 sm:py-3'
    ].join(' ')
  end
end
```

### CSS Organization Principles
1. **Layout classes first** - Display, positioning, flexbox
2. **Spacing** - Margin, padding
3. **Typography** - Font size, weight, color
4. **Colors** - Background, text, border colors
5. **Interactive states** - Hover, focus, active
6. **Effects** - Shadows, borders, radius
7. **Responsive** - Mobile-first responsive classes

## Documentation Standards

### Code Comments
```ruby
# Only comment complex business logic or non-obvious decisions
class AuthenticationService
  # We use constant-time comparison to prevent timing attacks
  # when validating authentication tokens
  def valid_token?(provided_token, stored_token)
    ActiveSupport::SecurityUtils.secure_compare(provided_token, stored_token)
  end
  
  private
  
  # Rotate tokens after successful authentication to prevent
  # session fixation attacks
  def rotate_authentication_token!
    update!(authentication_token: SecureRandom.hex(32))
  end
end
```

### README Documentation
- **Clear setup instructions** - Step-by-step getting started
- **Feature explanations** - What each major feature does
- **Usage examples** - Code samples for common tasks  
- **Architecture overview** - High-level system design
- **Contributing guidelines** - How to contribute to the project

### API Documentation
```ruby
# Document public methods with clear examples
class User < ApplicationRecord
  # Generates 8 single-use recovery codes for account backup access
  # 
  # @return [Array<RecoveryCode>] newly created recovery codes
  # @example
  #   user.generate_recovery_codes!
  #   # => [#<RecoveryCode code="abc123">, ...]
  def generate_recovery_codes!
    # Implementation
  end
end
```