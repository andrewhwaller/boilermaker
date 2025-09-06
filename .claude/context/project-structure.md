---
created: 2025-08-30T20:18:02Z
last_updated: 2025-08-30T20:18:02Z
version: 1.0
author: Claude Code PM System
---

# Project Structure

## Root Directory Organization
```
boilermaker/
├── app/                    # Core Rails application
├── bin/                    # Executable scripts
├── config/                 # Configuration files
├── db/                     # Database files and migrations  
├── docs/                   # Project documentation
├── lib/                    # Custom libraries
├── log/                    # Application logs
├── public/                 # Static assets
├── test/                   # Test files
├── tmp/                    # Temporary files
├── vendor/                 # Third-party dependencies
└── node_modules/           # Node.js dependencies
```

## App Directory Structure
```
app/
├── components/             # Phlex view components
│   ├── base.rb            # Base component class
│   ├── navigation.rb      # Navigation component
│   ├── form_group.rb      # Form components
│   ├── input.rb           # Input field components
│   └── ...                # Various UI components
├── mailers/               # Email handling
├── models/                # Data models
│   ├── concerns/          # Shared model concerns
│   ├── user.rb           # User authentication
│   ├── account.rb        # Account management
│   └── ...               # Other domain models
└── ...
```

## Configuration Organization
```
config/
├── application.rb         # Main app configuration
├── routes.rb             # URL routing
├── database.yml          # Database configuration
├── environments/         # Environment-specific settings
└── initializers/         # Initialization files
```

## Documentation Structure
```
docs/
├── phlex_architecture.md    # Phlex system design
├── phlex_scaffolding.md    # Scaffolding documentation
├── phlex_component_kits.md # Component kit system
├── phlex_shared_components.md # Shared component usage
└── tailwind_usage.md       # Styling guidelines
```

## File Naming Patterns
### Components
- **Base Components:** `base.rb`, `application_component.rb`
- **UI Components:** Snake_case naming (e.g., `form_group.rb`, `submit_button.rb`)
- **Domain Components:** Business logic naming (e.g., `recovery_code_item.rb`)

### Models
- **Core Models:** Singular naming (e.g., `user.rb`, `account.rb`, `session.rb`)
- **Concerns:** Descriptive modules (e.g., `account_scoped.rb`)
- **Special Models:** Context objects (e.g., `current.rb`)

### Tests
- **Test Files:** Mirror app structure with `_test.rb` suffix
- **System Tests:** Integration tests for full workflows

## Module Organization
### Component Inheritance
```
ApplicationComponent (base)
├── Base (shared functionality)
├── Navigation (layout components)
├── Form components (input handling)
└── UI components (buttons, labels, etc.)
```

### Model Concerns
- **AccountScoped:** Multi-tenant functionality
- **Authentication:** Session and security handling
- **Validation:** Custom validation logic

## Asset Organization
### Static Assets (public/)
- Images, fonts, and static files
- Compiled CSS and JavaScript output

### Development Assets
- Tailwind source files
- JavaScript modules via importmap
- Component-specific stylesheets