# Phlex Shared Components

This document describes the shared Phlex components that provide reusable patterns and eliminate code duplication across views.

## Overview

Shared components extract common UI patterns into reusable, composable pieces. They leverage the Phlex Kit system for clean syntax and provide consistent behavior across the application.

## Form Components

### FormGroup

A foundational component that combines label, input, and optional help text with consistent spacing.

```ruby
FormGroup(
  label_text: "Email Address",
  input_type: :email,
  name: "user[email]",
  id: "user_email",
  required: true,
  help_text: "We'll never share your email"
)
```

**Parameters:**
- `label_text` (required) - Text for the label
- `input_type` - Type of input (default: `:text`)
- `name` (required) - Input name attribute
- `id` - Input ID (auto-generated from name if not provided)
- `required` - Whether field is required (default: `false`)
- `help_text` - Optional help text displayed below input
- Additional attributes passed to the input

### EmailField

A specialized form group for email inputs with proper validation and autocomplete.

```ruby
EmailField(
  name: "user[email]",
  value: user.email,
  autofocus: true
)

# With custom label
EmailField(
  label_text: "Email Address",
  name: "email",
  placeholder: "Enter your email"
)
```

**Parameters:**
- `label_text` - Label text (default: "Email")
- `name` - Input name (default: "email")
- `id` - Input ID (auto-generated if not provided)
- `required` - Whether required (default: `true`)
- Additional input attributes

### PasswordField

A specialized form group for password inputs with smart autocomplete detection.

```ruby
# Basic password field
PasswordField(
  label_text: "Password",
  name: "user[password]"
)

# With help text
PasswordField(
  label_text: "New Password",
  name: "user[password]",
  help_text: "Must be at least 12 characters"
)

# Password confirmation
PasswordField(
  label_text: "Confirm Password",
  name: "user[password_confirmation]"
)
```

**Smart Autocomplete Detection:**
- `current.*password|password_challenge` → `"current-password"`
- `new.*password|password(?!.*confirmation)` → `"new-password"`
- `password.*confirmation|confirm.*password` → `"new-password"`

**Parameters:**
- `label_text` (required) - Label text
- `name` (required) - Input name
- `id` - Input ID (auto-generated if not provided)
- `required` - Whether required (default: `false`)
- `autocomplete` - Override auto-detection
- `help_text` - Optional help text
- Additional input attributes

### SubmitButton

A specialized button component for form submissions with consistent styling.

```ruby
# Basic submit button
SubmitButton("Save Changes")

# With custom variant
SubmitButton("Delete Account", variant: :destructive)

# With block content
SubmitButton(variant: :primary) do
  "Create Account"
end
```

**Parameters:**
- `text` - Button text (default: "Submit")
- `variant` - Button variant (default: `:primary`)
- Additional button attributes

## Layout Components

### FormCard

A wrapper component for consistent form presentation with optional title.

```ruby
FormCard(title: "Sign In") do
  # Form content here
end

# Without title
FormCard do
  # Form content here
end
```

**Parameters:**
- `title` - Optional card title
- Additional card attributes

### FormSection

A component for grouping related form elements with optional section titles.

```ruby
FormSection(title: "Account Information") do
  EmailField(name: "user[email]")
  PasswordField(label_text: "Password", name: "user[password]")
end

FormSection(
  title: "Profile Details",
  description: "This information will be displayed publicly"
) do
  # Form fields here
end
```

**Parameters:**
- `title` - Optional section title
- `description` - Optional section description
- Additional section attributes

## Navigation Components

### AuthLinks

A component for authentication-related navigation links with consistent styling.

```ruby
# Multiple links with separator
AuthLinks(links: [
  { text: "Sign up", path: sign_up_path },
  { text: "Forgot password?", path: new_password_reset_path }
])

# Single link
AuthLinks(links: [
  { text: "Already have an account? Sign in", path: sign_in_path }
])

# Custom separator and alignment
AuthLinks(
  links: links_array,
  separator: "•",
  center: false
)
```

**Parameters:**
- `links` - Array of link hashes with `:text` and `:path` keys
- `separator` - Text between links (default: "|")
- `center` - Whether to center align (default: `true`)

## Display Components

### RecoveryCodeItem

A component for displaying recovery codes with appropriate styling for used/unused states.

```ruby
RecoveryCodeItem(code: "ABC123", used: false)
RecoveryCodeItem(code: "DEF456", used: true)
```

**Parameters:**
- `code` (required) - The recovery code string
- `used` - Whether the code has been used (default: `false`)

## Usage Patterns

### Authentication Forms

Before (repetitive code):
```ruby
div do
  render Components::Label.new(for_id: "email", required: true) { "Email" }
  render Components::Input.new(
    type: :email,
    name: "email",
    id: "email",
    required: true,
    autocomplete: "email"
  )
end

div do
  render Components::Label.new(for_id: "password", required: true) { "Password" }
  render Components::Input.new(
    type: :password,
    name: "password",
    id: "password",
    required: true,
    autocomplete: "current-password"
  )
end

div do
  render Components::Button.new(type: "submit", variant: :primary) { "Sign in" }
end
```

After (using shared components):
```ruby
EmailField(name: "email", autofocus: true)
PasswordField(label_text: "Password", name: "password")
SubmitButton("Sign in")
```

### Complete Form Example

```ruby
class Views::Sessions::New < Views::Base
  def view_template
    page_with_title("Sign in") do
      centered_container do
        FormCard(title: "Sign in") do
          form_with(url: sign_in_path, class: "space-y-4") do |form|
            EmailField(name: :email, value: @email_hint, autofocus: true)
            PasswordField(label_text: "Password", name: :password)
            SubmitButton("Sign in")
          end

          AuthLinks(links: [
            { text: "Sign up", path: sign_up_path },
            { text: "Forgot password?", path: new_password_reset_path }
          ])
        end
      end
    end
  end
end
```

## Benefits

### Code Reduction
- **Before**: 15-20 lines per form field
- **After**: 1-2 lines per form field
- **Reduction**: ~85% less code for common patterns

### Consistency
- Automatic proper autocomplete attributes
- Consistent spacing and styling
- Standardized accessibility attributes
- Uniform error handling

### Maintainability
- Single source of truth for form patterns
- Easy to update styling across entire application
- Centralized accessibility improvements
- Simplified testing

### Developer Experience
- Clean, readable view code
- Self-documenting component names
- Reduced cognitive load
- Faster development

## Testing Shared Components

```ruby
# test/components/form_group_test.rb
require "test_helper"

class Components::FormGroupTest < ActiveSupport::TestCase
  def test_renders_label_and_input
    component = Components::FormGroup.new(
      label_text: "Email",
      name: "email",
      input_type: :email
    )
    
    # Test component creation
    assert_instance_of Components::FormGroup, component
  end

  def test_generates_id_from_name
    component = Components::FormGroup.new(
      label_text: "Email",
      name: "user[email]"
    )
    
    # Should generate ID as "user_email"
    assert_equal "user_email", component.instance_variable_get(:@id)
  end
end
```

## Migration Strategy

1. **Identify Patterns**: Look for repeated label + input combinations
2. **Replace Gradually**: Update one view at a time
3. **Test Thoroughly**: Ensure functionality remains identical
4. **Measure Impact**: Track code reduction and consistency improvements

## Best Practices

1. **Use Semantic Components**: Choose `EmailField` over generic `FormGroup` when appropriate
2. **Leverage Defaults**: Components provide sensible defaults for common use cases
3. **Compose Thoughtfully**: Combine shared components for complex patterns
4. **Test in Isolation**: Each shared component should work independently
5. **Document Patterns**: Update this guide when creating new shared components

This shared component system significantly reduces code duplication while improving consistency and maintainability across the application.