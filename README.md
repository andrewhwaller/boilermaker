# Boilermaker

A Rails 8 application template with Phlex components and AI-powered development tools.

## Tech Stack

- **Rails 8.0.3** with Ruby 3.4.4
- **Phlex** views and components (not ERB)
- **Stimulus + Turbo** for interactivity
- **Tailwind CSS** for styling
- **SQLite** with Solid Queue, Solid Cache, and Solid Cable
- **Minitest** with Capybara for testing

## Quick Start

```bash
bin/setup    # Install dependencies
bin/dev      # Start development server
```

Visit `http://localhost:3000`

## What's Different from Standard Rails

### Views
This template uses **Phlex** instead of ERB. Views are Ruby classes:
```
app/views/posts/index.rb      # Not index.html.erb
app/components/posts/...      # Reusable components
```

Scaffolding generates Phlex views automatically.

### Authentication
Built-in session-based auth with optional 2FA (TOTP). Configure features in `config/boilermaker.yml`.

### IDs
Model IDs are obfuscated via Hashids in URLs.

### Background Jobs & Caching
Uses SQLite-backed Solid Queue, Solid Cache, and Solid Cable instead of Redis.

## Development

```bash
rails test           # Run tests
rails generate scaffold Post title:string  # Generates Phlex views
rubocop              # Style checks
brakeman             # Security scan
```

## Starting a New Project from Boilermaker

After cloning, point origin to your new repo and add boilermaker as an upstream:

```bash
git remote set-url origin https://github.com/YOU/YOUR-NEW-REPO.git
git remote add boilermaker https://github.com/andrewhwaller/boilermaker.git
git push -u origin main
```

To pull updates from boilermaker later:

```bash
git fetch boilermaker
git merge boilermaker/main
```

## AI Development Tools

This template includes Claude Code commands for AI-assisted development. Use these slash commands in Claude Code:

### Core Workflow

| Command | Description |
|---------|-------------|
| `/prime` | Get oriented with the codebase - reads CLAUDE.md and key docs |
| `/architecture <requirements>` | Develop a spec for a new feature with multiple review iterations |
| `/implement <spec>` | Implement a feature from a spec using specialized agents |
| `/debug <issue>` | Debug an issue with code analysis and testing |
| `/review` | Review recent code changes against Rails/DHH standards |

### Specialized Agents

The commands use these sub-agents behind the scenes:

- **Application Architect** - Creates implementation specs
- **DHH Code Reviewer** - Reviews code against Rails conventions
- **Rails Programmer** - Implements backend code
- **Stimulus Turbo Developer** - Implements frontend with Phlex/Stimulus/Turbo
- **Test Writer** - Writes comprehensive tests
- **Code Analyzer** - Traces logic and finds bugs

### Typical Workflow

1. **Start a session**: `/prime` to load project context
2. **Plan a feature**: `/architecture docs/requirements/my-feature.md`
3. **Implement**: `/implement docs/plans/my-feature-spec.md`
4. **Debug issues**: `/debug "login form not submitting"`
5. **Review changes**: `/review` before committing

See `/docs/overview.md` for full documentation structure.
