# Boilermaker

A modern Rails 8 application template with a component-based architecture.

## Tech Stack

- **Ruby 3.4.4** / **Rails 8.0.3**
- **Phlex** - Ruby-based view components
- **Stimulus** - JavaScript framework for progressive enhancement
- **Turbo** - SPA-like page acceleration
- **Tailwind CSS** - Utility-first CSS framework
- **SQLite** - Database with Solid Queue, Solid Cache, and Solid Cable
- **Minitest** - Testing framework with Capybara for system tests

## Features

### Authentication & Security
- Session-based authentication
- Two-factor authentication (TOTP) with QR code generation (configurable)
- Password reset functionality (configurable)
- User registration (configurable)
- Obfuscated model IDs via Hashids

### Modern Rails Stack
- **Solid Queue** - Database-backed background jobs
- **Solid Cache** - Database-backed caching
- **Solid Cable** - Database-backed Action Cable
- **Propshaft** - Modern asset pipeline
- **Importmap** - JavaScript without bundling

### Developer Experience
- **Phlex Scaffolding** - Generate complete CRUD interfaces with Phlex views
- **Overmind** - Process manager for development
- **Letter Opener** - Preview emails in development
- **Hotwire Spark** - Live reloading during development
- **Brakeman** - Security vulnerability scanning
- **Rubocop** - Rails Omakase style enforcement

### Boilermaker Engine
Internal Rails engine providing:
- User settings management
- Custom theme system with light/dark modes
- Configurable feature flags
- Account/multi-tenancy support (configurable)

## Getting Started

### Prerequisites
- Ruby 3.4.4
- Rails 8.0.3
- SQLite3

### Installation

1. Clone this repository
2. Install dependencies:
```bash
bin/setup
```

3. Start the development server:
```bash
bin/dev
```

The application will be available at `http://localhost:3000`.

## Phlex View Scaffolding

This template includes a custom Phlex scaffolding system configured by default in `config/application.rb`.

### Generate a Scaffold

```bash
rails generate scaffold Post title:string content:text published:boolean
```

This generates:
- Model with validations
- Controller with standard CRUD actions
- Phlex view components for index, show, edit, new, and form
- Routes
- Migration

### File Structure

Generated scaffolds create:
```
app/
├── components/
│   └── posts/
│       ├── form_component.rb    # Reusable form component
│       └── post_component.rb    # Individual post display
├── controllers/
│   └── posts_controller.rb
├── models/
│   └── post.rb
└── views/
    └── posts/
        ├── index.rb             # List view
        ├── show.rb              # Detail view
        ├── new.rb               # New form
        └── edit.rb              # Edit form
```

## Development

### Running Tests

```bash
rails test                        # Run all tests
rails test test/models/user_test.rb  # Run specific test
rails test:system                 # Run system tests
```

### Code Quality

```bash
rubocop           # Run Rubocop
brakeman          # Run security scan
```

### Database

```bash
rails db:migrate  # Run migrations
rails db:create   # Create database
```

## Configuration

### Feature Flags

Configure features in `config/boilermaker.yml`:

```yaml
default:
  features:
    user_registration: true
    password_reset: true
    two_factor_authentication: false
    multi_tenant: false
    personal_accounts: false
```

Check feature status in code:
```ruby
Boilermaker.feature_enabled?(:two_factor_authentication)
Boilermaker::Config.multi_tenant?
```

### Theme System

The application includes custom themes optimized for productivity:

- **work-station** - Clean, focused light theme for daytime work
- **command-center** - Professional dark theme for extended coding sessions

Configure themes in `config/boilermaker.yml`:

```yaml
ui:
  theme:
    light: work-station
    dark: command-center
```
