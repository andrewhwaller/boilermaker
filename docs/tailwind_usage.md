# Tailwind CSS Usage Guide

## Overview

Boilermaker uses Tailwind CSS v4 with a custom theme system that provides consistent styling across light and dark modes. The setup is optimized for production with automatic purging and minimal file size.

## Custom Theme System

### CSS Variables

The theme system uses CSS custom properties for consistent theming:

```css
/* Light mode (default) */
--color-primary: #000000;
--color-primary-hover: #333333;
--color-secondary: #666666;
--color-surface: #ffffff;
--color-input: #ffffff;
--color-border: #d1d5db;
--color-foreground: #000000;
--color-muted: #6b7280;
--color-button: #000000;
--color-button-text: #ffffff;
--color-button-hover: #333333;
--color-success: #16a34a;
--color-error: #dc2626;
```

### Dark Mode Support

Dark mode is supported through:
1. **System preference**: Automatically detects `prefers-color-scheme: dark`
2. **Manual override**: Use `.dark` class for explicit dark mode
3. **Manual light**: Use `.light` class to force light mode

### Available Theme Colors

Use these semantic color classes in your components:

- `text-primary` / `bg-primary` - Main brand color
- `text-secondary` / `bg-secondary` - Secondary text/backgrounds
- `text-foreground` / `bg-surface` - Main text and surface colors
- `text-muted` / `bg-muted` - Muted/disabled states
- `text-success` / `bg-success` - Success states
- `text-error` / `bg-error` - Error states
- `border-border` - Standard border color
- `bg-input` - Input field backgrounds

## Typography

### Font Setup

The project uses CommitMono Industrial as the primary font:

```css
body {
  font-family: 'CommitMonoIndustrial', monospace;
}
```

### Base Font Size

The root font size is set to 14px for a compact, professional look:

```css
html {
  font-size: 14px;
}
```

### Text Utilities

- `text-xs` (0.75rem) - Small labels, captions
- `text-sm` (0.875rem) - Form labels, secondary text
- `text-base` (1rem) - Body text
- `text-lg` (1.125rem) - Subheadings
- `text-xl` (1.25rem) - Page titles
- `text-2xl` (1.5rem) - Section headers
- `text-3xl` (1.875rem) - Main headings

## Component Styling

### Button Components

All buttons inherit base styling from the `@layer components` section:

```css
button, input[type="submit"], input[type="button"], input[type="reset"], .btn {
  @apply px-3 py-1;
  @apply font-medium transition-colors duration-200 ease-in-out cursor-pointer;
  @apply bg-button text-button-text border border-button;
  @apply hover:bg-button-hover focus:outline-none;
  @apply disabled:opacity-50 disabled:cursor-not-allowed;
}
```

#### Button Variants

The Button component supports these variants:

```ruby
# Primary button (default)
Components::Button.new { "Save" }

# Secondary button
Components::Button.new(variant: :secondary) { "Cancel" }

# Destructive button
Components::Button.new(variant: :destructive) { "Delete" }

# Outline button
Components::Button.new(variant: :outline) { "Edit" }

# Ghost button
Components::Button.new(variant: :ghost) { "More" }

# Link-style button
Components::Button.new(variant: :link) { "Learn more" }
```

### Link Buttons

For text-only link buttons, use the `.btn-link` class:

```css
.btn-link {
  @apply bg-transparent text-blue-600 border-transparent hover:text-blue-800 hover:underline;
  @apply dark:text-blue-400 dark:hover:text-blue-300;
  @apply px-0 py-0;
}
```

## Layout Utilities

### Container System

Use the responsive container system for consistent page layouts:

```html
<div class="container mx-auto px-4">
  <!-- Content -->
</div>
```

Container breakpoints:
- Default: 100% width
- `sm` (40rem): max-width 40rem
- `md` (48rem): max-width 48rem  
- `lg` (64rem): max-width 64rem
- `xl` (80rem): max-width 80rem
- `2xl` (96rem): max-width 96rem

### Spacing System

The spacing system uses a 0.25rem (4px) base unit:

- `p-1` / `m-1` = 0.25rem (4px)
- `p-2` / `m-2` = 0.5rem (8px)
- `p-3` / `m-3` = 0.75rem (12px)
- `p-4` / `m-4` = 1rem (16px)
- `p-6` / `m-6` = 1.5rem (24px)
- `p-8` / `m-8` = 2rem (32px)

## Common Patterns

### Form Layouts

```html
<div class="space-y-4">
  <div>
    <label class="block text-sm font-medium text-foreground mb-2">
      Email
    </label>
    <input class="block border border-border bg-input px-3 py-1 text-foreground w-full">
  </div>
</div>
```

### Card Components

```html
<div class="bg-surface border border-border rounded-lg p-6 shadow-sm">
  <h3 class="text-lg font-semibold text-foreground mb-4">Card Title</h3>
  <p class="text-muted">Card content goes here.</p>
</div>
```

### Navigation

```html
<nav class="border-b border-border p-4 flex items-center justify-between">
  <div class="flex items-center gap-6">
    <a class="text-lg font-semibold text-foreground hover:text-secondary">
      Brand
    </a>
  </div>
</nav>
```

## Build Process

### Development

```bash
bin/dev  # Starts Rails server + Tailwind watch mode
```

### Production Build

```bash
RAILS_ENV=production bin/rails tailwindcss:build
```

### File Locations

- **Source**: `app/assets/tailwind/application.css`
- **Output**: `app/assets/builds/tailwind.css`
- **Size**: ~25KB (optimized with purging)

## Best Practices

### 1. Use Semantic Colors

```ruby
# Good - semantic meaning
class: "text-error"
class: "bg-success"

# Avoid - specific colors
class: "text-red-600"
class: "bg-green-500"
```

### 2. Consistent Spacing

```ruby
# Good - consistent spacing scale
class: "p-4 mb-6 gap-2"

# Avoid - arbitrary values
class: "p-[17px] mb-[23px]"
```

### 3. Component-Based Styling

```ruby
# Good - reusable component
Components::Button.new(variant: :primary) { "Submit" }

# Avoid - inline classes everywhere
button(class: "px-3 py-1 bg-primary text-white hover:bg-primary/90") { "Submit" }
```

### 4. Responsive Design

```ruby
# Good - mobile-first responsive
class: "text-sm md:text-base lg:text-lg"
class: "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3"
```

### 5. Dark Mode Considerations

```ruby
# Good - works in both modes
class: "bg-surface text-foreground border-border"

# Avoid - light mode only
class: "bg-white text-black border-gray-300"
```

## Troubleshooting

### Classes Not Working

1. Check if the class is being used in a scanned file (app/ directory)
2. Rebuild CSS: `bin/rails tailwindcss:build`
3. Restart the watch process: `bin/rails tailwindcss:watch`

### Dark Mode Issues

1. Ensure proper CSS variable usage
2. Test with system preference and manual `.dark` class
3. Check that theme variables are defined for both modes

### Performance

The current setup generates a 25KB CSS file with only used classes. If the file grows significantly:

1. Review unused classes in components
2. Check for overly broad class scanning
3. Consider splitting large utility classes

## Migration from v3 to v4

If upgrading from Tailwind v3:

```bash
bin/rails tailwindcss:upgrade
```

Key changes in v4:
- CSS-first configuration
- Improved performance
- Better dark mode support
- Enhanced purging