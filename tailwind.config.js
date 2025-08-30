/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './app/views/**/*.{erb,haml,html,slim,rb}',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js'
  ],
  darkMode: 'class', // Enable class-based dark mode strategy
  theme: {
    extend: {
      colors: {
        // Semantic color system using CSS custom properties
        // All colors use space-separated RGB values for Tailwind 4 compatibility
        primary: {
          DEFAULT: 'rgb(var(--color-primary) / <alpha-value>)',
          hover: 'rgb(var(--color-primary-hover) / <alpha-value>)',
        },
        secondary: {
          DEFAULT: 'rgb(var(--color-secondary) / <alpha-value>)',
        },
        background: {
          DEFAULT: 'rgb(var(--color-background) / <alpha-value>)',
          surface: 'rgb(var(--color-surface) / <alpha-value>)',
          elevated: 'rgb(var(--color-background-elevated) / <alpha-value>)',
        },
        foreground: {
          DEFAULT: 'rgb(var(--color-foreground) / <alpha-value>)',
          muted: 'rgb(var(--color-foreground-muted) / <alpha-value>)',
          subtle: 'rgb(var(--color-foreground-subtle) / <alpha-value>)',
        },
        border: {
          DEFAULT: 'rgb(var(--color-border) / <alpha-value>)',
          subtle: 'rgb(var(--color-border-subtle) / <alpha-value>)',
        },
        input: {
          DEFAULT: 'rgb(var(--color-input) / <alpha-value>)',
          border: 'rgb(var(--color-input-border) / <alpha-value>)',
        },
        button: {
          DEFAULT: 'rgb(var(--color-button) / <alpha-value>)',
          text: 'rgb(var(--color-button-text) / <alpha-value>)',
          hover: 'rgb(var(--color-button-hover) / <alpha-value>)',
          secondary: 'rgb(var(--color-button-secondary) / <alpha-value>)',
          'secondary-text': 'rgb(var(--color-button-secondary-text) / <alpha-value>)',
          'secondary-hover': 'rgb(var(--color-button-secondary-hover) / <alpha-value>)',
        },
        accent: {
          DEFAULT: 'rgb(var(--color-accent) / <alpha-value>)',
          hover: 'rgb(var(--color-accent-hover) / <alpha-value>)',
          text: 'rgb(var(--color-accent-text) / <alpha-value>)',
        },
        success: {
          DEFAULT: 'rgb(var(--color-success) / <alpha-value>)',
          text: 'rgb(var(--color-success-text) / <alpha-value>)',
          background: 'rgb(var(--color-success-background) / <alpha-value>)',
        },
        error: {
          DEFAULT: 'rgb(var(--color-error) / <alpha-value>)',
          text: 'rgb(var(--color-error-text) / <alpha-value>)',
          background: 'rgb(var(--color-error-background) / <alpha-value>)',
        },
        warning: {
          DEFAULT: 'rgb(var(--color-warning) / <alpha-value>)',
          text: 'rgb(var(--color-warning-text) / <alpha-value>)',
          background: 'rgb(var(--color-warning-background) / <alpha-value>)',
        },
        info: {
          DEFAULT: 'rgb(var(--color-info) / <alpha-value>)',
          text: 'rgb(var(--color-info-text) / <alpha-value>)',
          background: 'rgb(var(--color-info-background) / <alpha-value>)',
        },
      },
      fontFamily: {
        mono: ['CommitMonoIndustrial', 'monospace'],
      },
      boxShadow: {
        'theme': 'var(--shadow-theme)',
        'theme-sm': 'var(--shadow-theme-sm)',
        'theme-md': 'var(--shadow-theme-md)',
        'theme-lg': 'var(--shadow-theme-lg)',
      },
    },
  },
  plugins: [
    require('@tailwindcss/typography'),
  ],
}