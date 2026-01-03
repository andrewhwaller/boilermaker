# PATENTWATCH Design System
## Unified Base + Swappable Themes

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│  Theme Layer (CSS Variables + Texture Overlays)         │
│  [paper] [terminal] [blueprint] [brutalist] [dos]       │
├─────────────────────────────────────────────────────────┤
│  Component Layer (Phlex Components)                     │
│  Header, Nav, AlertList, ResultsTable, StatsRow, etc.   │
├─────────────────────────────────────────────────────────┤
│  Base Layer (Tailwind Config + Core Utilities)          │
│  Typography, Spacing, Layout Patterns                   │
└─────────────────────────────────────────────────────────┘
```

Themes are applied via:
1. A `data-theme` attribute on `<body>`
2. CSS variables that cascade through all components
3. Optional texture overlays (scanlines, grid)
4. A few theme-specific utility classes

---

## Base Tailwind Config

```javascript
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      fontFamily: {
        mono: ['IBM Plex Mono', 'monospace'],
      },
      fontSize: {
        'xxs': ['9px', '1.4'],
        'xs': ['10px', '1.4'],
        'sm': ['11px', '1.5'],
        'base': ['13px', '1.6'],
        'lg': ['14px', '1.5'],
        'xl': ['18px', '1.4'],
        '2xl': ['24px', '1.3'],
      },
      maxWidth: {
        'content': '900px',
        'form': '640px',
        'narrow': '360px',
      },
      // Theme-aware colors via CSS variables
      colors: {
        theme: {
          bg: 'var(--bg)',
          'bg-alt': 'var(--bg-alt)',
          'bg-inverse': 'var(--bg-inverse)',
          text: 'var(--text)',
          'text-muted': 'var(--text-muted)',
          accent: 'var(--accent)',
          'accent-alt': 'var(--accent-alt)',
          border: 'var(--border)',
          'border-light': 'var(--border-light)',
        }
      }
    }
  }
}
```

---

## CSS Variable Definitions Per Theme

```css
/* themes.css */

/* ============================================
   THEME: Paper (Default)
   Warm, minimal, refined industrial
   ============================================ */
[data-theme="paper"], :root {
  --bg: #f5f3ef;
  --bg-alt: #eae7e1;
  --bg-inverse: #1a1a18;
  --text: #1a1a18;
  --text-muted: #6a6965;
  --accent: #c54b32;
  --accent-alt: #2d5a4a;
  --border: #1a1a18;
  --border-light: #d4d1ca;
  
  --overlay: none;
  --border-style: solid;
}

/* ============================================
   THEME: Terminal
   Green phosphor CRT
   ============================================ */
[data-theme="terminal"] {
  --bg: #0a0a0a;
  --bg-alt: #111110;
  --bg-inverse: #33ff33;
  --text: #33ff33;
  --text-muted: #1a8c1a;
  --accent: #ffb000;
  --accent-alt: #33ff33;
  --border: #1a8c1a;
  --border-light: #143614;
  
  --overlay: scanlines;
  --border-style: solid;
}

/* ============================================
   THEME: Blueprint
   Engineering document / technical drawing
   ============================================ */
[data-theme="blueprint"] {
  --bg: #f8f9fa;
  --bg-alt: #d4e3f5;
  --bg-inverse: #1e56a0;
  --text: #1a1d21;
  --text-muted: #5a6270;
  --accent: #1e56a0;
  --accent-alt: #c23b22;
  --border: #1e56a0;
  --border-light: #b8c8dc;
  
  --overlay: grid;
  --border-style: solid;
}

/* ============================================
   THEME: Brutalist
   Raw, minimal, maximum content
   ============================================ */
[data-theme="brutalist"] {
  --bg: #ffffff;
  --bg-alt: #f5f5f5;
  --bg-inverse: #111111;
  --text: #111111;
  --text-muted: #666666;
  --accent: #111111;
  --accent-alt: #111111;
  --border: #111111;
  --border-light: #dddddd;
  
  --overlay: none;
  --border-style: solid;
}

/* ============================================
   THEME: DOS
   Amber monochrome, chunky, nostalgic
   ============================================ */
[data-theme="dos"] {
  --bg: #1a1400;
  --bg-alt: #241c00;
  --bg-inverse: #ffb000;
  --text: #ffb000;
  --text-muted: #996a00;
  --accent: #ffc832;
  --accent-alt: #ffb000;
  --border: #ffb000;
  --border-light: #4d3d00;
  
  --overlay: scanlines;
  --border-style: solid;
}
```

---

## Overlay Effects

```css
/* overlays.css */

/* Scanlines - for terminal and DOS themes */
[data-theme="terminal"] body::before,
[data-theme="dos"] body::before {
  content: '';
  position: fixed;
  inset: 0;
  background: repeating-linear-gradient(
    0deg,
    rgba(0, 0, 0, 0.1),
    rgba(0, 0, 0, 0.1) 1px,
    transparent 1px,
    transparent 2px
  );
  pointer-events: none;
  z-index: 1000;
}

/* Vignette - for terminal theme */
[data-theme="terminal"] body::after {
  content: '';
  position: fixed;
  inset: 0;
  background: radial-gradient(ellipse at center, transparent 0%, rgba(0,0,0,0.3) 100%);
  pointer-events: none;
  z-index: 999;
}

/* Grid paper - for blueprint theme */
[data-theme="blueprint"] body {
  background-image: 
    linear-gradient(var(--border-light) 1px, transparent 1px),
    linear-gradient(90deg, var(--border-light) 1px, transparent 1px);
  background-size: 20px 20px;
}
```

---

## Shared Component Structure

### Layout Shell

```ruby
# app/components/layout/shell.rb
class Layout::Shell < Phlex::HTML
  def initialize(theme: "paper")
    @theme = theme
  end

  def view_template(&block)
    html do
      head { theme_assets }
      body(data: { theme: @theme }, class: "font-mono text-base bg-theme-bg text-theme-text") do
        yield
      end
    end
  end
end
```

### Header

Same component, styled by theme variables:

```ruby
# app/components/ui/header.rb
class UI::Header < Phlex::HTML
  def initialize(user:)
    @user = user
  end

  def view_template
    header(class: "border-b-2 border-theme-border px-6 py-3 flex justify-between items-center") do
      span(class: "font-bold text-sm tracking-wider") { "PATENTWATCH" }
      
      nav(class: "flex gap-6") do
        nav_link("Alerts", href: "/alerts", active: true)
        nav_link("Search", href: "/search")
        nav_link("Settings", href: "/settings")
      end
      
      span(class: "text-sm text-theme-text-muted") { @user.email }
    end
  end

  private

  def nav_link(text, href:, active: false)
    classes = "text-sm transition-colors"
    classes += active ? " text-theme-text" : " text-theme-text-muted hover:text-theme-text"
    a(href: href, class: classes) { text }
  end
end
```

### Stats Row

```ruby
# app/components/ui/stats_row.rb
class UI::StatsRow < Phlex::HTML
  def initialize(stats:)
    @stats = stats
  end

  def view_template
    div(class: "flex gap-8 py-3 text-sm") do
      @stats.each do |stat|
        render_stat(stat)
      end
    end
  end

  private

  def render_stat(stat)
    span do
      span(class: stat_value_classes(stat[:highlight])) { stat[:value] }
      span(class: "text-theme-text-muted ml-1") { stat[:label] }
    end
  end

  def stat_value_classes(highlight)
    base = "font-bold"
    highlight ? "#{base} text-theme-accent" : base
  end
end
```

### Alert List

```ruby
# app/components/alerts/list.rb
class Alerts::List < Phlex::HTML
  def initialize(alerts:)
    @alerts = alerts
  end

  def view_template
    div(class: "border border-theme-border") do
      @alerts.each_with_index do |alert, idx|
        render Alerts::Row.new(alert: alert, index: idx + 1)
      end
    end
  end
end

# app/components/alerts/row.rb
class Alerts::Row < Phlex::HTML
  def initialize(alert:, index:)
    @alert = alert
    @index = index
  end

  def view_template
    div(class: row_classes) do
      span(class: "text-sm text-theme-text-muted w-8") { format("%02d", @index) }
      
      span(class: "flex-1") do
        a(href: alert_path(@alert), class: "hover:text-theme-accent") { @alert.name }
      end
      
      span(class: count_classes) { count_text }
      span(class: "text-xs text-theme-text-muted w-16") { status_text }
      span(class: "text-xs text-theme-text-muted w-20 text-right") { time_ago(@alert.updated_at) }
    end
  end

  private

  def row_classes
    "flex items-center gap-4 px-4 py-2.5 border-b border-theme-border-light last:border-b-0 hover:bg-theme-bg-alt"
  end

  def count_classes
    base = "text-sm w-16 text-right"
    @alert.new_count > 0 ? "#{base} font-semibold text-theme-accent" : "#{base} text-theme-text-muted"
  end

  def count_text
    @alert.new_count > 0 ? "+#{@alert.new_count} new" : "0"
  end

  def status_text
    @alert.active? ? "active" : "paused"
  end
end
```

### Results Table

```ruby
# app/components/patents/results_table.rb
class Patents::ResultsTable < Phlex::HTML
  COLUMNS = [
    { key: :patent_number, label: "Patent", width: "w-32" },
    { key: :title, label: "Title", width: "flex-1" },
    { key: :assignee, label: "Assignee", width: "w-28" },
    { key: :filed_at, label: "Filed", width: "w-20" },
    { key: :match_score, label: "Match", width: "w-16" },
  ]

  def initialize(patents:)
    @patents = patents
  end

  def view_template
    div(class: "border border-theme-border text-sm") do
      header_row
      @patents.each { |patent| result_row(patent) }
    end
  end

  private

  def header_row
    div(class: "flex gap-3 px-3 py-2 bg-theme-bg-alt border-b border-theme-border text-xs uppercase tracking-wide text-theme-text-muted") do
      COLUMNS.each do |col|
        span(class: col[:width]) { col[:label] }
      end
    end
  end

  def result_row(patent)
    div(class: "flex gap-3 px-3 py-2 border-b border-theme-border-light last:border-b-0 hover:bg-theme-bg-alt") do
      span(class: "w-32 font-semibold text-theme-accent") do
        a(href: patent_path(patent)) { patent.number }
      end
      span(class: "flex-1") { patent.title }
      span(class: "w-28 text-theme-text-muted") { patent.assignee }
      span(class: "w-20 text-theme-text-muted") { patent.filed_at.strftime("%b %d") }
      span(class: "w-16 font-semibold") { "#{patent.match_score}%" }
    end
  end
end
```

### Section Header

```ruby
# app/components/ui/section_header.rb
class UI::SectionHeader < Phlex::HTML
  def initialize(title:, action: nil, action_href: nil)
    @title = title
    @action = action
    @action_href = action_href
  end

  def view_template
    div(class: "flex justify-between items-center pb-2 border-b border-theme-border-light mb-3") do
      span(class: "text-xs uppercase tracking-wider text-theme-text-muted") { @title }
      
      if @action
        a(href: @action_href, class: "text-xs text-theme-accent hover:underline") { @action }
      end
    end
  end
end
```

### Form Input

```ruby
# app/components/ui/input.rb
class UI::Input < Phlex::HTML
  def initialize(label:, name:, type: "text", required: false, placeholder: nil, value: nil, hint: nil)
    @label = label
    @name = name
    @type = type
    @required = required
    @placeholder = placeholder
    @value = value
    @hint = hint
  end

  def view_template
    div(class: "mb-4") do
      label(for: @name, class: "block text-sm font-medium mb-1.5") do
        plain @label
        span(class: "text-theme-accent") { " *" } if @required
      end
      
      input(
        type: @type,
        name: @name,
        id: @name,
        value: @value,
        placeholder: @placeholder,
        required: @required,
        class: input_classes
      )
      
      p(class: "text-xs text-theme-text-muted mt-1") { @hint } if @hint
    end
  end

  private

  def input_classes
    "w-full px-3 py-2.5 text-base bg-theme-bg border border-theme-border " \
    "focus:outline-none focus:border-theme-accent " \
    "placeholder:text-theme-text-muted"
  end
end
```

### Button

```ruby
# app/components/ui/button.rb
class UI::Button < Phlex::HTML
  def initialize(text:, variant: :secondary, type: "button", href: nil, size: :default)
    @text = text
    @variant = variant
    @type = type
    @href = href
    @size = size
  end

  def view_template
    if @href
      a(href: @href, class: button_classes) { @text }
    else
      button(type: @type, class: button_classes) { @text }
    end
  end

  private

  def button_classes
    [base_classes, variant_classes, size_classes].join(" ")
  end

  def base_classes
    "inline-flex items-center justify-center font-mono transition-colors"
  end

  def variant_classes
    case @variant
    when :primary
      "bg-theme-accent text-theme-bg border border-theme-accent hover:bg-theme-bg-inverse hover:border-theme-bg-inverse"
    when :secondary
      "bg-theme-bg border border-theme-border hover:bg-theme-bg-inverse hover:text-theme-bg"
    end
  end

  def size_classes
    case @size
    when :small
      "px-3 py-1.5 text-xs"
    when :default
      "px-4 py-2.5 text-sm"
    end
  end
end
```

### Tag

```ruby
# app/components/ui/tag.rb
class UI::Tag < Phlex::HTML
  def initialize(text:, removable: false)
    @text = text
    @removable = removable
  end

  def view_template
    span(class: "inline-flex items-center gap-1.5 px-2.5 py-1 bg-theme-bg-alt border border-theme-border-light text-sm") do
      plain @text
      if @removable
        button(type: "button", class: "opacity-50 hover:opacity-100 hover:text-theme-accent") { "×" }
      end
    end
  end
end
```

### Activity Item

```ruby
# app/components/ui/activity_item.rb
class UI::ActivityItem < Phlex::HTML
  def initialize(time:, message:)
    @time = time
    @message = message
  end

  def view_template
    div(class: "flex gap-3 py-2 border-b border-theme-border-light last:border-b-0 text-sm") do
      span(class: "text-xs text-theme-text-muted min-w-[70px]") { @time }
      span { @message }
    end
  end
end
```

### Footer

```ruby
# app/components/ui/footer.rb
class UI::Footer < Phlex::HTML
  def initialize(status:, version: "1.0")
    @status = status
    @version = version
  end

  def view_template
    footer(class: "border-t border-theme-border-light px-6 py-3 text-xs text-theme-text-muted flex justify-between") do
      div(class: "flex gap-4") do
        span(class: "flex items-center gap-1.5") do
          span(class: "w-1.5 h-1.5 rounded-full bg-theme-accent-alt")
          plain @status
        end
      end
      span { "PATENTWATCH v#{@version}" }
    end
  end
end
```

---

## Theme-Specific Additions

Some themes have optional extra components:

### Terminal: Command Bar

```ruby
# app/components/terminal/command_bar.rb (only used with terminal/dos themes)
class Terminal::CommandBar < Phlex::HTML
  def initialize(prompt: "patentwatch $")
    @prompt = prompt
  end

  def view_template
    div(class: "fixed bottom-0 inset-x-0 bg-theme-bg-alt border-t border-theme-border px-6 py-3 flex items-center gap-2") do
      span(class: "text-theme-accent") { @prompt }
      input(
        type: "text",
        class: "flex-1 bg-transparent border-none text-theme-text outline-none",
        placeholder: "type command or search..."
      )
    end
  end
end
```

### Blueprint: Section Marker

```ruby
# app/components/blueprint/section_marker.rb
class Blueprint::SectionMarker < Phlex::HTML
  def initialize(label:)
    @label = label
  end

  def view_template
    span(class: "absolute -left-8 top-0 w-6 h-6 border-2 border-theme-border bg-theme-bg flex items-center justify-center text-xs font-bold text-theme-accent") do
      @label
    end
  end
end
```

### DOS: Function Key Bar

```ruby
# app/components/dos/fn_bar.rb
class DOS::FnBar < Phlex::HTML
  KEYS = [
    { key: "F1", label: "Help" },
    { key: "F2", label: "New" },
    { key: "F3", label: "Edit" },
    { key: "F4", label: "Delete" },
    { key: "F5", label: "Refresh" },
    { key: "F10", label: "Quit" },
  ]

  def view_template
    div(class: "flex border-t-2 border-theme-border mt-4 pt-2") do
      KEYS.each do |item|
        div(class: "flex-1 text-center text-xs") do
          span(class: "bg-theme-bg-inverse text-theme-bg px-1 font-bold") { item[:key] }
          span(class: "text-theme-text-muted ml-1") { item[:label] }
        end
      end
    end
  end
end
```

---

## Page Composition Example

```ruby
# app/views/dashboard/index.rb
class Dashboard::Index < Phlex::HTML
  def initialize(user:, alerts:, recent_patents:, stats:, activities:)
    @user = user
    @alerts = alerts
    @recent_patents = recent_patents
    @stats = stats
    @activities = activities
  end

  def view_template
    render Layout::Shell.new(theme: current_theme) do
      render UI::Header.new(user: @user)
      
      main(class: "max-w-content mx-auto px-6 py-8") do
        page_header
        render UI::StatsRow.new(stats: @stats)
        alerts_section
        results_section
        activity_section
      end
      
      render UI::Footer.new(status: "USPTO connected")
      
      # Theme-specific additions
      render Terminal::CommandBar.new if terminal_theme?
      render DOS::FnBar.new if dos_theme?
    end
  end

  private

  def page_header
    div(class: "mb-6") do
      h1(class: "text-xl font-semibold") { "Your Alerts" }
      p(class: "text-sm text-theme-text-muted") { "Monitoring #{@alerts.count} keyword sets" }
    end
  end

  def alerts_section
    section(class: "mb-8") do
      render UI::SectionHeader.new(title: "Active Alerts", action: "+ New Alert", action_href: "/alerts/new")
      render Alerts::List.new(alerts: @alerts)
    end
  end

  def results_section
    section(class: "mb-8") do
      render UI::SectionHeader.new(title: "Latest Results", action: "View All →", action_href: "/patents")
      render Patents::ResultsTable.new(patents: @recent_patents)
    end
  end

  def activity_section
    section(class: "mb-8") do
      render UI::SectionHeader.new(title: "Recent Activity")
      @activities.each do |activity|
        render UI::ActivityItem.new(time: activity.time_ago, message: activity.message)
      end
    end
  end
end
```

---

## Theme Switching

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  helper_method :current_theme

  def current_theme
    # Could be user preference, stored in session, or config
    current_user&.preferred_theme || session[:theme] || "paper"
  end
end
```

```ruby
# app/controllers/settings_controller.rb
class SettingsController < ApplicationController
  def update_theme
    session[:theme] = params[:theme] if valid_theme?(params[:theme])
    redirect_back(fallback_location: root_path)
  end

  private

  def valid_theme?(theme)
    %w[paper terminal blueprint brutalist dos].include?(theme)
  end
end
```

---

## File Structure

```
app/
├── components/
│   ├── layout/
│   │   └── shell.rb
│   ├── ui/
│   │   ├── header.rb
│   │   ├── footer.rb
│   │   ├── section_header.rb
│   │   ├── stats_row.rb
│   │   ├── button.rb
│   │   ├── input.rb
│   │   ├── tag.rb
│   │   └── activity_item.rb
│   ├── alerts/
│   │   ├── list.rb
│   │   └── row.rb
│   ├── patents/
│   │   ├── results_table.rb
│   │   └── detail.rb
│   ├── terminal/          # Theme-specific
│   │   └── command_bar.rb
│   ├── blueprint/         # Theme-specific
│   │   └── section_marker.rb
│   └── dos/               # Theme-specific
│       └── fn_bar.rb
├── views/
│   ├── dashboard/
│   │   └── index.rb
│   ├── alerts/
│   │   ├── index.rb
│   │   ├── show.rb
│   │   └── new.rb
│   └── patents/
│       ├── index.rb
│       └── show.rb
└── assets/
    └── stylesheets/
        ├── application.css
        ├── themes.css        # All theme variables
        └── overlays.css      # Scanlines, grid, etc.
```

---

## Summary

**Shared across all themes:**
- All Phlex components
- Layout structure
- Typography scale
- Spacing system
- Interaction patterns

**Per-theme customization:**
- 9 CSS variables (colors)
- 1-2 overlay effects
- 2-3 optional decorative components

**Switching themes:**
- Single `data-theme` attribute on body
- User preference stored in session/DB
- Zero JavaScript required for base theming

This gives you one codebase with five distinct visual personalities. The coding agent builds components once, and themes are just CSS.
