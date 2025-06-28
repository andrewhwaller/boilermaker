# Boilermaker Configuration Engine

The Boilermaker configuration system is organized as a Rails Engine within the `lib/boilermaker/` namespace, keeping it cleanly separated from your main application code.

## Structure

```
lib/boilermaker/
├── README.md                          # This file
├── config.rb                          # Core configuration management
├── engine.rb                          # Rails engine that integrates everything
├── version.rb                         # Version information
├── config/
│   └── routes.rb                      # Engine routes
├── controllers/
│   └── configurations_controller.rb    # Configuration interface controller
└── views/
    └── configurations/
        └── show.rb                    # Phlex view for config display
```

## Usage

### Accessing Configuration

The configuration is available throughout your application via:

```ruby
# In controllers and models
Boilermaker.config.app_name
Boilermaker.config.feature_enabled?('two_factor_authentication')

# In views (helper methods available)
app_name
feature_enabled?('user_registration')
primary_color
```

### Configuration File

The main configuration lives in `config/boilermaker.yml` and supports environment-specific settings:

```yaml
default: &default
  app:
    name: "My App"
    version: "1.0.0"
  features:
    personal_accounts: true
    two_factor_authentication: true
  # ... more settings

development:
  <<: *default
  debug:
    enabled: true

production:
  <<: *default
  app:
    name: "My Production App"
```

### Feature Toggles

Use feature toggles throughout your app:

```ruby
# In controllers
def create
  return head :forbidden unless feature_enabled?('user_registration')
  # ... registration logic
end

# In views with Phlex
def view_template
  if_feature_enabled('dark_mode') do
    button(class: "dark-mode-toggle") { "Toggle Dark Mode" }
  end
end
```

### Configuration Interface

Access the configuration interface at `/boilermaker/configuration` (only available in development/test environments).

## Engine Integration

The engine automatically:

1. **Loads Configuration**: Reads `config/boilermaker.yml` at startup
2. **Adds Helper Methods**: Makes config available in controllers and views
3. **Configures Rails**: Sets up sessions, mailers, etc. based on config
4. **Provides Configuration Interface**: Web interface for viewing/editing config (development/test only)

## Benefits of Engine Structure

- **Separation of Concerns**: Config system is isolated from main app
- **Reusability**: Could potentially be extracted as a gem
- **Organization**: All related code is in one namespace
- **Maintainability**: Clear boundaries and responsibilities
- **Testing**: Easier to test in isolation

## Adding New Configuration Options

1. Add to `config/boilermaker.yml`
2. Add convenience method to `Config` class if needed
3. Update configuration interface params if you want web editing
4. Add tests for new functionality

## Engine Routes

The engine provides these routes (when mounted at `/boilermaker` in development/test):

- `GET /boilermaker/configuration` - View current config
- `GET /boilermaker/configuration/edit` - Edit config (TODO)
- `PATCH /boilermaker/configuration` - Update config (TODO) 