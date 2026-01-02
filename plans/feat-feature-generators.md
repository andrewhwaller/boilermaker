# Feature Generators Implementation Plan

## Overview

Implement a system of installable feature generators that add complete, production-ready functionality to Boilermaker applications. Each generator creates controllers, views, models, routes, tests, and configuration - leveraging established gems (Pay, Noticed) rather than building from scratch.

**Spec Reference:** `docs/requirements/260102-01-feature-generators.md`

## Phase 1: Generator Framework

### 1.1 Base Generator Class

Create shared infrastructure all generators inherit from.

**Files to create:**
- `lib/generators/boilermaker/base_generator.rb`

**Responsibilities:**
- Interactive prompts (using Thor's `ask` and `yes?`)
- Gem management (add to Gemfile, run bundle)
- Config updates (append to `config/boilermaker.yml`)
- Route file creation and main routes.rb integration
- Development seed appending
- Consistent "Next steps" output

```ruby
# lib/generators/boilermaker/base_generator.rb
module Boilermaker
  module Generators
    class BaseGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      protected

      def add_gem(name, version = nil)
        # Add gem to Gemfile, run bundle
      end

      def update_config(feature, settings)
        # Append to config/boilermaker.yml
      end

      def create_route_file(feature)
        # Create config/routes/{feature}.rb
        # Insert `draw :feature` into config/routes.rb
      end

      def append_seeds(content)
        # Append to db/seeds.rb with development guard
      end

      def prompt_for_scope
        # Interactive scope selection (account vs user)
      end
    end
  end
end
```

### 1.2 Route Infrastructure

**Files to create:**
- `config/routes/` directory
- Update `config/routes.rb` to support `draw :feature` pattern

**Pattern:**
```ruby
# config/routes.rb
Rails.application.routes.draw do
  # ... existing routes ...

  # Feature routes (added by generators)
  draw :invitations if Boilermaker.config.feature_enabled?(:invitations)
  draw :notifications if Boilermaker.config.feature_enabled?(:notifications)
  # etc.
end
```

### 1.3 Feature Gate Concern

**Files to create:**
- `app/controllers/concerns/feature_gate.rb`

Provides `require_feature!(:feature_name)` method for controllers to block access when feature is disabled.

---

## Phase 2: Invitations Generator

**Command:** `bin/rails generate boilermaker:invitations`

### Files to Generate

**Models:**
- `app/models/invitation.rb` (account, email, invited_by, token, accepted_at, expires_at)

**Controllers:**
- `app/controllers/invitations_controller.rb` (new, create, accept)

**Views:**
- `app/views/invitations/new.rb` - Invitation form
- `app/views/invitations/accept.rb` - Accept invitation page (handles existing vs new user)

**Mailers:**
- `app/mailers/invitation_mailer.rb`
- `app/views/invitation_mailer/invite.html.erb`
- `app/views/invitation_mailer/invite.text.erb`

**Migrations:**
- `db/migrate/xxx_create_invitations.rb`

**Routes:**
- `config/routes/invitations.rb`

**Tests:**
- `test/models/invitation_test.rb`
- `test/controllers/invitations_controller_test.rb`
- `test/mailers/invitation_mailer_test.rb`

### Integration Points

- Account admin section: Add invitation list to `app/views/accounts/` (documented, not auto-injected)
- Permissions: Only owner/admin roles can send invitations

---

## Phase 3: Impersonation Generator

**Command:** `bin/rails generate boilermaker:impersonation`

### Files to Generate/Enhance

**Controllers:**
- Enhance `app/controllers/masquerades_controller.rb`:
  - Add `destroy` action
  - Add session tracking (store original user ID)
  - Add audit logging hook (if audit_log installed)

**Components:**
- `app/components/impersonation_banner.rb` - "You are impersonating X" banner with exit link

**Views:**
- Document slot usage in AppHeader for banner placement

**Routes:**
- `config/routes/impersonation.rb`

**Tests:**
- `test/controllers/masquerades_controller_test.rb` (enhance existing)

### Constraints

- Only admin role can impersonate
- Cannot impersonate other admins
- Logs impersonation start/end if audit_log feature present

---

## Phase 4: Notifications Generator

**Command:** `bin/rails generate boilermaker:notifications`

### Interactive Prompt

```
This feature can be scoped to:
  [1] Account - Notifications belong to team/organization
  [2] User    - Each user has their own notifications

Select scope: _
```

### Gems Required

- `noticed` (~> 2.0)

### Files to Generate

**Configuration:**
- `config/initializers/noticed.rb`

**Models:**
- Noticed handles `Notification` model via its migrations

**Controllers:**
- `app/controllers/notifications_controller.rb` (index, mark_read, mark_all_read)

**Views:**
- `app/views/notifications/index.rb` - Notification list page
- `app/views/settings/notifications.rb` - Notification preferences

**Components:**
- `app/components/notification_bell.rb` - Header bell with unread count
- `app/components/notification_dropdown.rb` - Dropdown list

**Notifiers:**
- `app/notifiers/welcome_notifier.rb` - Example notifier
- `app/notifiers/application_notifier.rb` - Base class

**Routes:**
- `config/routes/notifications.rb`

**Seeds:**
- Sample notifications for development

**Tests:**
- `test/controllers/notifications_controller_test.rb`
- `test/notifiers/welcome_notifier_test.rb`

### Delivery Channels

- Database (always, for in-app bell)
- Email (per notification type)

---

## Phase 5: Payments Generator

**Command:** `bin/rails generate boilermaker:payments`

### Interactive Prompt

```
This feature can be scoped to:
  [1] Account - One subscription per team/organization
  [2] User    - Each user has their own subscription

Select scope: _
```

### Gems Required

- `pay` (~> 7.0)

### Files to Generate

**Configuration:**
- `config/initializers/pay.rb` - Pay configuration for Stripe

**Controllers:**
- `app/controllers/payments_controller.rb` (checkout, portal, webhooks)

**Views:**
- `app/views/payments/pricing.rb` - Pricing page
- `app/views/settings/billing.rb` - Billing settings page

**Components:**
- `app/components/pricing_card.rb` - Plan display card
- `app/components/subscription_status.rb` - Current subscription display

**Routes:**
- `config/routes/payments.rb`

**Seeds:**
- Sample plan data for development

**Tests:**
- `test/controllers/payments_controller_test.rb`

### Pay Integration

- Run `pay:install:migrations`
- Configure webhook route
- Use `Pay::Subscription`, `Pay::Customer` directly (no wrappers)

### Next Steps Output

```
1. Run migrations: bin/rails db:migrate
2. Configure Stripe keys: bin/rails credentials:edit
   Add: stripe: { private_key: sk_xxx, public_key: pk_xxx, webhook_secret: whsec_xxx }
3. Create plans in Stripe dashboard
4. Set webhook URL: https://yourapp.com/pay/webhooks/stripe
```

---

## Phase 6: File Uploads Generator

**Command:** `bin/rails generate boilermaker:uploads`

### Files to Generate

**Configuration:**
- Run `active_storage:install` if needed
- `config/storage.yml` updates (document cloud setup)

**Components:**
- `app/components/file_upload.rb` - Drag-drop with progress
- `app/components/file_preview.rb` - Image/document preview
- `app/components/file_list.rb` - Attached files list

**JavaScript:**
- `app/javascript/controllers/file_upload_controller.js` - Stimulus controller for direct uploads

**Routes:**
- `config/routes/uploads.rb` (for any standalone endpoints)

**Tests:**
- `test/components/file_upload_test.rb`
- `test/components/file_preview_test.rb`

### What It Does NOT Generate

- Image processing/variants (user adds)
- Model attachments (user adds `has_one_attached`)
- Cloud configuration (user configures for production)

---

## Phase 7: Audit Logging Generator

**Command:** `bin/rails generate boilermaker:audit_log`

### Files to Generate

**Models:**
- `app/models/audit_log.rb` (user, action, auditable_type/id, changes, ip_address, user_agent, metadata)
- `app/models/concerns/auditable.rb` - Explicit opt-in concern

**Controllers:**
- `app/controllers/admin/audit_logs_controller.rb` (index with search, export)

**Views:**
- `app/views/admin/audit_logs/index.rb` - Log viewer with filters

**Jobs:**
- `app/jobs/audit_log_cleanup_job.rb` - SolidQueue recurring job

**Configuration:**
- `config/initializers/audit_log.rb` - Auto-track User, Account, Session

**Migrations:**
- `db/migrate/xxx_create_audit_logs.rb`

**Routes:**
- `config/routes/audit_log.rb`

**Tests:**
- `test/models/audit_log_test.rb`
- `test/models/concerns/auditable_test.rb`
- `test/controllers/admin/audit_logs_controller_test.rb`

### Config Options

```yaml
features:
  audit_log: true
  audit_log_retention_days: 90
```

---

## Implementation Order

1. **Generator Framework** (Phase 1) - Foundation for all generators
2. **Invitations** (Phase 2) - No external gems, straightforward
3. **Impersonation** (Phase 3) - Enhances existing code, simple
4. **Notifications** (Phase 4) - Noticed gem integration
5. **Payments** (Phase 5) - Pay gem integration
6. **Uploads** (Phase 6) - ActiveStorage integration
7. **Audit Logging** (Phase 7) - SolidQueue recurring jobs

---

## Success Criteria

From spec - all must pass:

- [ ] Generator framework exists in `lib/generators/boilermaker/`
- [ ] All 6 feature generators implemented
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

---

## Estimated Effort

| Phase | Description | Complexity |
|-------|-------------|------------|
| 1 | Generator Framework | Medium |
| 2 | Invitations | Low |
| 3 | Impersonation | Low |
| 4 | Notifications | Medium |
| 5 | Payments | Medium |
| 6 | Uploads | Low |
| 7 | Audit Logging | Medium |

---

## Dependencies

- Existing Phlex component patterns
- Existing settings page structure
- Existing account/user models
- SolidQueue for recurring jobs
- External gems: Pay, Noticed
