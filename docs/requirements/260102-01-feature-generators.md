# Feature Generators

## Overview

Create a system of installable "feature generators" that add complete, production-ready functionality to a Boilermaker application. Unlike CRUD scaffolds that generate basic models/views/controllers, feature generators add entire capabilities (payments, notifications, file uploads) with all necessary integrations, configuration, and UI components.

Feature generators leverage established gems where possible (Pay, Noticed, etc.) rather than building from scratch, focusing on configuration, Boilermaker-specific UI, and integration with existing patterns.

## Current State

The application has:
- Phlex scaffold generator (`bin/rails generate phlex:scaffold`) for basic CRUD
- Boilermaker config system (`config/boilermaker.yml`) for feature flags
- Component kit (buttons, forms, cards, tables, etc.) with Phlex slot support
- Authentication system with 2FA, sessions, multi-tenant accounts
- Existing MasqueradesController (incomplete impersonation)
- SolidQueue for background jobs

What's missing:
- Higher-level generators that add complete features
- Standard patterns for feature installation
- Route organization for feature modules

## Design Decisions

### Scoping
Features that can be scoped to Account or User (e.g., subscriptions, notifications) require an **interactive prompt during generation**. The generator asks the user to choose and requires an answer - no default, no flag, no inference. This is a foundational architectural decision that the user must make explicitly.

```
This feature can be scoped to:
  [1] Account - One subscription per team/organization
  [2] User    - Each user has their own subscription

Select scope: _
```

The chosen scope is recorded in `config/boilermaker.yml` for documentation purposes but cannot be changed after generation without re-running the generator.

### Upgrades
Generated code is a starting point. Once generated, it's the user's code to maintain. We do not provide upgrade paths for existing installations. If we fix bugs or add features to generators, users who already ran them must manually apply relevant changes.

### Testing Strategy
Generated tests should **unit test the logic** only. Integration tests that require external services (Stripe, S3) are left to manual testing or CI environments with real credentials. No mocks, but also no generated tests that call external APIs.

### Gem Dependencies
When a generator requires a gem (Pay, Noticed, etc.), the generator should:
1. Add the gem to Gemfile
2. Run `bundle install` automatically
3. Continue with file generation

### Route Organization
Feature routes go in **separate files**: `config/routes/payments.rb`, `config/routes/notifications.rb`, etc. The main `routes.rb` uses `draw :payments` to include them.

### Destroy Behavior
Standard Rails generator destroy: remove files only. Migrations remain in `db/migrate/` with their down methods. User decides whether to rollback. No special handling for existing data.

### Feature Flags at Runtime
When a feature is disabled in config (`features.payments: false`), the feature should **block access** - routes return 404 or redirect. This is enforced via route constraints or controller before_actions.

### Missing Credentials
If required credentials aren't configured (e.g., no Stripe keys), the generator should **warn and continue**. The app will work until the specific feature flow is hit, at which point it errors with a clear message.

### Settings UI
Each feature that adds user-facing settings creates a **sub-page** under settings: `settings/billing.rb`, `settings/notifications.rb`, etc. These are linked from the main settings navigation.

### Header Integration
Features that add header components (notification bell, etc.) use **Phlex slots** in AppHeader. The generator documents which slot to use; no automatic injection into existing components.

### Seed Data
Generators add **development seed data** to `db/seeds.rb` (guarded by `Rails.env.development?`). This includes sample plans, test notifications, etc. for local development.

## Requirements

### 1. Generator Architecture

Create a generator framework that:
- Lives in `lib/generators/boilermaker/`
- Follows Rails generator conventions
- Can be invoked via `bin/rails generate boilermaker:<feature>`
- Supports `--skip-*` flags for partial installation
- Prompts interactively for scope where applicable (no flags)
- Generates tests alongside implementation
- Updates `config/boilermaker.yml` with new feature flags
- Creates feature routes in `config/routes/<feature>.rb`

**Generator Template Structure:**
```
lib/generators/boilermaker/<feature>/
├── <feature>_generator.rb      # Generator logic
├── USAGE                       # Help text
└── templates/
    ├── models/                 # Model templates
    ├── controllers/            # Controller templates
    ├── views/                  # Phlex view templates
    ├── components/             # Component templates
    ├── migrations/             # Database migrations
    ├── jobs/                   # Background job templates
    ├── routes/                 # Route file template
    └── tests/                  # Test templates
```

### 2. Feature Set (Priority Order)

#### 2.1 Invitations
`bin/rails generate boilermaker:invitations`

Team member invitation system using email-based invites.

**Generates:**
- `Invitation` model (account, email, invited_by, token, accepted_at, expires_at)
- `InvitationsController` (new, create, accept)
- `InvitationMailer` with invite email template
- Invitation list view in account admin
- Accept invitation flow (smart handling: existing users join team, new users sign up + join)
- Route file `config/routes/invitations.rb`
- Tests for invitation flows

**Permissions:** Only account owner and admin role can send invitations.

**Smart Handling:**
- If invited email matches existing user → show "Join Team" with login
- If email is new → show "Sign Up" form that also joins team on completion

**Config additions:**
```yaml
features:
  invitations: true
```

#### 2.2 Impersonation
`bin/rails generate boilermaker:impersonation`

Enhance existing MasqueradesController to be complete.

**Generates/Enhances:**
- Complete `MasqueradesController` (create, destroy)
- Session handling for impersonation state
- UI banner showing "You are impersonating X" with exit link
- User table action to impersonate (admin only)
- Audit logging of impersonation start/end (if audit_log feature installed)
- Route file `config/routes/impersonation.rb`
- Tests for impersonation flows

**Constraints:** Only users with admin role can impersonate. Cannot impersonate other admins.

**Config additions:**
```yaml
features:
  impersonation: true
```

#### 2.3 Notifications
`bin/rails generate boilermaker:notifications`

In-app and email notifications using the Noticed gem. Generator prompts for scope (user or account).

**Generates:**
- Noticed gem configuration
- `Notification` model (Noticed delivery records)
- `NotificationsController` (index, mark_read, mark_all_read)
- Notification bell component for header (uses Phlex slot)
- Notification dropdown with unread count
- Notification preferences in `settings/notifications.rb`
- Example notification classes (WelcomeNotification, etc.)
- Route file `config/routes/notifications.rb`
- Development seeds with sample notifications
- Tests for notification flows

**Delivery Channels:**
- Database delivery (always, for in-app bell)
- Email delivery (per notification type - some types email by default, others don't)

**Config additions:**
```yaml
features:
  notifications: true
  notifications_scope: user  # or account
```

#### 2.4 Payments
`bin/rails generate boilermaker:payments`

Subscription billing using the Pay gem with Stripe. Generator prompts for scope (account or user).

**Generates:**
- Pay gem configuration (Stripe only)
- Pay migrations (handled by Pay's install generator)
- `PaymentsController` for checkout/portal redirects
- Webhook route and controller using Pay's webhook handling
- Pricing page component
- Billing settings page `settings/billing.rb`
- Plan/subscription display components
- Route file `config/routes/payments.rb`
- Development seeds with sample plans
- Tests for payment controller actions

**What it does NOT generate:**
- Wrapper models around Pay (use Pay::Subscription, Pay::Customer directly)
- Custom subscription logic (Pay handles this)

**Webhook Setup:** Auto-configured. Generator adds webhook route that Pay handles.

**Config additions:**
```yaml
features:
  payments: true
  payments_scope: account  # or user
  payments_provider: stripe
```

**Next Steps (printed after generation):**
1. Configure Stripe keys: `bin/rails credentials:edit`
2. Run Pay migrations: `bin/rails db:migrate`
3. Create plans in Stripe dashboard
4. Set webhook URL in Stripe: `https://yourapp.com/pay/webhooks/stripe`

#### 2.5 File Uploads
`bin/rails generate boilermaker:uploads`

Generic ActiveStorage setup for file handling.

**Generates:**
- ActiveStorage installation (if not present)
- ActiveStorage configuration for local development
- File upload component (drag-drop with progress via Stimulus)
- File preview component (images, documents)
- File list component
- Direct upload JavaScript configuration
- Route file `config/routes/uploads.rb` (for any standalone upload endpoints)
- Tests for upload components

**What it does NOT generate:**
- Image processing/variants (user adds if needed)
- Specific model attachments (user adds `has_one_attached` where needed)
- S3/cloud configuration (user configures for production)

**Config additions:**
```yaml
features:
  uploads: true
```

#### 2.6 Audit Logging
`bin/rails generate boilermaker:audit_log`

Track changes to sensitive models.

**Generates:**
- `AuditLog` model (user, action, auditable_type, auditable_id, changes, ip_address, user_agent, metadata)
- `Auditable` concern for explicit opt-in on models
- Auto-tracking for sensitive models: User, Account, Session (via initializer)
- `AuditLogsController` for admin viewing
- Audit log viewer with full search (by model, user, action, date range)
- CSV export functionality
- Cleanup job using SolidQueue recurring jobs
- Retention configuration
- Route file `config/routes/audit_log.rb`
- Tests for logging behavior

**Tracking Scope:**
- User, Account, Session: Auto-tracked by default
- Other models: Must include `Auditable` concern explicitly

**Cleanup:** Daily recurring job (SolidQueue) deletes entries older than retention period.

**Config additions:**
```yaml
features:
  audit_log: true
  audit_log_retention_days: 90
```

### 3. Generator Behavior

Each generator should:

1. **Check and install gems** - Add required gems to Gemfile, run `bundle install`
2. **Generate migrations** - Create migration files
3. **Create routes file** - Add `config/routes/<feature>.rb`
4. **Update main routes** - Add `draw :<feature>` to `config/routes.rb`
5. **Update config** - Add feature flags to `config/boilermaker.yml`
6. **Add development seeds** - Append to `db/seeds.rb`
7. **Generate tests** - Create test files for all generated code
8. **Print next steps** - Clear instructions for manual configuration

**Example output:**
```
$ bin/rails generate boilermaker:payments

This feature can be scoped to:
  [1] Account - One subscription per team/organization
  [2] User    - Each user has their own subscription

Select scope: 1

    gemfile  pay (~> 7.0)
     bundle  install
     create  app/controllers/payments_controller.rb
     create  app/views/payments/pricing.rb
     create  app/views/settings/billing.rb
     create  app/components/pricing_card.rb
     create  app/components/subscription_status.rb
     create  config/routes/payments.rb
     insert  config/routes.rb
     insert  config/boilermaker.yml
     append  db/seeds.rb
     create  test/controllers/payments_controller_test.rb
      rails  pay:install:migrations

Next steps:
  1. Run migrations: bin/rails db:migrate
  2. Configure Stripe keys: bin/rails credentials:edit
     Add: stripe: { private_key: sk_xxx, public_key: pk_xxx, webhook_secret: whsec_xxx }
  3. Create plans in Stripe dashboard
  4. Set webhook URL: https://yourapp.com/pay/webhooks/stripe
```

### 4. Feature Independence

All generators are **fully independent**. No generator requires another to be installed first. However, generators may include optional enhancements when other features are present:

- Impersonation checks if audit_log is installed and logs impersonation events if so
- Payments can trigger notifications if notifications is installed

These are runtime checks, not generation-time dependencies.

## Clarifications

1. **No API Keys feature**: Removed from scope. Not needed for MVP.

2. **Pay gem only**: We use Pay for payments, not custom subscription logic. The generator configures Pay and adds Boilermaker UI.

3. **Noticed gem only**: We use Noticed for notifications, not custom notification logic. The generator configures Noticed and adds Boilermaker UI.

4. **Stripe only**: Only Stripe is configured. Pay supports other providers, but we don't generate configuration for them.

5. **Incremental generation**: Running a generator twice should be safe - skip existing files or prompt for overwrite.

6. **Route namespacing**: Feature routes use `draw :feature` pattern. Each feature's routes are isolated in their own file.

## Success Criteria

- [ ] Generator framework exists in `lib/generators/boilermaker/`
- [ ] All 6 feature generators are implemented
- [ ] Generators add gems and run bundle install
- [ ] Generators create routes in separate files
- [ ] Generators update config/boilermaker.yml
- [ ] Generators add development seeds
- [ ] Generated code follows Boilermaker conventions
- [ ] Generated tests pass
- [ ] `rails destroy boilermaker:<feature>` removes generated files
- [ ] Clear documentation for each generator in USAGE file
- [ ] Features can be disabled via config (returns 404)
- [ ] Smart credential warnings (warn but continue if keys missing)
