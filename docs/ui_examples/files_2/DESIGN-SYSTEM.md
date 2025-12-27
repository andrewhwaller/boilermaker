# PATENTWATCH Design System
## USPTO Patent Alert Application — Industrial Minimal Aesthetic

---

## Design Philosophy

Inspired by **US Graphics Company** and the golden era of computing. The aesthetic evokes:
- Mid-century industrial design (Sennheiser, Bridgeport, Starrett)
- Vintage computing interfaces (CRT terminals, control panels)
- Engineering graphics and technical documentation
- Machine-readable typefaces and monospace typography

**Core Principles:**
1. **Functional first** — Every element serves a purpose
2. **Industrial precision** — Grid-based, measured, calibrated
3. **Monospace typography** — Code-like, technical, readable
4. **Muted earth tones** — Warm paper colors, not clinical white
5. **Bold borders** — Heavy 2px borders define structure
6. **Minimal decoration** — No gradients, shadows are rare

---

## Color Palette

### Tailwind Config Extension

```javascript
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: {
        // Backgrounds
        'paper': {
          100: '#f5f3ef', // Primary background (warm off-white)
          200: '#eae7e1', // Secondary background (light tan)
          300: '#ddd9d0', // Tertiary background (darker tan)
        },
        // Text
        'ink': {
          900: '#1a1a18', // Primary text (near-black)
          700: '#5a5955', // Secondary text
          500: '#8a8884', // Muted text
        },
        // Accents
        'rust': '#c54b32',      // Primary accent (rust red)
        'forest': '#2d5a4a',    // Secondary accent (dark green)
        'ochre': '#b8860b',     // Warning/pending (dark gold)
        // Borders
        'border': {
          dark: '#1a1a18',
          light: '#c4c1ba',
        }
      },
      fontFamily: {
        'mono': ['IBM Plex Mono', 'JetBrains Mono', 'Menlo', 'monospace'],
      },
      fontSize: {
        'xxs': '9px',
        'xs': '10px',
        'sm': '11px',
        'base': '13px',
        'lg': '14px',
        'xl': '18px',
        '2xl': '24px',
        '3xl': '32px',
        '4xl': '42px',
      },
      letterSpacing: {
        'tight': '-0.02em',
        'normal': '0',
        'wide': '0.05em',
        'wider': '0.08em',
        'widest': '0.1em',
        'ultra': '0.12em',
      },
      borderWidth: {
        '1': '1px',
        '2': '2px',
        '3': '3px',
      }
    }
  }
}
```

### Color Usage Guidelines

| Element | Color | Tailwind Class |
|---------|-------|----------------|
| Page background | paper-100 | `bg-paper-100` |
| Secondary panels | paper-200 | `bg-paper-200` |
| Tertiary/headers | paper-300 | `bg-paper-300` |
| Dark panels | ink-900 | `bg-ink-900 text-paper-100` |
| Primary text | ink-900 | `text-ink-900` |
| Secondary text | ink-700 | `text-ink-700` |
| Muted text | ink-500 | `text-ink-500` |
| Primary accent | rust | `text-rust` or `bg-rust` |
| Success/active | forest | `text-forest` or `bg-forest` |
| Warning/pending | ochre | `text-ochre` or `bg-ochre` |
| Heavy borders | border-dark | `border-border-dark border-2` |
| Light borders | border-light | `border-border-light border-1` |

---

## Typography

### Font Stack
```css
font-family: 'IBM Plex Mono', 'JetBrains Mono', 'Menlo', 'Monaco', 'Consolas', monospace;
```

Add to layout:
```html
<link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500;600;700&display=swap" rel="stylesheet">
```

### Type Scale

| Use Case | Size | Weight | Spacing | Tailwind |
|----------|------|--------|---------|----------|
| Page headings | 32px | 700 | -0.02em | `text-3xl font-bold tracking-tight` |
| Section headings | 24px | 700 | -0.01em | `text-2xl font-bold` |
| Card titles | 14px | 600 | 0 | `text-lg font-semibold` |
| Body text | 13px | 400 | 0 | `text-base` |
| Labels/meta | 10px | 400 | 0.08em | `text-xs uppercase tracking-wider` |
| Tiny labels | 9px | 400 | 0.08em | `text-xxs uppercase tracking-wider` |
| Nav items | 11px | 400 | 0.08em | `text-sm uppercase tracking-wider` |

### Text Styles (Reusable Classes)

```html
<!-- Page Title -->
<h1 class="font-mono text-3xl font-bold tracking-tight text-ink-900">Dashboard</h1>

<!-- Section Label -->
<span class="font-mono text-xs uppercase tracking-widest text-ink-500">Overview</span>

<!-- Nav Item -->
<a class="font-mono text-sm uppercase tracking-wider text-ink-700 hover:text-ink-900">Alerts</a>

<!-- Body Text -->
<p class="font-mono text-base text-ink-900 leading-relaxed">Content here...</p>

<!-- Muted Helper Text -->
<span class="font-mono text-sm text-ink-500">Optional description</span>
```

---

## Layout Patterns

### Header
```html
<header class="border-b-2 border-border-dark grid grid-cols-[auto_1fr_auto]">
  <!-- Logo Block -->
  <div class="border-r-2 border-border-dark px-6 py-4 flex items-center gap-3">
    <div class="w-8 h-8 bg-ink-900 flex items-center justify-center text-paper-100 font-bold text-sm">PW</div>
    <div>
      <div class="font-mono text-sm font-bold uppercase tracking-widest">Patentwatch</div>
      <div class="font-mono text-xxs text-ink-500 tracking-wide">USPTO Alert System</div>
    </div>
  </div>
  
  <!-- Navigation -->
  <nav class="flex items-stretch">
    <a href="#" class="px-6 py-4 border-r border-border-light font-mono text-sm uppercase tracking-wider text-ink-700 hover:bg-paper-200 hover:text-ink-900">Dashboard</a>
    <a href="#" class="px-6 py-4 border-r border-border-light font-mono text-sm uppercase tracking-wider bg-ink-900 text-paper-100">Alerts</a>
    <!-- ... more nav items -->
  </nav>
  
  <!-- User Block -->
  <div class="border-l-2 border-border-dark px-6 py-4 flex items-center gap-3">
    <div class="w-2 h-2 bg-forest rounded-full"></div>
    <span class="font-mono text-base">user@company.com</span>
  </div>
</header>
```

### Three-Column Dashboard
```html
<div class="grid grid-cols-[280px_1fr_320px] min-h-[calc(100vh-66px)]">
  <!-- Sidebar -->
  <aside class="border-r-2 border-border-dark bg-paper-200">...</aside>
  
  <!-- Main Content -->
  <main class="p-8 bg-paper-100">...</main>
  
  <!-- Activity Panel -->
  <aside class="border-l-2 border-border-dark bg-paper-200">...</aside>
</div>
```

### Form Page (Centered)
```html
<div class="max-w-[900px] mx-auto px-8 py-12">
  <header class="mb-12">
    <div class="font-mono text-xs uppercase tracking-widest text-ink-500 mb-4">
      <a href="#">Dashboard</a> <span class="mx-2">→</span> <span>New Alert</span>
    </div>
    <h1 class="font-mono text-3xl font-bold tracking-tight mb-2">Create New Alert</h1>
    <p class="font-mono text-lg text-ink-700">Configure your patent monitoring criteria.</p>
  </header>
  
  <!-- Form sections here -->
</div>
```

---

## Components

### Form Section
```html
<section class="bg-paper-200 border-2 border-border-dark mb-6">
  <div class="bg-ink-900 text-paper-100 px-6 py-4 flex justify-between items-center">
    <span class="font-mono text-sm font-semibold uppercase tracking-wider">Section Title</span>
    <span class="font-mono text-xs opacity-60">01</span>
  </div>
  <div class="p-6">
    <!-- Form fields here -->
  </div>
</section>
```

### Form Input
```html
<div class="mb-6">
  <label class="block font-mono text-xs uppercase tracking-wider text-ink-500 mb-2">
    Field Label <span class="text-rust">*</span>
  </label>
  <input 
    type="text" 
    class="w-full px-4 py-3 font-mono text-lg bg-paper-100 border border-border-dark text-ink-900 
           focus:outline-none focus:border-rust focus:ring-2 focus:ring-rust/10
           placeholder:text-ink-500"
    placeholder="Placeholder text..."
  >
  <p class="font-mono text-sm text-ink-500 mt-2">Helper text goes here.</p>
</div>
```

### Button - Primary
```html
<button class="bg-rust text-paper-100 px-6 py-3 font-mono text-sm uppercase tracking-wider
               hover:bg-ink-900 transition-colors">
  Create Alert →
</button>
```

### Button - Secondary
```html
<button class="bg-paper-100 border border-border-dark px-6 py-3 font-mono text-sm uppercase tracking-wider
               hover:bg-ink-900 hover:text-paper-100 transition-colors">
  Cancel
</button>
```

### Stat Box
```html
<div class="bg-paper-100 border border-border-dark p-3">
  <div class="font-mono text-xxs uppercase tracking-wider text-ink-500 mb-1">Active Alerts</div>
  <div class="font-mono text-2xl font-bold">12</div>
</div>

<!-- Highlighted variant -->
<div class="bg-paper-100 border border-border-dark p-3">
  <div class="font-mono text-xxs uppercase tracking-wider text-ink-500 mb-1">New Matches</div>
  <div class="font-mono text-2xl font-bold text-rust">47</div>
</div>
```

### Alert List Item
```html
<div class="px-5 py-4 border-b border-border-light hover:bg-paper-100 hover:pl-6 cursor-pointer transition-all">
  <div class="font-mono text-base font-semibold mb-1">Machine Learning — Image Recognition</div>
  <div class="font-mono text-xs text-ink-500 flex gap-3">
    <span class="flex items-center gap-1">
      <span class="w-1.5 h-1.5 bg-forest rounded-full"></span>
      Active
    </span>
    <span>23 new</span>
  </div>
</div>

<!-- Selected state -->
<div class="px-5 py-4 border-b border-border-light border-l-3 border-l-rust bg-paper-100">
  <!-- ... same content ... -->
</div>
```

### Data Table
```html
<div class="bg-paper-200 border-2 border-border-dark">
  <div class="px-5 py-4 border-b-2 border-border-dark flex justify-between items-center">
    <span class="font-mono text-base font-semibold">23 New Patents Found</span>
    <div class="flex gap-2">
      <button class="bg-paper-100 border border-border-dark px-3 py-1.5 font-mono text-xs hover:bg-ink-900 hover:text-paper-100">Export CSV</button>
      <button class="bg-paper-100 border border-border-dark px-3 py-1.5 font-mono text-xs hover:bg-ink-900 hover:text-paper-100">Filter</button>
    </div>
  </div>
  
  <table class="w-full">
    <thead>
      <tr class="bg-paper-300">
        <th class="text-left px-4 py-3 font-mono text-xxs uppercase tracking-wider text-ink-500 border-b border-border-light">Patent ID</th>
        <th class="text-left px-4 py-3 font-mono text-xxs uppercase tracking-wider text-ink-500 border-b border-border-light">Title</th>
        <th class="text-left px-4 py-3 font-mono text-xxs uppercase tracking-wider text-ink-500 border-b border-border-light">Assignee</th>
        <th class="text-left px-4 py-3 font-mono text-xxs uppercase tracking-wider text-ink-500 border-b border-border-light">Filed</th>
      </tr>
    </thead>
    <tbody>
      <tr class="hover:bg-paper-100">
        <td class="px-4 py-4 border-b border-border-light font-mono text-base font-semibold text-rust">US20240401234</td>
        <td class="px-4 py-4 border-b border-border-light font-mono text-base max-w-xs">Neural Network Architecture...</td>
        <td class="px-4 py-4 border-b border-border-light font-mono text-base">Google LLC</td>
        <td class="px-4 py-4 border-b border-border-light font-mono text-sm text-ink-500">2024-12-18</td>
      </tr>
    </tbody>
  </table>
</div>
```

### Tag/Badge
```html
<!-- Keyword Tag -->
<span class="inline-flex items-center gap-2 bg-paper-100 border border-border-dark px-3 py-1.5 font-mono text-base">
  machine learning
  <span class="cursor-pointer opacity-50 hover:opacity-100 hover:text-rust">×</span>
</span>

<!-- Status Badge -->
<span class="bg-ink-900 text-paper-100 px-2 py-0.5 font-mono text-xxs uppercase">12</span>

<!-- Classification Tag -->
<span class="bg-paper-200 border border-border-dark px-3 py-2 font-mono text-sm">
  <span class="font-bold mr-2">G06N</span>
  <span class="text-ink-500">Computing Arrangements</span>
</span>
```

### Activity Feed Item
```html
<div class="px-5 py-4 border-b border-border-light">
  <div class="font-mono text-xxs uppercase tracking-wide text-ink-500 mb-2">2 minutes ago</div>
  <p class="font-mono text-base leading-relaxed">
    Alert <span class="text-rust font-semibold">"ML Image Recognition"</span> found 23 new matching patents
  </p>
  <span class="inline-block mt-2 bg-paper-100 border border-border-dark px-2 py-0.5 font-mono text-xxs uppercase">New Results</span>
</div>
```

### Footer Status Bar
```html
<footer class="fixed bottom-0 left-0 right-0 bg-ink-900 text-paper-100 px-6 py-2 font-mono text-xs flex justify-between items-center">
  <div class="flex items-center gap-4">
    <span class="flex items-center gap-2">
      <span class="w-1.5 h-1.5 bg-green-400 rounded-full animate-pulse"></span>
      USPTO Connected
    </span>
    <span>Last sync: 2 min ago</span>
    <span>Database: 18.4M patents</span>
  </div>
  <span class="text-ink-500">PATENTWATCH v1.0.0</span>
</footer>
```

---

## Interactive States

### Hover States
- Nav items: `hover:bg-paper-200 hover:text-ink-900`
- List items: `hover:bg-paper-100 hover:pl-6` (with transition)
- Table rows: `hover:bg-paper-100`
- Buttons: `hover:bg-ink-900 hover:text-paper-100`

### Focus States
- Inputs: `focus:outline-none focus:border-rust focus:ring-2 focus:ring-rust/10`
- Buttons: `focus:outline-none focus:ring-2 focus:ring-rust focus:ring-offset-2`

### Active/Selected States
- Nav: `bg-ink-900 text-paper-100`
- List item: `border-l-3 border-l-rust bg-paper-100`
- Toggle: `bg-ink-900 text-paper-100`
- Checkbox checked: `bg-forest border-forest text-paper-100`

### Disabled States
- Buttons: `opacity-50 cursor-not-allowed`
- Inputs: `bg-paper-300 text-ink-500 cursor-not-allowed`

---

## Responsive Breakpoints

```javascript
// Use Tailwind defaults but design mobile-first
// sm: 640px - Stack sidebar below content
// md: 768px - Show sidebar in drawer
// lg: 1024px - Full three-column layout
// xl: 1280px - Max content width
```

### Mobile Adaptations
- Header: Collapse to hamburger menu
- Three-column → Single column with bottom nav
- Side panels → Slide-out drawers
- Tables → Card-based list view

---

## Animation Guidelines

Keep animations **minimal and functional**:

```css
/* Standard transition */
transition: all 0.15s ease;

/* Pulse for status indicators */
@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}
.animate-pulse { animation: pulse 2s infinite; }
```

**Use sparingly:**
- Hover state transitions (0.15s)
- Focus ring transitions
- Slide-in for panels/drawers
- Pulse for live status indicators

**Avoid:**
- Decorative animations
- Page transition effects
- Loading spinners (use skeleton or progress bars)
- Bounce/elastic effects

---

## File Structure for Rails/Phlex

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
│   │   ├── new.rb
│   │   └── edit.rb
│   └── patents/
│       ├── index.rb
│       └── show.rb
├── components/
│   ├── ui/
│   │   ├── button.rb
│   │   ├── input.rb
│   │   ├── table.rb
│   │   ├── tag.rb
│   │   ├── stat_box.rb
│   │   └── status_badge.rb
│   ├── navigation/
│   │   ├── header.rb
│   │   ├── sidebar.rb
│   │   └── footer_bar.rb
│   ├── alerts/
│   │   ├── list_item.rb
│   │   └── form_section.rb
│   └── patents/
│       ├── result_row.rb
│       └── detail_sidebar.rb
```

---

## Implementation Notes

1. **Typography is everything** — The monospace font is the soul of this design
2. **Borders define structure** — Use 2px for major divisions, 1px for minor
3. **Color is minimal** — Rust red for accents/CTAs, forest green for success states
4. **White space is generous** — Don't crowd elements
5. **Everything aligns to a grid** — Keep spacing consistent (multiples of 4px)
6. **No rounded corners** — All elements are sharp rectangles
7. **Labels are always uppercase** — Micro labels use extra tracking

---

*Design inspired by US Graphics Company (usgraphics.com) — Berkeley Mono aesthetic*
