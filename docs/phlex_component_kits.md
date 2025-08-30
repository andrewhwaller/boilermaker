# Phlex Component Kits

This document describes the reusable Phlex component system available in the Boilermaker application using Phlex's built-in Kit functionality.

## Overview

The Boilermaker application uses Phlex's built-in Kit system to provide clean, organized access to UI components. This system allows for elegant component composition without the need for explicit `render` calls or `.new` instantiation.

## The Components Kit

### Main Kit Module

The main `Components` module is defined as a Phlex Kit:

```ruby
# app/components.rb
module Components
  extend Phlex::Kit
end
```

This automatically makes all components in the `Components::` namespace available through the kit's clean syntax.

### Available Components

#### Form Components
- `Components::Button` - Styled buttons with variants
- `Components::Input` - Form inputs with consistent styling
- `Components::Label` - Form labels with required field indicators
- `Components::FormField` - Combined label + input component

#### Navigation Components
- `Components::Navigation` - Main navigation bar
- `Components::DropdownMenu` - Dropdown menu container
- `Components::DropdownMenuItem` - Individual dropdown menu items
- `Components::DropdownMenuSeparator` - Visual separators in dropdown menus

#### Utility Components
- `Components::Base` - Base class for all components
- `Components::ExampleCard` - Example component demonstrating kit usage

## Using the Kit System

### Clean Component Syntax

With the Phlex Kit system, you can render components using clean, capital-letter method calls:

```ruby
class Views::SomeView < Views::Base
  def view_template
    # Clean kit syntax - no render or .new needed
    Button(variant: :primary, type: :submit) { "Save Changes" }
    
    # Form field with kit syntax
    FormField(
      label_text: "Email Address",
      input_type: :email,
      name: "user[email]",
      required: true,
      placeholder: "Enter your email"
    )
    
    # Navigation component
    Navigation()
    
    # Dropdown menu
    DropdownMenu(trigger_text: "Account") do
      DropdownMenuItem("Settings", settings_path)
      DropdownMenuSeparator()
      DropdownMenuItem("Sign out", session_path, method: :delete)
    end
  end
end
```

### Traditional Syntax (Still Available)

You can still use the traditional `render` syntax if preferred:

```ruby
class Views::SomeView < Views::Base
  def view_template
    render Components::Button.new(variant: :primary) { "Save Changes" }
    render Components::FormField.new(
      label_text: "Email Address",
      input_type: :email,
      name: "user[email]",
      required: true
    )
  end
end
```

### Kit Inclusion

The `Components` kit is automatically included in:
- `Components::Base` - Making it available to all components
- `Views::Base` - Making it available to all views (through inheritance from `Components::Base`)

This means any component or view can use the clean kit syntax without additional setup.

## Component Architecture

### Base Component

All components inherit from `Components::Base`:

```ruby
class Components::Base < Phlex::HTML
  # Include the Components kit for clean component rendering
  include Components
  
  # Include Rails helpers
  include Phlex::Rails::Helpers::Routes

  # Development debugging
  if Rails.env.development?
    def before_template
      comment { "Before #{self.class.name}" }
      super
    end
  end
end
```

### Button Component

The Button component supports multiple variants:

```ruby
# Available variants
Button(variant: :primary) { "Primary" }      # Default blue button
Button(variant: :secondary) { "Secondary" }  # Gray button
Button(variant: :destructive) { "Delete" }   # Red button
Button(variant: :outline) { "Outline" }      # Outlined button
Button(variant: :ghost) { "Ghost" }          # Minimal button
Button(variant: :link) { "Link" }            # Link-styled button

# With different types
Button(type: :submit, variant: :primary) { "Submit Form" }
Button(type: :button, variant: :secondary) { "Cancel" }
```

### Form Components

Form components work together seamlessly:

```ruby
# Individual components
Label(for_id: "email", text: "Email Address", required: true)
Input(type: :email, id: "email", name: "user[email]", required: true)

# Combined form field (recommended)
FormField(
  label_text: "Email Address",
  input_type: :email,
  name: "user[email]",
  required: true,
  placeholder: "Enter your email"
)
```

### Navigation Components

Navigation components provide consistent navigation patterns:

```ruby
# Main navigation (handles auth states automatically)
Navigation()

# Custom dropdown
DropdownMenu(trigger_text: "User Menu") do
  DropdownMenuItem("Profile", profile_path)
  DropdownMenuItem("Settings", settings_path)
  DropdownMenuSeparator()
  DropdownMenuItem("Sign out", session_path, method: :delete, class: "text-destructive")
end
```

## Styling System

Components use semantic CSS classes that work with the application's theme system:

```css
/* Semantic color classes */
.text-foreground          /* Primary text color */
.text-muted-foreground    /* Secondary text color */
.text-error               /* Error text color */
.text-success             /* Success text color */

/* Background colors */
.bg-primary               /* Primary background */
.bg-secondary             /* Secondary background */
.bg-surface               /* Surface background */
.bg-destructive           /* Destructive background */

/* Border colors */
.border-border            /* Standard border color */
```

## Example Usage

### Complete Login Form

```ruby
class Views::Sessions::New < Views::Base
  def view_template
    centered_container do
      card do
        h1(class: "text-2xl font-bold text-foreground mb-6") { "Sign In" }
        
        form_with(url: session_path, local: true, class: "space-y-4") do |form|
          FormField(
            label_text: "Email",
            input_type: :email,
            name: "email",
            required: true,
            autofocus: true
          )

          FormField(
            label_text: "Password",
            input_type: :password,
            name: "password",
            required: true
          )

          div(class: "flex justify-between items-center") do
            Button(type: :submit, variant: :primary) { "Sign In" }
            Button(variant: :link) { link_to("Forgot password?", new_password_reset_path) }
          end
        end
      end
    end
  end
end
```

### Component Composition Example

```ruby
class Components::ExampleCard < Components::Base
  def initialize(title:)
    @title = title
  end

  def view_template(&block)
    div(class: "bg-surface border border-border rounded-lg p-6 shadow-sm") do
      h3(class: "text-lg font-semibold text-foreground mb-4") { @title }
      
      # Using clean Kit syntax
      div(class: "space-y-4") do
        Button(variant: :primary) { "Primary Action" }
        Button(variant: :secondary) { "Secondary Action" }
        
        FormField(
          label_text: "Example Input",
          input_type: :text,
          name: "example",
          placeholder: "Enter something..."
        )
      end
      
      # Custom content block
      if block_given?
        div(class: "mt-4 pt-4 border-t border-border") do
          yield
        end
      end
    end
  end
end
```

## Testing Components

Components can be tested in isolation:

```ruby
# test/components/button_test.rb
require "test_helper"

class Components::ButtonTest < ActiveSupport::TestCase
  include Phlex::Testing::ViewHelper

  def test_renders_primary_button
    output = render Components::Button.new(variant: :primary) { "Click me" }
    
    assert_includes output, 'type="button"'
    assert_includes output, "Click me"
    assert_includes output, "bg-primary"
  end

  def test_renders_submit_button
    output = render Components::Button.new(type: :submit, variant: :primary) { "Submit" }
    
    assert_includes output, 'type="submit"'
    assert_includes output, "Submit"
  end
end
```

## Best Practices

### 1. Use Kit Syntax in Components and Views

```ruby
# Preferred - clean kit syntax
Button(variant: :primary) { "Save" }

# Still valid but more verbose
render Components::Button.new(variant: :primary) { "Save" }
```

### 2. Combine Related Components

```ruby
# Preferred - use FormField for label + input combinations
FormField(label_text: "Email", input_type: :email, name: "email")

# Less preferred - separate components
Label(for_id: "email", text: "Email")
Input(type: :email, id: "email", name: "email")
```

### 3. Use Semantic Variants

```ruby
# Good - semantic meaning
Button(variant: :primary) { "Save Changes" }      # Main action
Button(variant: :secondary) { "Cancel" }          # Secondary action
Button(variant: :destructive) { "Delete Item" }   # Dangerous action

# Avoid - unclear intent
Button(variant: :primary) { "Maybe" }
```

### 4. Include Accessibility Attributes

```ruby
FormField(
  label_text: "Password",
  input_type: :password,
  name: "password",
  required: true,
  autocomplete: "current-password"  # Accessibility
)
```

## Migration from ERB

When converting ERB templates to use the kit system:

1. **Replace HTML elements with components:**
   ```erb
   <!-- ERB -->
   <button type="submit" class="btn btn-primary">Save</button>
   
   <!-- Phlex Kit -->
   Button(type: :submit, variant: :primary) { "Save" }
   ```

2. **Combine form elements:**
   ```erb
   <!-- ERB -->
   <label for="email">Email</label>
   <input type="email" id="email" name="email" required>
   
   <!-- Phlex Kit -->
   FormField(label_text: "Email", input_type: :email, name: "email", required: true)
   ```

3. **Use semantic styling:**
   ```erb
   <!-- ERB -->
   <div class="bg-white border rounded p-4">
   
   <!-- Phlex Kit -->
   card do
   ```

## Kit Limitations

1. **ERB Compatibility**: Kit syntax only works within Phlex components/views, not in ERB templates
2. **Parentheses Required**: For components without arguments or blocks, use empty parentheses: `Navigation()`
3. **Capital Letters**: Kit methods start with capital letters to match component class names

## Extending the Kit

To add new components to the kit:

1. **Create the component** in `app/components/`:
   ```ruby
   class Components::NewComponent < Components::Base
     # Component implementation
   end
   ```

2. **Use immediately** with kit syntax:
   ```ruby
   NewComponent(some: :argument) { "content" }
   ```

The Phlex Kit system automatically detects new components and makes them available through the clean syntax.

This kit system provides a powerful, clean way to build consistent, reusable UI components with minimal boilerplate and maximum readability.