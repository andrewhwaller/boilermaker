# PATENTWATCH Design System v2
## Dense, Readable, Industrial

---

## Core Philosophy

**Less chrome, more content.** This is a tool for professionals who want to scan information quickly. Inspired by:
- Terminal interfaces and data sheets
- Old-school computing: dense, readable, functional
- US Graphics Company aesthetic: monospace, industrial, precise

**Principles:**
1. Single-column layouts where possible
2. No sidebars — information flows vertically  
3. Dense but readable — tight spacing, not cramped
4. Minimal borders — use sparingly for structure
5. Color is functional, not decorative
6. Everything is a link or actionable

---

## Color Palette

```javascript
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: {
        'paper': '#f5f3ef',      // Primary background
        'paper-alt': '#eae7e1',  // Secondary/hover background
        'ink': '#1a1a18',        // Primary text
        'ink-muted': '#6a6965',  // Secondary text
        'rust': '#c54b32',       // Accent / links / CTAs
        'forest': '#2d5a4a',     // Success / active status
        'ochre': '#b8860b',      // Warning / pending
        'border': '#1a1a18',     // Heavy borders
        'border-light': '#d4d1ca', // Light dividers
      }
    }
  }
}
```

| Use | Color | Tailwind |
|-----|-------|----------|
| Page background | paper | `bg-paper` |
| Hover/alt backgrounds | paper-alt | `bg-paper-alt` |
| Primary text | ink | `text-ink` |
| Secondary/muted text | ink-muted | `text-ink-muted` |
| Links, IDs, accents | rust | `text-rust` |
| Active status | forest | `text-forest` or `bg-forest` |
| Pending status | ochre | `bg-ochre` |
| Section borders | border | `border-border` |
| Row dividers | border-light | `border-border-light` |

---

## Typography

### Font
```html
<link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500;600;700&display=swap" rel="stylesheet">
```

```css
font-family: 'IBM Plex Mono', monospace;
```

### Scale

| Element | Size | Weight | Tailwind |
|---------|------|--------|----------|
| Page title | 18px | 600 | `text-lg font-semibold` |
| Patent title | 16px | 500 | `text-base font-medium` |
| Body text | 13px | 400 | `text-[13px]` |
| Table/list text | 12px | 400 | `text-xs` |
| Labels/headers | 11px | 400 | `text-[11px] uppercase tracking-wider` |
| Tiny labels | 10px | 400 | `text-[10px] uppercase tracking-wide` |

### Text Patterns

```html
<!-- Page Title -->
<h1 class="text-lg font-semibold">Your Alerts</h1>

<!-- Section Label -->
<span class="text-[11px] uppercase tracking-wider text-ink-muted">Active Alerts</span>

<!-- Body Text -->
<p class="text-[13px] text-ink leading-relaxed">...</p>

<!-- Muted Meta -->
<span class="text-xs text-ink-muted">Dec 18, 2024</span>

<!-- Link -->
<a class="text-rust hover:underline">View All →</a>
```

---

## Layout

### Page Structure
```html
<body class="font-mono bg-paper text-ink text-[13px]">
  <header class="border-b-2 border-border px-6 py-3 flex justify-between items-center">
    <!-- Compact header -->
  </header>
  
  <main class="max-w-4xl mx-auto px-6 py-8">
    <!-- Single column content -->
  </main>
  
  <footer class="border-t border-border-light px-6 py-3 text-[10px] text-ink-muted">
    <!-- Status bar -->
  </footer>
</body>
```

### Max Widths
- **Lists/Tables:** `max-w-4xl` (1000px)
- **Forms:** `max-w-xl` (640px)  
- **Login:** `max-w-sm` (360px)

---

## Components

### Compact Header
```html
<header class="border-b-2 border-border px-6 py-3 flex justify-between items-center">
  <span class="font-bold text-sm tracking-wider">PATENTWATCH</span>
  
  <nav class="flex gap-6">
    <a href="#" class="text-xs text-ink-muted hover:text-ink">Alerts</a>
    <a href="#" class="text-xs text-ink">Search</a>
    <a href="#" class="text-xs text-ink-muted hover:text-ink">Settings</a>
  </nav>
  
  <span class="text-xs text-ink-muted">user@company.com</span>
</header>
```

### Section Header
```html
<div class="flex justify-between items-center pb-2 border-b border-border-light mb-3">
  <span class="text-[11px] uppercase tracking-wider text-ink-muted">Section Title</span>
  <a href="#" class="text-[11px] text-rust hover:underline">Action →</a>
</div>
```

### Alert Row (Dense List)
```html
<div class="border border-border">
  <div class="grid grid-cols-[1fr_auto_auto_auto] gap-6 px-3.5 py-2.5 border-b border-border-light items-center hover:bg-paper-alt">
    <a href="#" class="font-medium text-ink hover:text-rust">Machine Learning — Image Recognition</a>
    <span class="text-xs text-rust font-semibold">23 new</span>
    <span class="text-[11px] text-ink-muted flex items-center gap-1.5">
      <span class="w-1.5 h-1.5 rounded-full bg-forest"></span>
      Active
    </span>
    <span class="text-[11px] text-ink-muted text-right">2 min ago</span>
  </div>
  <!-- more rows -->
</div>
```

### Results Table (Dense)
```html
<table class="w-full border border-border text-xs">
  <thead>
    <tr class="bg-paper-alt">
      <th class="text-left px-3 py-2 text-[10px] uppercase tracking-wide text-ink-muted font-medium border-b border-border">Patent</th>
      <th class="text-left px-3 py-2 text-[10px] uppercase tracking-wide text-ink-muted font-medium border-b border-border">Title</th>
      <th class="text-left px-3 py-2 text-[10px] uppercase tracking-wide text-ink-muted font-medium border-b border-border">Assignee</th>
      <th class="text-left px-3 py-2 text-[10px] uppercase tracking-wide text-ink-muted font-medium border-b border-border">Filed</th>
      <th class="text-left px-3 py-2 text-[10px] uppercase tracking-wide text-ink-muted font-medium border-b border-border">Match</th>
    </tr>
  </thead>
  <tbody>
    <tr class="hover:bg-paper-alt">
      <td class="px-3 py-2 border-b border-border-light font-semibold text-rust whitespace-nowrap">
        <a href="#" class="hover:underline">US20240401234</a>
      </td>
      <td class="px-3 py-2 border-b border-border-light">Neural Network Architecture for Real-Time Object Detection...</td>
      <td class="px-3 py-2 border-b border-border-light text-ink-muted">Google LLC</td>
      <td class="px-3 py-2 border-b border-border-light text-ink-muted">Dec 18</td>
      <td class="px-3 py-2 border-b border-border-light font-semibold">94%</td>
    </tr>
  </tbody>
</table>
```

### Form Input
```html
<div class="mb-4">
  <label class="block text-xs font-medium mb-1.5">
    Field Label <span class="text-rust">*</span>
  </label>
  <input 
    type="text" 
    class="w-full px-3 py-2.5 text-[13px] bg-paper border border-border
           focus:outline-none focus:border-rust
           placeholder:text-ink-muted"
    placeholder="Placeholder..."
  >
  <p class="text-[11px] text-ink-muted mt-1">Helper text.</p>
</div>
```

### Button
```html
<!-- Primary -->
<button class="px-4 py-2.5 text-xs bg-ink text-paper border border-ink hover:bg-rust hover:border-rust">
  Create Alert →
</button>

<!-- Secondary -->
<button class="px-4 py-2.5 text-xs bg-paper border border-border hover:bg-ink hover:text-paper">
  Cancel
</button>

<!-- Small -->
<button class="px-3 py-1.5 text-[11px] bg-paper border border-border hover:bg-ink hover:text-paper">
  Export
</button>
```

### Tag
```html
<span class="inline-flex items-center gap-1.5 px-2.5 py-1 bg-paper-alt border border-border-light text-xs">
  machine learning
  <span class="cursor-pointer opacity-50 hover:opacity-100 hover:text-rust">×</span>
</span>
```

### Classification Tag
```html
<span class="px-2.5 py-1.5 bg-paper-alt border border-border-light text-[11px]">
  <span class="font-bold mr-1.5">G06N</span>
  <span class="text-ink-muted">Computing</span>
</span>
```

### Toggle Row
```html
<div class="flex border border-border">
  <div class="flex-1 px-3 py-2 text-xs text-center cursor-pointer hover:bg-paper-alt">All (AND)</div>
  <div class="flex-1 px-3 py-2 text-xs text-center cursor-pointer bg-ink text-paper border-l border-border">Any (OR)</div>
  <div class="flex-1 px-3 py-2 text-xs text-center cursor-pointer hover:bg-paper-alt border-l border-border">Exact</div>
</div>
```

### Checkbox
```html
<label class="flex items-center gap-2 cursor-pointer text-xs">
  <span class="w-4 h-4 border border-border flex items-center justify-center text-[9px] bg-ink text-paper">✓</span>
  Remember me
</label>
```

### Match Banner
```html
<div class="flex justify-between items-center px-4 py-3 bg-ink text-paper text-xs mb-6">
  <div>
    <span class="text-lg font-bold text-rust">94%</span> match confidence
  </div>
  <div class="flex gap-5 opacity-70">
    <span>Keyword: <strong class="opacity-100">96%</strong></span>
    <span>CPC: <strong class="opacity-100">100%</strong></span>
    <span>Semantic: <strong class="opacity-100">89%</strong></span>
  </div>
</div>
```

### Activity Item
```html
<div class="flex gap-3 py-2 border-b border-border-light text-xs">
  <span class="text-[11px] text-ink-muted min-w-[70px]">2 min ago</span>
  <span><strong>ML Image Recognition</strong> — 23 new patents matched</span>
</div>
```

### Footer Status Bar
```html
<footer class="border-t border-border-light px-6 py-3 text-[10px] text-ink-muted flex justify-between">
  <div class="flex gap-4">
    <span class="flex items-center gap-1.5">
      <span class="w-1.5 h-1.5 bg-forest rounded-full"></span>
      USPTO connected
    </span>
    <span>Last sync: 2 min ago</span>
    <span>18.4M patents indexed</span>
  </div>
  <span>PATENTWATCH v1.0</span>
</footer>
```

---

## Spacing Reference

Use Tailwind's default spacing scale. Common values:

| Use | Size | Tailwind |
|-----|------|----------|
| Tight inline gap | 4px | `gap-1` |
| Standard gap | 8px | `gap-2` |
| Comfortable gap | 12px | `gap-3` |
| Section gap | 16px | `gap-4` |
| Table cell padding | 8-12px | `px-3 py-2` |
| Form field margin | 16px | `mb-4` |
| Section margin | 28px | `mb-7` |
| Page padding | 24-32px | `px-6 py-8` |

---

## State Guidelines

### Hover
- Backgrounds: `hover:bg-paper-alt`
- Text: `hover:text-ink` or `hover:text-rust`
- Links: `hover:underline`

### Focus
- Inputs: `focus:outline-none focus:border-rust`

### Active/Selected
- Nav: Just darker text, no background
- Toggle: `bg-ink text-paper`
- List item: Border accent or background change

### Status Indicators
- Active: `bg-forest` (small dot)
- Paused: `bg-ink-muted` (small dot)
- Pending: `bg-ochre`

---

## File Structure for Phlex

```
app/
├── views/
│   ├── layouts/
│   │   └── application_layout.rb
│   ├── dashboard/
│   │   └── index.rb
│   ├── alerts/
│   │   ├── index.rb
│   │   ├── show.rb
│   │   └── new.rb
│   ├── patents/
│   │   ├── index.rb
│   │   └── show.rb
│   └── sessions/
│       └── new.rb
├── components/
│   ├── header.rb
│   ├── footer.rb
│   ├── section_header.rb
│   ├── alert_row.rb
│   ├── patent_row.rb
│   ├── button.rb
│   ├── input.rb
│   ├── tag.rb
│   └── status_dot.rb
```

---

## Key Differences from v1

1. **No sidebars** — Everything single-column
2. **Denser rows** — Less padding, more data per screen
3. **Fewer borders** — Only where structurally necessary
4. **Simpler header** — Logo + nav + user, no logo boxes
5. **Inline stats** — Not boxed, just labeled values
6. **Lighter footer** — Single line status bar
7. **Narrower forms** — 640px max instead of full width

---

*Keep it dense. Keep it readable. Get out of the way.*
