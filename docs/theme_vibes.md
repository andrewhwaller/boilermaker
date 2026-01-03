# Theme Vibes Guide

This guide describes each theme's personality, visual elements, and when to use it.

## Overview

Boilermaker includes 5 themed UI systems, each with distinct visual language:

| Theme | Vibe | Best For |
|-------|------|----------|
| Paper | Warm, refined, minimal | Content-focused apps, reading-heavy interfaces |
| Terminal | Green phosphor CRT | Developer tools, monitoring, retro tech feel |
| Blueprint | Technical drawings | Engineering apps, data-heavy dashboards |
| Brutalist | Raw, stark, honest | Minimal portfolios, bold statements |
| DOS | Amber nostalgia | Productivity tools, command-line inspired |

## Mixing Colors and Layouts

Colors (themes) and layouts are separate concepts that can be mixed:

```yaml
# config/boilermaker.yml
development:
  ui:
    theme:
      name: terminal    # Colors: green phosphor CRT palette
    layout:
      name: blueprint   # Structure: title block, tabbed nav, sections
```

This gives you terminal colors with blueprint's structural components.

---

## Paper Theme

**Personality:** Warm, minimal, refined industrial

**Visual Elements:**
- Serif typography for headers
- Subtle borders and dividers
- Warm neutral palette
- Generous whitespace
- Clean, printable aesthetic

**When to Use:**
- Content-heavy applications
- Documentation sites
- Reading-focused interfaces
- Classic, timeless feel

**Components:**
- Standard header with serif font
- Simple bordered cards
- Clean activity lists

**Demo:** `/demos/paper`

---

## Terminal Theme

**Personality:** Green phosphor CRT, retro-tech

**Visual Elements:**
- Monospace typography throughout
- Green-on-dark color scheme
- Scanline overlay effect
- Dotted borders
- Command prompt styling
- Glowing hover effects

**When to Use:**
- Developer tools
- System monitoring
- CLI-inspired interfaces
- Retro aesthetic projects

**Key Components:**
- `PromptHeader` - `$ ` prefix headers
- `CommentHeader` - `// ` section markers
- `IndexedList` - Numbered row lists
- `LogWindow` - Timestamped log entries
- `CommandInput` - Command line input

**Demo:** `/demos/terminal`

---

## Blueprint Theme

**Personality:** Technical drawings, engineering documents

**Visual Elements:**
- Grid paper background
- Technical drawing borders
- Section markers with letters (A, B, C...)
- Title blocks with metadata
- Tabbed navigation
- Uppercase headings

**When to Use:**
- Engineering applications
- Data-heavy dashboards
- Technical documentation
- Professional tools

**Key Components:**
- `TitleBlock` - Technical drawing header with metadata
- `TabbedNav` - Tab-style navigation
- `SectionMarker` - Lettered section dividers

**Demo:** `/demos/blueprint`

---

## Brutalist Theme

**Personality:** Raw, minimal, maximum content

**Visual Elements:**
- Heavy borders
- High contrast
- Minimal decoration
- Bold typography
- Inverted hover states
- Keyboard-first design

**When to Use:**
- Portfolios
- Minimal applications
- Bold design statements
- Accessibility-focused interfaces

**Key Components:**
- `KbdHint` - Keyboard shortcut badges
- Heavy bordered containers
- Stark black/white contrast

**Demo:** `/demos/brutalist`

---

## DOS Theme

**Personality:** Amber monochrome, chunky, nostalgic

**Visual Elements:**
- Amber on dark palette
- Menu bars with underlined hotkeys
- F-key function bar
- Box panels with title bars
- Scanline overlay
- Chunky, readable text

**When to Use:**
- Productivity tools
- Command-line inspired apps
- Nostalgic projects
- Keyboard-driven interfaces

**Key Components:**
- `MenuBar` - Menu with underlined hotkeys
- `FkeyBar` - F1-F10 function key bar
- `BoxPanel` - Panel with title bar

**Demo:** `/demos/dos`

---

## Configuration

### Setting Theme Colors

Edit `config/boilermaker.yml`:

```yaml
development:
  ui:
    theme:
      name: terminal  # paper, terminal, blueprint, brutalist, dos
```

### Setting Layout Structure

```yaml
development:
  ui:
    layout:
      name: blueprint  # defaults to theme name if not set
```

### Customization

To customize a theme's colors, edit `app/assets/tailwind/themes.css`:

```css
[data-theme="terminal"] {
  --accent: #00ff00;  /* Change the accent color */
}
```

To create a custom layout, extend `Views::Layouts::DashboardBase`:

```ruby
class MyLayout < Views::Layouts::DashboardBase
  def theme_name = "terminal"
  def polarity = "dark"

  def header_content
    # Your custom header
  end

  def footer_content
    # Your custom footer
  end
end
```

---

## Component Reference

### Behavior Components

Components named by what they do, not which theme they're for:

| Component | Purpose | Example |
|-----------|---------|---------|
| `PromptHeader` | Header with `$ ` prefix | Terminal-style headers |
| `CommentHeader` | Header with `// ` prefix | Section comments |
| `KbdHint` | Keyboard shortcut badge | `Ctrl+C` hint |
| `IndexedList` | List with row numbers | Numbered alerts |
| `LogWindow` | Timestamped log entries | System logs |
| `TabbedNav` | Tab-style navigation | Section tabs |
| `MenuBar` | Menu with hotkeys | DOS-style menu |
| `FkeyBar` | Function key bar | F1-F10 actions |
| `TitleBlock` | Technical drawing header | Blueprint header |
| `SectionMarker` | Lettered section marker | Section A, B, C |
| `BoxPanel` | Panel with title bar | Windowed content |
| `CommandInput` | Command line input | Search/command bar |

### Using Components

```ruby
# In your view
render Components::PromptHeader.new(text: "SYSTEM STATUS")
render Components::CommentHeader.new(title: "ALERTS")

render Components::IndexedList.new(items: @alerts) do |alert|
  div { alert.name }
end

render Components::LogWindow.new(entries: [
  { time: "14:32:01", type: "INFO", message: "Sync complete" }
])
```

---

## Quick Start

1. **Visit demo pages** to see themes in action:
   - `/demos/paper`
   - `/demos/terminal`
   - `/demos/blueprint`
   - `/demos/brutalist`
   - `/demos/dos`

2. **Pick your theme** in `config/boilermaker.yml`

3. **Mix layouts** if desired (e.g., DOS colors + Blueprint layout)

4. **Use behavior components** to build your UI

5. **Customize** colors and layouts as needed
