# Phlex View Architecture

## Overview

Boilermaker uses [Phlex](https://www.phlex.fun/) for its view layer, providing a pure Ruby approach to HTML generation. This document outlines our Phlex architecture, component patterns, and best practices.

## Directory Structure

```
app/
├── components/
│   ├── base.rb
│   ├── button.rb
│   ├── input.rb
│   ├── label.rb
│   ├── navigation.rb
│   └── two_factor_authentication/
│       └── profile/
│           └── recovery_codes/
│               └── recovery_code.rb
└── views/
    ├── layouts/
    │   └── application.rb
    ├── home/
    │   └── index.rb
    ├── registrations/
    │   └── new.rb
    ├── sessions/
    │   └── new.rb
    ├── passwords/
    │   └── edit.rb
    └── identity/
        └── password_resets/
            ├── new.rb
            └── edit.rb
```

## Component Architecture

### Base Component

All components inherit from `Components::Base`, which provides common functionality:

```ruby
module Components
  class Base < Phlex::HTML
    def initialize(**attrs)
      @attrs = attrs
    end

    private

    def merge_classes(default_classes, additional_classes = nil)
      [default_classes, additional_classes, @attrs[:class]].compact.join(" ")
    end
  end
end
```

### Component Patterns

1. **Simple Components**
   ```ruby
   module Components
     class Button < Base
       def template
         button(**@attrs) { yield if block_given? }
       end
     end
   end
   ```

2. **Components with Props**
   ```ruby
   module Components
     class Label < Base
       def initialize(for_input: nil, required: false, **attrs)
         @for_input = for_input
         @required = required
         super(**attrs)
       end

       def template
         label(@attrs.merge(for: @for_input)) do
           yield if block_given?
           span(class: "text-error") { "*" } if @required
         end
       end
     end
   end
   ```

3. **Composite Components**
   ```ruby
   module Components
     class Navigation < Base
       include Phlex::Rails::Helpers::LinkTo

       def template
         nav(class: "border-b p-4") do
           div { link_to("Brand", root_path) }
           div { yield if block_given? }
         end
       end
     end
   end
   ```

## View Architecture

### Base View

All views inherit from `Views::Base`, which provides common functionality and layout integration:

```ruby
module Views
  class Base < Phlex::HTML
    include Phlex::Rails::Helpers::ContentFor

    def template
      # Implement in subclasses
    end
  end
end
```

### Layout Integration

The application layout (`Views::Layouts::Application`) provides the HTML structure and includes common elements:

```ruby
module Views
  module Layouts
    class Application < Views::Base
      def template(&block)
        doctype
        html do
          head { ... }
          body do
            render Components::Navigation.new
            main { yield_content_or(&block) }
          end
        end
      end
    end
  end
end
```

## Controller Integration

Controllers render Phlex views directly:

```ruby
class RegistrationsController < ApplicationController
  def new
    render Views::Registrations::New.new(user: @user)
  end
end
```

## Best Practices

1. **Component Naming**
   - Use descriptive, singular names
   - Omit "Component" suffix (it's redundant in the components/ directory)
   - Follow Ruby naming conventions (e.g., `Button`, not `ButtonComponent`)

2. **Props vs Attributes**
   - Use props for component-specific configuration
   - Pass through HTML attributes via `**attrs`
   - Handle class merging in a consistent way

3. **Helper Inclusion**
   - Include only needed Rails helpers
   - Common helpers: `FormWith`, `LinkTo`, `ContentFor`
   - Keep helper inclusion at the class level

4. **Component Organization**
   - Place shared components in `app/components/`
   - Use subdirectories for feature-specific components
   - Keep component files focused and single-purpose

5. **View Organization**
   - Place views in `app/views/` matching controller structure
   - Use subdirectories for nested resources
   - Keep view logic minimal, push complexity to components

## Testing

1. **Component Testing**
   ```ruby
   RSpec.describe Components::Button do
     it "renders a button with text" do
       result = render(described_class.new(type: "submit")) { "Click me" }
       expect(result).to have_tag("button", text: "Click me")
     end
   end
   ```

2. **View Testing**
   ```ruby
   RSpec.describe Views::Registrations::New do
     it "renders the registration form" do
       result = render(described_class.new(user: User.new))
       expect(result).to have_tag("form")
     end
   end
   ```

## Migration Strategy

1. **Identify Components**
   - Start with shared partials
   - Look for repeated UI patterns
   - Consider future reusability

2. **Create Base Classes**
   - Set up `Components::Base`
   - Set up `Views::Base`
   - Establish common patterns

3. **Convert Views**
   - Start with simple, standalone views
   - Move to more complex views
   - Update controllers as you go

4. **Test and Verify**
   - Ensure functionality matches
   - Verify styling is preserved
   - Check accessibility features

## Common Patterns

1. **Form Handling**
   ```ruby
   form_with(model: @user) do |form|
     render Components::Label.new(for_input: "user_email") do
       plain("Email address")
     end
     render Components::Input.new(
       type: :email,
       name: "user[email]",
       id: "user_email"
     )
   end
   ```

2. **Conditional Rendering**
   ```ruby
   if notice
     div(class: "text-success") { plain(notice) }
   end
   ```

3. **Collection Rendering**
   ```ruby
   ul do
     @items.each do |item|
       render Components::ListItem.new(item: item)
     end
   end
   ```

## Troubleshooting

1. **Missing Constants**
   - Ensure proper module nesting
   - Check file naming and locations
   - Verify autoloading paths

2. **Helper Methods**
   - Include required Phlex helpers
   - Use proper helper method syntax
   - Check for naming conflicts

3. **Styling Issues**
   - Verify class merging
   - Check Tailwind class order
   - Inspect rendered HTML

## Resources

- [Phlex Documentation](https://www.phlex.fun/)
- [Phlex Rails Integration](https://github.com/phlex-ruby/phlex-rails)
- [Phlex Testing](https://github.com/phlex-ruby/phlex-testing) 