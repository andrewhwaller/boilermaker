# Setup Wizard CLI

## Overview

Create an interactive command-line wizard that guides users through configuring a Boilermaker project after cloning. The wizard handles git remote setup, collects preferences (app name, theme, features), runs selected generators, and produces a ready-to-run application.

## Current State

Currently, starting a new Boilermaker project requires:
1. Cloning the repository
2. Manually setting up git remotes
3. Manually editing `config/boilermaker.yml`
4. Running database setup
5. Manually running feature generators
6. Understanding the codebase structure

This is friction that prevents the "describe what you want → get a working app" vision.

## Design Decisions

### Entry Point & Git Workflow
The wizard assumes users have **cloned the boilermaker repo**. The workflow is:
1. Clone boilermaker repo
2. Run setup wizard
3. Wizard helps set up new origin (offers `gh repo create`)
4. Wizard configures the project
5. User pushes to their new origin

This is NOT a Rails template or standalone CLI gem - it's a rake task that runs after cloning.

### Quick Mode
Wizard offers "Quick setup or full configuration?" at start. Quick mode uses sensible defaults:
- Theme: Paper (light)
- Features: Registration, team accounts, invitations, notifications
- Skips detailed questions, uses defaults for everything

### Database
Assume SQLite. No database selection prompt. Users who need Postgres/MySQL configure it manually.

### Demo Content
Leave all demo content in place (theme demos, example components). Users remove what they don't need manually. The demos serve as reference implementations.

### Feature Generator Execution
For each generator feature selected, wizard asks "Install now or later?" This allows users to defer features they want to configure more carefully.

### Generator Sub-Questions
Wizard collects all answers upfront using **inline expansion**: when user toggles a feature on, any required sub-questions (like scope) appear immediately below. All answers are passed to generators silently (no nested prompts).

### Custom Theme
"Custom" theme option means no theme styling applied. User starts with a blank slate and builds their own theme later.

### Re-Run Behavior
Wizard can be re-run on configured projects:
- Shows current values as defaults
- Allows changing any configuration
- If user toggles off an already-installed generator feature, show warning but don't remove (user handles manually with `rails destroy`)

### Upstream Updates
Wizard checks if boilermaker remote has new commits and offers to pull before proceeding.

## Requirements

### 1. Wizard Entry Point

```bash
# From within a cloned boilermaker project
bin/rails boilermaker:setup
```

### 2. Wizard Flow

#### Step 0: Update Check
```
Checking for boilermaker updates...

  ⚠ boilermaker remote has 3 new commits.

Pull latest updates before setup? [Y/n]
> Y

Pulling from boilermaker...
  ✓ Updated to latest
```

#### Step 1: Setup Mode
```
┌─────────────────────────────────────────────────────────┐
│  BOILERMAKER SETUP                                      │
└─────────────────────────────────────────────────────────┘

How would you like to configure your project?

  [1] Quick setup (recommended defaults)
  [2] Full configuration

> 1
```

#### Step 2: Git Remote Setup
```
Let's set up your project's git remote.

  [1] Create new GitHub repo (uses `gh` CLI)
  [2] Use existing repo URL
  [3] Skip for now

> 1

Repository name? [my-app]
> patentwatch

Private repository? [Y/n]
> Y

Creating repository...
  ✓ Created github.com/username/patentwatch
  ✓ Set as origin remote
  ✓ Renamed boilermaker remote to 'upstream'
```

#### Step 3: Basic Info
```
What's your app called? [Boilermaker]
> PatentWatch

Support email? [support@example.com]
> support@patentwatch.com
```

#### Step 4: Theme Selection
```
Choose a theme:

  [1] Paper      - Clean, minimal, refined (light)
  [2] Terminal   - Green phosphor CRT aesthetic (dark)
  [3] Blueprint  - Technical drawing style (dark)
  [4] Brutalist  - Raw, minimal, content-focused (light)
  [5] Amber      - Warm amber CRT/DOS style (dark)
  [6] Custom     - No theme, build your own

> 1
```

#### Step 5: Feature Selection (Full Mode Only)
```
Which features do you need?

  [x] User registration
  [x] Team accounts
  [ ] Personal accounts
  [ ] Two-factor authentication (required)

  Generator Features:
  [x] Invitations
      └─ (will be installed)
  [ ] Impersonation
  [x] Notifications
      ├─ Scope: [Account / User] > Account
      └─ Install now? [Y/n] > Y
  [ ] Payments
  [ ] File uploads
  [ ] Audit logging

Use arrow keys to navigate, space to toggle, enter to confirm.
```

#### Step 6: Confirmation & Execution
```
Ready to configure your project:

  Name:         PatentWatch
  Theme:        Paper
  Features:     Registration, Team Accounts, Invitations, Notifications

  Generators to run:
    • boilermaker:invitations
    • boilermaker:notifications (scope: account)

Proceed? [Y/n]
> Y

Configuring project...
  ✓ Updated config/boilermaker.yml
  ✓ Running boilermaker:invitations generator...
  ✓ Running boilermaker:notifications generator...
  ✓ Running database migrations...
  ✓ Seeding development data...

Done! Run `bin/dev` to start your app.
```

#### Step 7: Next Steps
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Next steps:

  1. Start the server: bin/dev
  2. Visit http://localhost:3000
  3. Create your first user by signing up

Your git remotes:
  origin   → github.com/username/patentwatch (your repo)
  upstream → github.com/boilermaker/boilermaker (for updates)

To pull future boilermaker updates:
  git fetch upstream && git merge upstream/main

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 3. Quick Mode Flow

Quick mode skips feature selection entirely:

```
┌─────────────────────────────────────────────────────────┐
│  BOILERMAKER SETUP                                      │
└─────────────────────────────────────────────────────────┘

How would you like to configure your project?

  [1] Quick setup (recommended defaults)
  [2] Full configuration

> 1

Quick setup will configure:
  • Paper theme (light mode)
  • User registration + Team accounts
  • Invitations (account-scoped)
  • Notifications (account-scoped)

What's your app called? [Boilermaker]
> PatentWatch

Support email? [support@example.com]
> support@patentwatch.com

Setting up git remote...
  [1] Create new GitHub repo
  [2] Use existing repo URL
  [3] Skip for now

> 1
...

Configuring project...
  ✓ Updated config/boilermaker.yml
  ✓ Running generators...
  ✓ Migrating database...
  ✓ Seeding development data...

Done! Run `bin/dev` to start your app.
```

### 4. Re-Run Behavior

When wizard detects existing configuration:

```
┌─────────────────────────────────────────────────────────┐
│  BOILERMAKER SETUP                                      │
└─────────────────────────────────────────────────────────┘

Existing configuration detected.

  App name:    PatentWatch
  Theme:       Paper
  Features:    Registration, Team Accounts, Invitations, Notifications

What would you like to do?

  [1] Modify configuration
  [2] Add more features
  [3] Cancel

> 1
```

When toggling off an installed feature:

```
  [ ] Notifications

  ⚠ Notifications is currently installed. Unchecking will NOT remove
    the generated code. To remove, run:

    bin/rails destroy boilermaker:notifications
```

### 5. Implementation

#### 5.1 Rake Task
```ruby
# lib/tasks/boilermaker.rake
namespace :boilermaker do
  desc "Run interactive setup wizard"
  task setup: :environment do
    Boilermaker::SetupWizard.new.run
  end
end
```

#### 5.2 TTY Toolkit
Use the TTY gem family for interactive prompts:
- `tty-prompt` for input collection (select, multiselect, ask)
- `tty-spinner` for progress indicators
- `tty-box` for formatted headers

#### 5.3 Wizard Class Structure
```ruby
# lib/boilermaker/setup_wizard.rb
module Boilermaker
  class SetupWizard
    def run
      check_for_updates
      select_mode  # quick vs full
      setup_git_remote
      collect_basic_info
      select_theme
      select_features if full_mode?
      confirm_and_execute
      show_next_steps
    end
  end
end
```

### 6. Configuration Output

The wizard writes to `config/boilermaker.yml`:

```yaml
---
default:
  app:
    name: PatentWatch
    version: 1.0.0
    support_email: support@patentwatch.com
  features:
    user_registration: true
    personal_accounts: false
    team_accounts: true
    invitations: true
    notifications: true
    notifications_scope: account
    payments: false
    uploads: false
    impersonation: false
    audit_log: false
  security:
    require_two_factor_authentication: false
  ui:
    theme:
      name: paper
    typography:
      font: system
      uppercase: false
      size: base
    navigation:
      layout_mode: sidebar
```

### 7. Error Handling

The wizard should handle:

- **No git remote**: Proceed without remote setup, warn user
- **gh CLI not installed**: Fall back to "enter URL" or "skip" options
- **Generator fails**: Show error, offer to continue with remaining generators
- **Missing dependencies**: Check for required gems before running generators

## Clarifications

1. **Not a standalone CLI**: The wizard is a rake task within the project, not a separate gem.

2. **Not a Rails template**: Users clone the repo first, then run the wizard. This gives more control than `rails new -m`.

3. **Demo content stays**: Theme demos and example components remain. They serve as reference.

4. **SQLite assumed**: No database configuration. Users who need Postgres configure it separately.

5. **Quick mode defaults**: Registration, team accounts, invitations, notifications - all account-scoped.

6. **Upstream tracking**: After setup, boilermaker remote is renamed to `upstream` for future updates.

## Success Criteria

- [ ] Wizard runs via `bin/rails boilermaker:setup`
- [ ] Offers quick mode vs full configuration
- [ ] Handles git remote setup with `gh repo create` option
- [ ] Collects app name, support email, theme
- [ ] Feature selection with inline sub-questions
- [ ] "Install now or later?" per generator feature
- [ ] Runs selected generators with collected answers
- [ ] Runs migrations and seeds after generators
- [ ] Checks for upstream updates and offers to pull
- [ ] Works on fresh clone and existing configured projects
- [ ] Re-run shows current config as defaults
- [ ] Warns (doesn't destroy) when toggling off installed features
- [ ] Clear next steps shown after completion
