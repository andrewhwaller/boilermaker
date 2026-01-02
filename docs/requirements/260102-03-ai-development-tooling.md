# AI Development Tooling

## Overview

Organize documentation and context files so AI coding assistants (Claude Code, Cursor, etc.) can effectively build applications using Boilermaker. The goal is that a user can describe what they want and the AI generates correct, idiomatic Boilermaker code by referencing well-organized documentation.

This is NOT about adding AI features to apps or creating complex tooling. It's about **good documentation, well-organized** so AI can find and use it.

## Current State

The application has:
- `CLAUDE.md` with project rules and philosophy
- Architecture documentation in `/docs/`
- Consistent patterns for models, controllers, views
- Phlex component library with established conventions
- Existing `/prime` skill that loads context
- Existing agents (rails-senior-developer, phlex-component-architect, etc.)

What's missing:
- Docs reorganized for easier AI navigation
- Quick reference section in CLAUDE.md
- Lightweight examples of how things were built
- Prompt templates to help users describe requirements

## Design Decisions

### No New Skills or Agents
Existing Claude Code skills and agents are sufficient. The `/prime` skill already handles context loading. Focus is on making the content it loads better, not adding more tooling.

### No Codebase Map
Skip machine-readable codebase map. Well-organized docs + CLAUDE.md is enough. A map would require maintenance and adds complexity without proportional value.

### Manual Documentation Discipline
Developers manually update docs when adding patterns or components. No automation or CI enforcement. This is a discipline, not a tool.

### Guardrails Already Exist
Existing CLAUDE.md already covers what AI should/shouldn't do. No expansion needed.

### Documentation in Two Places
- **Code comments**: Inline documentation for implementation details
- **docs/ folder**: High-level patterns and concepts

## Requirements

### 1. Docs Reorganization

Restructure `/docs/` by concern for easier AI navigation:

```
docs/
├── README.md                    # Index pointing to all docs
├── architecture/
│   ├── overview.md              # High-level app structure
│   ├── file-structure.md        # Directory conventions
│   └── tech-stack.md            # Rails 8, Phlex, Tailwind, etc.
├── models/
│   ├── overview.md              # Model patterns and conventions
│   ├── user.md                  # User model details
│   ├── account.md               # Account/multi-tenancy
│   └── authentication.md        # Auth flow
├── views/
│   ├── phlex-patterns.md        # Phlex conventions
│   ├── layouts.md               # Layout structure
│   └── components.md            # Component library overview
├── patterns/
│   ├── adding-settings.md       # How to add settings sections
│   ├── adding-admin-features.md # How to add admin features
│   ├── background-jobs.md       # SolidQueue patterns
│   └── forms.md                 # Form patterns
├── features/
│   ├── authentication.md        # Built-in auth
│   ├── accounts.md              # Multi-tenant accounts
│   ├── two-factor-auth.md       # 2FA implementation
│   └── generators.md            # Available feature generators
├── themes/
│   ├── overview.md              # Theme system
│   ├── creating-themes.md       # How to create new themes
│   └── theme-components.md      # Theme-specific components
└── examples/
    ├── README.md                # Index of examples
    ├── building-crud.md         # Example: scaffold → customization
    ├── adding-dashboard.md      # Example: how demo dashboards were built
    └── implementing-feature.md  # Example: how a feature was added
```

### 2. CLAUDE.md Quick Reference

Add a quick reference section at the top of CLAUDE.md (after critical rules):

```markdown
## Quick Reference

### Common Commands
```bash
# Add a new resource (model + CRUD views)
bin/rails generate phlex:scaffold Post title:string body:text

# Add a feature
bin/rails generate boilermaker:invitations

# Run setup wizard
bin/rails boilermaker:setup

# Run tests
bin/rails test
```

### Where Things Live
- Models: `app/models/`
- Controllers: `app/controllers/`
- Views (Phlex): `app/views/`
- Components: `app/components/`
- Layouts: `app/views/layouts/`
- Theme components: `app/components/boilermaker/`

### Common Patterns
See `docs/patterns/` for detailed guides:
- Adding a settings section → `docs/patterns/adding-settings.md`
- Adding an admin feature → `docs/patterns/adding-admin-features.md`
- Creating forms → `docs/patterns/forms.md`

### Component Usage
See `docs/views/components.md` for full reference:
```ruby
# Button
render Components::Button.new(label: "Save", variant: :primary)

# Form input
render Components::Input.new(form: f, field: :name, label: "Name")

# Card
render Components::Card.new(title: "Settings") { content }
```
```

### 3. Lightweight Examples

Create brief "how we did X" notes in `docs/examples/`:

Each example should be **one file, ~50-100 lines**, covering:
- What was built (2-3 sentences)
- Key files involved (list)
- Pattern used (brief explanation)
- Link to relevant pattern doc

**Example format:**
```markdown
# Building CRUD for Posts

## What We Built
A standard resource with list, show, create, edit, delete views using the Phlex scaffold generator.

## Command
```bash
bin/rails generate phlex:scaffold Post title:string body:text published:boolean
```

## Files Created
- `app/models/post.rb`
- `app/controllers/posts_controller.rb`
- `app/views/posts/` (index, show, new, edit, _form)
- `db/migrate/xxx_create_posts.rb`
- `test/models/post_test.rb`
- `test/controllers/posts_controller_test.rb`

## Pattern
Standard Rails resource pattern. See `docs/patterns/resources.md` for customization options.

## Customizations Made
- Added `published` scope to model
- Added publish/unpublish actions to controller
- Modified index view to show published status
```

### 4. Prompt Templates

Create templates in `.claude/templates/` to help users describe requirements:

#### `.claude/templates/feature-request.md`
```markdown
# Feature Request Template

Use this format when asking AI to build a new feature:

---

## Feature: [Name]

### What It Does
[2-3 sentences describing the feature]

### User Flow
1. User does X
2. System responds with Y
3. User sees Z

### Where It Appears
- [ ] Settings page
- [ ] Admin area
- [ ] Main navigation
- [ ] Other: ___

### Who Can Access
- [ ] All users
- [ ] Admins only
- [ ] Account owners
- [ ] Custom permission: ___

### Related Existing Features
[List any existing models, controllers, or patterns this relates to]

---
```

#### `.claude/templates/resource-request.md`
```markdown
# Resource Request Template

Use this format when asking AI to create a new resource:

---

## Resource: [Name]

### Fields
| Name | Type | Required | Notes |
|------|------|----------|-------|
| title | string | yes | |
| body | text | no | |

### Associations
- belongs_to: [model name]
- has_many: [model name]

### Validations
- Required: [field names]
- Unique: [field names]
- Custom: [describe]

### Views Needed
- [ ] Index (list)
- [ ] Show (detail)
- [ ] New/Edit (form)
- [ ] Custom: ___

### Permissions
[Who can create/read/update/delete?]

---
```

#### `.claude/templates/component-request.md`
```markdown
# Component Request Template

Use this format when asking AI to create a new Phlex component:

---

## Component: [Name]

### Purpose
[One sentence describing what this component does]

### Props
| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| | | | | |

### Variants (if any)
- variant_a: [description]
- variant_b: [description]

### Example Usage
```ruby
render Components::MyComponent.new(prop: value)
```

### Similar To
[Name any existing components this is similar to]

---
```

### 5. Documentation Guidelines

Add a section to CLAUDE.md or a dedicated file explaining how to document:

```markdown
## Documentation Guidelines

### When to Update Docs

Update documentation when you:
- Add a new pattern or convention
- Create a new component
- Add a feature generator
- Change how something fundamental works

### Where to Document

| What Changed | Where to Update |
|--------------|-----------------|
| New model | `docs/models/` |
| New component | `docs/views/components.md` + inline YARD |
| New pattern | `docs/patterns/` |
| New feature | `docs/features/` |
| Example of something | `docs/examples/` |

### Documentation Format

Keep it brief:
- One concept per file
- 50-150 lines max
- Code examples over prose
- Link to related docs

### Inline Documentation

Use YARD-style comments for components:
```ruby
# Renders a styled button with multiple variants.
#
# @param label [String] Button text
# @param variant [Symbol] :primary, :secondary, :danger, :ghost
# @param href [String, nil] Optional link URL
#
# @example Primary button
#   render Components::Button.new(label: "Save", variant: :primary)
#
class Button < Components::Base
```
```

## What We're NOT Building

- **No codebase map**: Too much maintenance burden
- **No new skills**: Existing /prime is sufficient
- **No new agents**: Existing agents work fine
- **No automation**: Manual discipline for doc updates
- **No guardrails expansion**: Existing rules are sufficient

## Clarifications

1. **Scope**: This is about documentation organization, not AI features or complex tooling.

2. **Maintenance**: Docs are updated manually as part of development workflow. No enforcement.

3. **Progressive disclosure**: CLAUDE.md has quick reference, /docs/ has details.

4. **Real examples**: Examples reference actual code, not hypotheticals.

5. **Tool agnostic**: While focused on Claude Code, good docs help any AI tool.

## Success Criteria

- [ ] `/docs/` reorganized by concern (architecture/, models/, views/, patterns/, features/, examples/)
- [ ] Each docs folder has an overview/index file
- [ ] CLAUDE.md has quick reference section with common commands and patterns
- [ ] At least 3 lightweight examples in `docs/examples/`
- [ ] Prompt templates exist in `.claude/templates/`
- [ ] Documentation guidelines added (where to document what)
- [ ] Existing docs migrated to new structure
- [ ] AI can navigate docs to find relevant patterns
