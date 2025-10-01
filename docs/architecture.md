# Application Architecture

## Overview

This Rails 8 application follows a component-based architecture using Phlex for views and Stimulus for JavaScript behavior.

## Core Patterns

### View Layer
- **Phlex Components**: Ruby classes in `/app/components/` handle all view rendering
- **Component Kits**: Organized component hierarchies for reusability
- **Shared Components**: Common UI elements in dedicated namespaces

### Interactive Behavior
- **Stimulus Controllers**: Progressive enhancement via `/app/javascript/controllers/`
- **Turbo Frames**: Independent page sections that update without full page reload
- **Turbo Streams**: Server-driven DOM updates for real-time features

### Data Flow
1. **Request** → Rails Controller
2. **Controller** → Model interactions + data preparation
3. **Controller** → Phlex component rendering with data
4. **Response** → HTML with Stimulus data attributes
5. **Client** → Stimulus controllers enhance behavior

### Testing Strategy
- **Model Tests**: Business logic validation
- **Controller Tests**: Request/response validation
- **Component Tests**: Phlex component rendering
- **System Tests**: End-to-end user flows with Capybara

## File Organization

```
app/
├── components/           # Phlex components
│   ├── application_component.rb
│   ├── shared/          # Shared UI components
│   └── layouts/         # Layout components
├── controllers/         # Rails controllers
├── models/             # ActiveRecord models
├── javascript/
│   └── controllers/    # Stimulus controllers
└── assets/
    └── stylesheets/    # CSS and Tailwind
```