# Font Configuration

Boilermaker supports configurable fonts, allowing you to choose from a curated list of fonts for your application. The system intelligently handles local fonts as well as remote fonts delivered by Google Fonts and third-party CDNs such as JSDelivr.

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

### Remote Fonts

**Inter**
- Source: Google Fonts
- Style: Modern sans-serif
- Weights: 400, 500, 600, 700

**Space Grotesk**
- Source: Google Fonts
- Style: Geometric sans-serif
- Weights: 400, 500, 600, 700

**JetBrains Mono**
- Source: Google Fonts
- Style: Monospace
- Weights: 400, 500, 600, 700

**IBM Plex Sans**
- Source: Google Fonts
- Style: Corporate sans-serif
- Weights: 400, 500, 600, 700

**Roboto Mono**
- Source: Google Fonts
- Style: Monospace
- Weights: 400, 500, 600, 700

**EB Garamond**
- Source: Google Fonts
- Style: Serif
- Weights: 400, 500, 600, 700

**Libre Franklin**
- Source: Google Fonts
- Style: Sans-serif
- Weights: 400, 500, 600, 700

**Jura**
- Source: Google Fonts
- Style: Display sans-serif
- Weights: 400, 500, 600, 700

**Monaspace Argon · Neon · Xenon · Krypton · Radon**
- Source: JSDelivr (GitHub Monaspace project)
- Style: Monospaced superfamily with distinct personalities
- Weights: 400, 500, 700 (served from JSDelivr CDN)

## How It Works

### 1. Configuration Loading

The font is configured in `boilermaker.yml` and accessed via:

```ruby
Boilermaker::Config.font_name
# => "CommitMono" (or configured font)
```

### 2. Remote Font Loading

For remote fonts, the system automatically:
- Adds preconnect links for the appropriate CDN (Google Fonts, JSDelivr, etc.)
- Preloads the font binaries for each shipped weight whenever we control the asset URLs (Monaspace)
- Loads either the provider-hosted stylesheet (Google Fonts) or injects inline `@font-face` declarations that point directly at CDN-hosted font binaries (Monaspace)
- Uses `font-display` hints tuned for each provider to reduce flashes of unstyled text

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

# Google Fonts expose their stylesheet URL
Boilermaker::FontConfiguration.google_fonts_url("Inter")
# => "https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"

# Generic helpers work for any remote font
Boilermaker::FontConfiguration.stylesheet_urls("Monaspace Neon")
# => []
Boilermaker::FontConfiguration.style_blocks("Monaspace Neon")
# => ["@font-face { ... }"]
Boilermaker::FontConfiguration.preconnect_urls("Monaspace Neon")
# => [{ href: "https://cdn.jsdelivr.net", crossorigin: "anonymous" }]
Boilermaker::FontConfiguration.preload_links("Monaspace Neon")
# => [
#   { href: "https://cdn.jsdelivr.net/.../MonaspaceNeon-Regular.woff", as: "font", type: "font/woff", crossorigin: "anonymous" },
#   { href: "https://cdn.jsdelivr.net/.../MonaspaceNeon-Medium.woff", as: "font", type: "font/woff", crossorigin: "anonymous" },
#   { href: "https://cdn.jsdelivr.net/.../MonaspaceNeon-Bold.woff", as: "font", type: "font/woff", crossorigin: "anonymous" }
# ]

# List all available fonts
Boilermaker::FontConfiguration.all_fonts
# => ["CommitMono", "Inter", "Space Grotesk", ...]
```

## Implementation Details

### Files Modified

- `config/boilermaker.yml` - Typography font configuration
- `lib/boilermaker/font_configuration.rb` - Font definitions, remote CDN handling
- `lib/boilermaker/config.rb` - `font_name` convenience method
- `lib/boilermaker.rb` - Requires FontConfiguration module
- `app/helpers/application_helper.rb` - `font_stylesheet_link_tag`, `app_font_family`
- `app/views/layouts/application.rb` - Integrates font loading and CSS variables
- `app/assets/tailwind/application.css` - Uses CSS variable for body font
- Inline Monaspace font-face declarations are generated at runtime, so no additional static assets are required

### Boilermaker Config UI

The Boilermaker configuration UI (at `/boilermaker`) always uses CommitMono regardless of the app font setting. This is intentional to maintain a consistent "command center" aesthetic for the configuration interface.

## Performance Considerations

### Local Fonts (CommitMono)
- Zero network requests
- Instant rendering
- No FOUT (Flash of Unstyled Text)

### Remote Fonts
- Preconnect hints minimize latency
- Stylesheets are only added when the font is selected
- `font-display: swap` prevents render blocking
- Fonts are served from well-cached CDNs (Google Fonts or JSDelivr)

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
2. Add font configuration to the `FONTS` hash. Remote fonts should define `stylesheet_urls` and optional `preconnect_urls`:

```ruby
"Your Font Name" => {
  name: "Your Font Name",
  display_name: "Your Font Display Name",
  type: :remote,  # or :local
  family_stack: '"Your Font Name", fallback, fonts',
  stylesheet_urls: ["https://cdn.example.com/path/to/your-font.css"],
  preconnect_urls: [
    { href: "https://cdn.example.com", crossorigin: "anonymous" }
  ]
}
```

If the remote provider does not ship a stylesheet, you can create a small CSS file under `public/fonts/` that defines `@font-face` rules pointing to CDN-hosted assets and reference it from `stylesheet_urls`.
