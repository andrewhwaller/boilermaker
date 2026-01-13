# Blackbox Theme Specification

**Version:** 1.0
**Status:** Draft
**Created:** 2026-01-11

---

## Overview

Blackbox is a utilitarian, information-dense UI theme for Wallhack Industries applications. It prioritizes function over decoration, clarity over cleverness, and density over whitespace.

### Design Philosophy

- **Tool energy:** This is software for getting work done, not a toy or marketing site
- **BMW-level refinement:** Solid, functional, practically useful—with evident quality underneath
- **Competence signal:** Users should immediately perceive "someone capable built this"
- **Information density:** Maximize useful content per screen. This is the primary success metric.

### What This Is Not

- Not corporate/enterprise design (no LinkedIn, Teams, Salesforce vibes)
- Not shadcn/Tailwind UI generic (avoid the "vibecoded" look)
- Not over-designed (no decorative elements, no visual flourishes)
- Not whimsical (no playful touches, no personality through decoration)

---

## Visual Language

### Typography

**Font Stack:** Monospace

```css
font-family: ui-monospace, SFMono-Regular, "SF Mono", Menlo, Consolas, monospace;
```

This reinforces the tool/terminal aesthetic and pairs well with the dense, structural approach.

**Type Scale:** Minimal, 3-4 sizes only

| Token | Use Case |
|-------|----------|
| `text-sm` | Secondary info, captions, metadata |
| `text-base` | Body text, form labels, most content |
| `text-lg` | Section headers, primary headings |
| `text-xl` | Page titles (use sparingly) |

**Hierarchy:** Established through both size AND weight. Headers are larger and bolder than body text.

**Links:** Always underlined. No exceptions. Color alone is not sufficient differentiation.

### Colors

**Palette:** Grayscale + semantic colors only. No accent color.

```css
:root {
  /* Grayscale - Light Mode */
  --color-bg: #ffffff;
  --color-bg-subtle: #f5f5f5;
  --color-bg-muted: #e5e5e5;
  --color-border: #d4d4d4;
  --color-text: #171717;
  --color-text-muted: #525252;
  --color-text-subtle: #737373;

  /* Grayscale - Dark Mode */
  --color-bg-dark: #0a0a0a;
  --color-bg-subtle-dark: #171717;
  --color-bg-muted-dark: #262626;
  --color-border-dark: #404040;
  --color-text-dark: #fafafa;
  --color-text-muted-dark: #a3a3a3;
  --color-text-subtle-dark: #737373;

  /* Semantic - Same in both modes */
  --color-error: #dc2626;
  --color-warning: #ca8a04;
  --color-success: #16a34a;
  --color-info: #2563eb;
}
```

**Color Usage Rules:**
- Color is an event, not decoration
- Only use semantic colors for their intended purpose (errors, warnings, success states)
- No colored backgrounds for sections or cards
- No accent colors for branding or visual interest

### Accessibility

- **Minimum:** WCAG AA (4.5:1 contrast for normal text)
- **Target:** WCAG AAA (7:1) for key text (headings, primary actions, critical information)
- Focus indicators: Subtle but present (not loud outlines, but clearly visible)

### Borders & Structure

**Corner Radius:** 0px everywhere. Square corners only.

**Border Weight:** 1px everywhere. Consistent hairline borders.

**Element Separation:**
- Hard borders for defining boundaries
- Avoid card proliferation—not everything needs a box around it
- Background color shifts acceptable for grouping related content
- Context-dependent: use what serves clarity, not decoration

```css
/* Standard border */
border: 1px solid var(--color-border);

/* No shadows, no elevation for cards */
box-shadow: none;
```

### Spacing

Use Tailwind utility classes. Do not create custom spacing values.

**Density:** Compact. Err on the side of less whitespace, more information.

Prefer smaller spacing values:
- `p-2`, `p-3` for internal padding
- `gap-2`, `gap-3` for grid/flex gaps
- `space-y-2`, `space-y-3` for stacked elements

Avoid excessive padding (`p-8`, `p-12`) except for major layout boundaries.

### Icons

**None.** This is a text-only interface.

- No decorative icons
- No icon-only buttons
- No icons in navigation
- Text labels for everything

The only exception: File type indicators if genuinely necessary for comprehension, evaluated case-by-case.

---

## Components

### Buttons

**Philosophy:** Links are preferred. Buttons only when an action genuinely requires one.

**Primary Button:** Solid fill, no border radius, text centered

```css
.btn-primary {
  background-color: var(--color-text);
  color: var(--color-bg);
  padding: 0.5rem 1rem;
  border: none;
  cursor: pointer;
}

.btn-primary:hover {
  opacity: 0.9;
}
```

**Secondary/Ghost:** Outlined or text-only, used for less important actions

**Sizing:** Compact. Don't make buttons larger than necessary.

### Form Inputs

**Philosophy:** Leverage HTML primitives. Native browser behavior over custom implementations.

```css
input, select, textarea {
  border: 1px solid var(--color-border);
  padding: 0.5rem;
  background: var(--color-bg);
  color: var(--color-text);
}

input:focus, select:focus, textarea:focus {
  outline: 1px solid var(--color-text);
  outline-offset: 1px;
}
```

**Dropdowns/Selects:** Use native `<select>` elements. No custom dropdown components.

**Checkboxes/Radio:** Use native elements with minimal styling.

### Tables

**Grid Style:** Clear cell boundaries with grid lines

```css
table {
  border-collapse: collapse;
  width: 100%;
}

th, td {
  border: 1px solid var(--color-border);
  padding: 0.5rem;
}

th {
  font-weight: 600;
  text-align: left;
  background-color: var(--color-bg-subtle);
}

tr:hover {
  background-color: var(--color-bg-subtle);
}
```

**Alignment:** Type-aware
- Text columns: left-aligned
- Numeric columns: right-aligned
- Date columns: center-aligned (or left, depending on format)

**Density:** Tight row padding. Maximize visible rows.

### Navigation

**Support Both Patterns:**
- Fixed or collapsible sidebar
- Top bar with dropdowns

Implementation should allow either based on application context.

**No icons in navigation.** Text labels only.

### Modals & Overlays

Slight elevation acceptable for modals:

```css
.modal {
  background: var(--color-bg);
  border: 1px solid var(--color-border);
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
}

.modal-backdrop {
  background: rgba(0, 0, 0, 0.3);
}
```

Modal content follows all other Blackbox rules (dense, no decoration, etc.)

### Notifications & Alerts

**Style:** Top banner, full width

```css
.notification {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  padding: 0.75rem 1rem;
  border-bottom: 1px solid var(--color-border);
}

.notification-error { background: var(--color-error); color: white; }
.notification-warning { background: var(--color-warning); color: white; }
.notification-success { background: var(--color-success); color: white; }
.notification-info { background: var(--color-info); color: white; }
```

### Code Blocks

Minimal styling. Background only, no syntax highlighting.

```css
pre, code {
  font-family: ui-monospace, SFMono-Regular, "SF Mono", Menlo, monospace;
  background: var(--color-bg-subtle);
  padding: 0.125rem 0.25rem;
}

pre {
  padding: 1rem;
  overflow-x: auto;
}
```

### Empty States, Loading States, Error States

**Extremely minimal.** Text only.

```html
<!-- Empty state -->
<p>No items found.</p>

<!-- Loading state -->
<p>Loading...</p>

<!-- Error state -->
<p>Error: Unable to load data.</p>
```

No illustrations. No emoji. No cute copy. No "Oops!" messaging.

---

## Interaction States

### Philosophy

Refined functional. Not flashy, not cute, but polished. Interactions should feel solid and responsive.

### Hover States

- Buttons: Slight opacity change (0.9)
- Links: Underline darkens/thickens slightly
- Table rows: Background shifts to `--color-bg-subtle`
- Interactive elements: Cursor changes appropriately

### Focus States

Subtle but present. Never invisible.

```css
:focus {
  outline: 1px solid var(--color-text);
  outline-offset: 1px;
}
```

### Active States

Brief visual confirmation that action registered:

```css
button:active {
  transform: translateY(1px);
}
```

### Motion & Animation

No special consideration for reduced motion. Animations only where they serve function.

Keep transitions brief when used:

```css
transition: opacity 100ms ease;
```

No decorative animations. No entrances/exits unless genuinely useful.

---

## Theme Implementation

### CSS Architecture

- **CSS Variables:** For colors and theming (enables light/dark mode)
- **Tailwind Utilities:** For spacing, layout, and responsive design
- **No custom spacing scale:** Use Tailwind's built-in values

### Theme Switching

- **Light mode default**
- **Dark mode available**
- **Switching is a development/build-time decision**, not user-facing

No theme picker in the UI. Theme is configured at the application level.

### File Structure

```
app/assets/stylesheets/
├── themes/
│   └── blackbox/
│       ├── variables.css      # CSS custom properties
│       ├── base.css           # Reset and base styles
│       └── components.css     # Component-specific overrides
```

### Component Strategy

Evaluate existing Phlex components individually:

- **CSS-only changes:** Where existing component structure works
- **Parallel components:** Where significant structural changes needed
- **Full rebuild:** Where existing patterns conflict with Blackbox philosophy

Audit required before implementation begins.

---

## Test Cases

Build and validate against these page types:

1. **Dashboard/home page** - First impression, information density
2. **Form-heavy page** - Settings, profile editing, data entry
3. **Data-heavy page** - Tables, lists, reports

All three must feel cohesive and achieve the information density goal.

---

## Anti-Patterns (Explicitly Forbidden)

| Do Not | Why |
|--------|-----|
| Add gradient backgrounds | Vibecoded aesthetic |
| Use border-radius > 0 | Not the Blackbox look |
| Add box shadows to cards | Creates floating/elevated feel |
| Use icons | Text-only interface |
| Add decorative elements | Tool energy, not decoration |
| Create elaborate empty states | Minimal, text-only |
| Add accent colors | Grayscale + semantic only |
| Over-style native form elements | Leverage HTML primitives |
| Add skeleton loaders | Simple "Loading..." text |
| Create toast notifications in corners | Top banner only |

---

## Success Criteria

When viewing the Blackbox-themed interface, users should think:

1. "This is dense with information" ✓
2. "This is serious software" ✓
3. "Someone competent built this" ✓
4. "This respects my time" ✓
5. "This feels solid and reliable" ✓

Users should NOT think:

1. "This looks like every other shadcn site" ✗
2. "This was vibecoded" ✗
3. "This is corporate/enterprise bloatware" ✗
4. "Where's the actual content?" ✗
5. "This is trying too hard to be cool" ✗

---

## Next Steps

1. Create new branch: `feature/blackbox-theme`
2. Audit existing Phlex components
3. Implement CSS variables file
4. Build core components (buttons, inputs, tables)
5. Create test pages for each test case
6. Iterate based on information density assessment
