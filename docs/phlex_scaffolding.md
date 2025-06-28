# Phlex View Scaffolding

This boilerplate includes a custom `phlex:scaffold` generator that creates Phlex views and controllers for standard Rails scaffolding workflows.

## Quick Start

You have two options for using Phlex scaffolding:

### Option A: Use the Custom Generator
Instead of using the default Rails scaffold (which generates ERB views), you can use:

```bash
bin/rails generate phlex:scaffold ModelName field1:type field2:type
```

### Option B: Make Phlex the Default (Recommended)
Uncomment these lines in `config/application.rb`:

```ruby
config.generators do |g|
  g.template_engine :phlex_scaffold
end
```

Then use the regular scaffold command, and it will automatically generate Phlex views and controllers:

```bash
bin/rails generate scaffold ModelName field1:type field2:type
```

For example:
```bash
bin/rails generate phlex:scaffold Post title:string content:text published:boolean
```

This will generate:
- `app/controllers/posts_controller.rb` - Controller with Phlex view rendering
- `app/views/posts/index.rb` - List all posts
- `app/views/posts/show.rb` - Show a single post
- `app/views/posts/new.rb` - New post form
- `app/views/posts/edit.rb` - Edit post form
- `app/views/posts/_form.rb` - Shared form component

## Generated Features

### Controller
- Automatically renders Phlex views
- Follows Rails best practices
- Includes proper error handling
- Uses strong parameters
- Includes all standard CRUD actions

### Index View
- Displays all records in a clean, styled list
- Shows all non-timestamp attributes
- Includes "Show", "Edit", and "Delete" actions for each record
- Styled with Tailwind CSS classes for a modern look

### Show View  
- Displays individual record details in a structured layout
- Shows all attributes in a clean definition list format
- Includes navigation back to index and edit links

### New/Edit Views
- Use the shared `_form.rb` component
- Include proper navigation links
- Handle errors gracefully

### Form Component
- Automatically generates appropriate form fields based on attribute types:
  - `string` → text field
  - `text` → textarea 
  - `boolean` → checkbox
  - `integer/decimal/float` → number field
  - `date` → date field
  - `datetime` → datetime field
  - `email` → email field
- Displays validation errors in a styled error block
- Uses your existing `Components::Label` and `Components::Button` components
- Includes proper CSRF protection and Rails form helpers

## Comparison with Default Scaffold

### Default Rails Scaffold
```bash
bin/rails generate scaffold Post title:string content:text
```
Creates ERB views and a standard controller that you'd need to manually convert to work with Phlex.

### Phlex Scaffold (New!)
```bash
bin/rails generate phlex:scaffold Post title:string content:text
```
Creates Phlex views and a Phlex-compatible controller that work immediately with your existing architecture.

## Workflow Integration

### Option 1: Use Default Scaffold with Phlex Configuration (Recommended)
1. Enable Phlex as the default template engine (see Quick Start Option B above)
2. Use the regular scaffold command:

```bash
# Generate everything with Phlex views and controllers automatically
bin/rails generate scaffold Post title:string content:text published:boolean
```

### Option 2: Replace Default Scaffold Views and Controller
1. Generate your model with the default scaffold
2. Delete the generated ERB views and controller
3. Generate Phlex views and controller instead:

```bash
# Generate everything (model, routes, etc.)
bin/rails generate scaffold Post title:string content:text published:boolean

# Remove the ERB views and default controller
rm -rf app/views/posts
rm app/controllers/posts_controller.rb

# Generate Phlex views and controller
bin/rails generate phlex:scaffold Post title:string content:text published:boolean
```

### Option 3: Views and Controller Only Generation
1. Create your model manually or with a separate generator
2. Generate only the Phlex views and controller:

```bash
bin/rails generate model Post title:string content:text published:boolean
bin/rails generate phlex:scaffold Post title:string content:text published:boolean
```

## Customization

The generator uses templates located in `lib/generators/phlex/scaffold/templates/`. You can customize these templates to match your specific needs:

- `controller.rb.erb` - Controller template
- `index.rb.erb` - Index view template
- `show.rb.erb` - Show view template  
- `new.rb.erb` - New view template
- `edit.rb.erb` - Edit view template
- `_form.rb.erb` - Form component template

### Advanced Customization

You can override the generator's behavior by modifying `lib/generators/phlex/scaffold/scaffold_generator.rb`:

- Change the CSS classes used
- Modify which attributes are displayed
- Add custom field types
- Change the form layout structure
- Customize controller behavior

## Benefits

1. **Consistent Architecture**: All views and controllers follow your established Phlex patterns
2. **Component Integration**: Automatically uses your existing components
3. **Type-Aware Forms**: Generates appropriate form fields for different data types
4. **Modern Styling**: Uses Tailwind CSS classes for clean, modern appearance
5. **Error Handling**: Includes proper validation error display
6. **Rails Integration**: Works seamlessly with Rails form helpers and routing

## Examples

### Blog Post Scaffold
```bash
bin/rails generate phlex:scaffold Post title:string content:text published:boolean author:string
```

### Product Catalog
```bash
bin/rails generate phlex:scaffold Product name:string description:text price:decimal available:boolean
```

### User Profile
```bash
bin/rails generate phlex:scaffold Profile user:references bio:text website:string public:boolean
```

This generator makes it easy to rapidly prototype new features while maintaining your Phlex-based architecture! 