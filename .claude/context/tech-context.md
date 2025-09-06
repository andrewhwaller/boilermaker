---
created: 2025-08-30T20:18:02Z
last_updated: 2025-08-30T20:18:02Z
version: 1.0
author: Claude Code PM System
---

# Technology Context

## Core Technology Stack
### Backend Framework
- **Ruby on Rails 8.0.2** - Latest Rails with modern features
- **Ruby 3.4+** - Current Ruby version (see .ruby-version)
- **SQLite 3** - Database with Litestream for reliability
- **Puma** - Web server for production and development

### View Layer
- **Phlex Rails 2.3+** - Pure Ruby view components
- **Phlex Component Architecture** - Custom component kit system
- **Custom Phlex Scaffolding** - Automated component generation

### Frontend Technologies  
- **Tailwind CSS** - Utility-first CSS framework
- **Tailwind Typography** - Enhanced text styling (@tailwindcss/typography)
- **Hotwire Stack:**
  - **Turbo Rails** - SPA-like navigation and updates
  - **Stimulus Rails** - Modest JavaScript framework
- **Importmap Rails** - Modern JavaScript without bundling
- **Propshaft** - Rails asset pipeline

### Authentication & Security
- **BCrypt** - Password hashing
- **ROTP** - Time-based one-time passwords (2FA)
- **RQRCode** - QR code generation for 2FA setup
- **Pwned** - Password breach checking
- **Brakeman** - Static security analysis

### Background Processing
- **Solid Queue** - Database-backed job processing
- **Solid Cache** - Database-backed caching
- **Solid Cable** - Database-backed Action Cable

### Development Dependencies
```ruby
group :development, :test do
  gem "debug"                    # Debugging tools
  gem "brakeman"                # Security scanner
  gem "rubocop-rails-omakase"   # Code styling
end

group :development do
  gem "web-console"             # Console in browser
  gem "overmind"               # Process manager
  gem "hotwire-spark"          # Development tools
  gem "letter_opener_web"      # Email previews
end

group :test do
  gem "capybara"               # Integration testing
  gem "selenium-webdriver"     # Browser automation
end
```

### Node.js Dependencies
```json
{
  "dependencies": {
    "@tailwindcss/typography": "^0.5.16"
  }
}
```

## Development Tools
### Process Management
- **Overmind** - Development process manager
- **Procfile.dev** - Development process configuration
- **bin/dev** - Development startup script

### Code Quality
- **RuboCop Rails Omakase** - Ruby/Rails style enforcement
- **Brakeman** - Security vulnerability scanning
- **.rubocop.yml** - Custom RuboCop configuration

### Database
- **SQLite** with optimized configuration
- **Database migrations** - Rails ActiveRecord migrations
- **Litestream** integration for backup/replication

### Deployment
- **Kamal** - Docker-based deployment
- **Thruster** - HTTP acceleration and caching
- **Dockerfile** - Container configuration
- **.kamal/** - Deployment configuration

### Testing Framework
- **Rails Testing** - Built-in Rails test framework
- **Capybara + Selenium** - System/integration testing
- **Test directory structure** - Organized test files

## Version Management
- **Ruby Version:** Specified in `.ruby-version`
- **Node Version:** Managed via package.json
- **Gem Dependencies:** Locked in Gemfile.lock
- **Node Dependencies:** Locked in package-lock.json

## Environment Configuration
- **.env** and **.env.example** - Environment variables
- **mise.toml** - Development tool version management
- **config/environments/** - Rails environment configs

## Performance & Caching
- **Bootsnap** - Boot time optimization
- **Solid Cache** - Database-backed caching
- **Asset Pipeline** - Propshaft for asset management
- **Importmap** - JavaScript module loading

## Development Workflow
- **bin/setup** - Project setup script
- **bin/dev** - Start development server
- **Overmind** - Manage multiple development processes
- **Hot reloading** - Via Hotwire and Rails development mode