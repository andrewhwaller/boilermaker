# Font Configuration

Boilermaker supports configurable fonts, allowing you to choose from a curated list of fonts for your application. The system intelligently handles both local fonts and Google Fonts.

## Configuration

Fonts are configured in `config/boilermaker.yml` under the `ui.typography.font` setting:

```yaml
development:
  ui:
    typography:
      font: CommitMono  # Default font
```

## Available Fonts

### Local Fonts

**CommitMono** (Default)
- Type: Local (pre-loaded)
- Style: Monospace
- Use case: Technical, code-focused applications
- No external dependencies

### Google Fonts

**Inter**
- Type: Google Font
- Style: Modern sans-serif
- Use case: Clean, professional interfaces
- Weights: 400, 500, 600, 700

**Space Grotesk**
- Type: Google Font
- Style: Geometric sans-serif
- Use case: Modern, tech-forward designs
- Weights: 400, 500, 600, 700

**JetBrains Mono**
- Type: Google Font
- Style: Monospace
- Use case: Code editors, developer tools
- Weights: 400, 500, 600, 700

**IBM Plex Sans**
- Type: Google Font
- Style: Corporate sans-serif
- Use case: Enterprise applications
- Weights: 400, 500, 600, 700

**Roboto Mono**
- Type: Google Font
- Style: Monospace
- Use case: Technical interfaces, dashboards
- Weights: 400, 500, 600, 700

## How It Works

### 1. Configuration Loading

The font is configured in `boilermaker.yml` and accessed via:

```ruby
Boilermaker::Config.font_name
# => "CommitMono" (or configured font)
```

### 2. Google Fonts Loading

For Google Fonts, the system automatically:
- Adds preconnect links to Google Fonts CDN
- Loads the font stylesheet with optimal weights
- Uses `font-display: swap` for better performance

For local fonts (CommitMono):
- No external requests are made
- Font is already loaded via `@font-face` in application.css

### 3. CSS Variable Application

The font family is set as a CSS custom property:

```css
:root {
  --app-font-family: "Inter", -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
}

body {
  font-family: var(--app-font-family, "Arial");
}
```

This approach provides:
- Easy theme customization
- Fallback to Arial if font fails to load
- Consistent font application across the app

## Usage

### Changing the Font

Edit `config/boilermaker.yml`:

```yaml
development:
  ui:
    typography:
      font: Inter  # Change to any available font
```

Then restart your Rails server.

### In Views (Phlex)

The font is automatically applied to the entire application through the layout. No additional code needed.

### Accessing Font Information

```ruby
# Get current font name
Boilermaker::Config.font_name

# Get font family stack
Boilermaker::FontConfiguration.font_family_stack("Inter")
# => "Inter", -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif

# Check if font is a Google Font
Boilermaker::FontConfiguration.google_font?("Inter")
# => true

# Get Google Fonts URL
Boilermaker::FontConfiguration.google_fonts_url("Inter")
# => "https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"

# List all available fonts
Boilermaker::FontConfiguration.all_fonts
# => ["CommitMono", "Inter", "Space Grotesk", "JetBrains Mono", "IBM Plex Sans", "Roboto Mono"]
```

## Implementation Details

### Files Modified

- `config/boilermaker.yml` - Added typography.font configuration
- `lib/boilermaker/font_configuration.rb` - Font definitions and helpers
- `lib/boilermaker/config.rb` - Added `font_name` convenience method
- `lib/boilermaker.rb` - Required FontConfiguration module
- `app/helpers/application_helper.rb` - Added `google_fonts_link_tag` and `app_font_family`
- `app/views/layouts/application.rb` - Integrated font loading and CSS variables
- `app/assets/tailwind/application.css` - Updated body font to use CSS variable

### Boilermaker Config UI

The Boilermaker configuration UI (at `/boilermaker`) always uses CommitMono regardless of the app font setting. This is intentional to maintain a consistent "command center" aesthetic for the configuration interface.

## Performance Considerations

### Local Fonts (CommitMono)
- Zero network requests
- Instant rendering
- No FOUT (Flash of Unstyled Text)

### Google Fonts
- Preconnect hints minimize latency
- Subset loading for optimal file size
- `font-display: swap` prevents render blocking
- Fonts are cached by CDN

## Testing

Comprehensive test coverage is included:

```bash
# Test FontConfiguration module
bin/rails test test/lib/boilermaker/font_configuration_test.rb

# Test config integration
bin/rails test test/lib/boilermaker/config_test.rb

# Test helper methods
bin/rails test test/helpers/application_helper_test.rb
```

## Adding New Fonts

To add a new font to the curated list:

1. Edit `lib/boilermaker/font_configuration.rb`
2. Add font configuration to the `FONTS` hash:

```ruby
"Your Font Name" => {
  name: "Your Font Name",
  display_name: "Your Font Display Name",
  type: :google,  # or :local
  family_stack: '"Your Font Name", fallback, fonts',
  google_url: "https://fonts.googleapis.com/css2?family=Your+Font+Name..."
}
```

3. Add test coverage in `test/lib/boilermaker/font_configuration_test.rb`
4. Run tests to verify

## Rails Way Compliance

This implementation follows Rails conventions:

- **Fat models, skinny controllers**: Business logic in FontConfiguration module
- **Convention over configuration**: Sensible defaults (CommitMono)
- **Rails helpers**: Font loading logic in ApplicationHelper
- **CSS variables**: Theme-agnostic font application
- **Comprehensive tests**: Full test coverage using Minitest
- **No abstractions**: Simple, straightforward implementation
