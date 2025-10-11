# DHH Code Review: Two-Factor Authentication Integration Spec

**Spec Version:** 1a
**Reviewed:** 2025-10-08

## Overall Assessment

The spec is solid and follows Rails conventions well. A few areas could be simplified, and some patterns could be more direct. Here's what needs attention:

## Critical Feedback

### 1. Helper Methods in User Model - Good, But One Concerns Me

```ruby
def two_factor_enabled?
  otp_required_for_sign_in?
end
```

**Problem:** This is just an alias. Why not use `otp_required_for_sign_in?` directly everywhere? Aliases without semantic value add cognitive overhead.

**Alternative Approaches:**

**Option A (Recommended):** Drop the alias, use `otp_required_for_sign_in?` directly
```ruby
# In views and controllers
if Current.user.otp_required_for_sign_in?
  # ...
end
```

**Option B:** If you really want better naming, rename the column itself via migration
```ruby
# Migration
rename_column :users, :otp_required_for_sign_in, :two_factor_enabled

# Model
alias_attribute :otp_required_for_sign_in, :two_factor_enabled  # For backwards compat if needed
```

**Decision Point:** Is `two_factor_enabled?` meaningfully clearer than `otp_required_for_sign_in?`? If not, drop it. If yes, rename the column.

### 2. The `requires_two_factor_setup?` Method - Configuration Leakage

```ruby
def requires_two_factor_setup?
  Boilermaker.config.require_two_factor_authentication? && !two_factor_enabled?
end
```

**Problem:** Model methods shouldn't know about application-level config. This is a controller/view concern.

**Better:** Keep this logic in the controller where it belongs:

```ruby
# In ApplicationController
def enforce_two_factor_setup
  return unless Current.user
  return unless Boilermaker.config.require_two_factor_authentication?
  return if Current.user.otp_required_for_sign_in?
  # ...
end
```

The view can check the same conditions directly:
```ruby
# In view
if Boilermaker.config.require_two_factor_authentication? && !Current.user.otp_required_for_sign_in?
  # Show "Setup Required" badge
end
```

Don't hide simple boolean logic behind model methods. It's not business logic—it's presentation logic.

### 3. DisablesController Name - Rails Naming Convention

**Current:**
```ruby
class TwoFactorAuthentication::Profile::DisablesController
```

**Problem:** "Disables" isn't a resource. You're not listing/showing "disables"—you're performing an action on the TOTP resource.

**Better:** Use a custom action on the existing controller:
```ruby
# In TotpsController
def destroy
  # Show confirmation form
end

def confirm_destroy
  # Actually disable with TOTP verification
end
```

Or if you insist on separation:
```ruby
class TwoFactorAuthentication::Profile::Totp::DisableController
  # Singular: disable, not disables
end
```

**Recommendation:** Add `destroy` and `confirm_destroy` to `TotpsController`. It's the same resource (TOTP settings), just different actions.

### 4. View Organization - Phlex Nesting

The spec proposes:
```ruby
module Views::TwoFactorAuthentication::Profile::Disables::New
```

**Problem:** If we're adding this to `TotpsController`, the view should be:
```ruby
module Views::TwoFactorAuthentication::Profile::Totps::Destroy
```

Keep views aligned with controller actions. Don't create new directories for every action.

### 5. Settings View - Extract Private Methods Are Good, But

The `render_two_factor_section`, `render_two_factor_status`, and `render_two_factor_actions` methods are fine, but watch for over-extraction.

**Good extraction:** When logic is reused or conceptually distinct.
**Bad extraction:** When you're just moving 10 lines down to avoid scrolling.

This case is borderline. The extractions are okay because they represent distinct UI concerns (status vs. actions), but don't go further.

### 6. Test Helper `with_config` - Smart

```ruby
def with_config(**overrides)
  # ...
end
```

**Feedback:** This is clean. Good job. One suggestion:

**Consider:** Making it even simpler if you only ever override one setting at a time:
```ruby
def with_required_2fa(value = true)
  with_config(require_two_factor_authentication: value) { yield }
end

# Usage
with_required_2fa do
  # test code
end
```

But the general `with_config` is fine if you foresee testing multiple config combinations.

### 7. Recovery Code Deletion - Silent Failure Risk

```ruby
@user.recovery_codes.delete_all  # Remove recovery codes when disabling
```

**Problem:** What if this fails? Should we wrap in a transaction?

**Better:**
```ruby
ActiveRecord::Base.transaction do
  @user.update!(otp_required_for_sign_in: false)
  @user.recovery_codes.delete_all
end
```

Ensures atomicity. Either both happen or neither does.

### 8. Flash Messages - Be Consistent

You have:
- "Two-factor authentication has been disabled"
- "That code didn't work. Please try again"
- "You must set up two-factor authentication to continue"

**Feedback:** Tone is good. Clear and direct. Just be consistent:
- Use sentence case (capitalize first word only) throughout
- End with periods or don't—pick one style
- Keep them short and actionable

Current messages are fine, just make sure the rest of the app matches this tone.

### 9. The Enforcement Logic - Could Be Simpler?

```ruby
def enforce_two_factor_setup
  return unless Current.user
  return unless Boilermaker.config.require_two_factor_authentication?
  return if Current.user.two_factor_enabled?

  return if controller_path.start_with?("two_factor_authentication/profile")
  return if controller_name == "sessions" && action_name == "destroy"

  redirect_to new_two_factor_authentication_profile_totp_path,
              alert: "You must set up two-factor authentication to continue"
end
```

**Concern:** The allowlist of routes (`controller_path.start_with?`, etc.) could grow brittle.

**Alternative:** Use `skip_before_action` in the controllers that need to bypass:
```ruby
# In TotpsController
skip_before_action :enforce_two_factor_setup

# In SessionsController
skip_before_action :enforce_two_factor_setup, only: [:destroy]
```

Then the enforcement logic becomes:
```ruby
def enforce_two_factor_setup
  return unless Current.user
  return unless Boilermaker.config.require_two_factor_authentication?
  return if Current.user.otp_required_for_sign_in?

  redirect_to new_two_factor_authentication_profile_totp_path,
              alert: "You must set up two-factor authentication to continue"
end
```

Cleaner, and puts the bypass logic where it belongs (in the controllers that need it).

### 10. Configuration Section Name - Minor Nit

```yaml
security:
  require_two_factor_authentication: false
  password_min_length: 12
```

**Observation:** You're mixing authentication settings (`require_two_factor_authentication`) with password policy (`password_min_length`).

**Suggestion:** Either:
1. Keep them together under `security` (current approach is fine)
2. Namespace more specifically:
```yaml
security:
  two_factor:
    required: false
  password:
    min_length: 12
```

Current approach is fine. Only change if you add many more security settings and need better organization.

## What's Good

### Following The Rails Way
- Fat model methods for `disable_two_factor!` ✓
- Controller stays thin, delegates to model ✓
- Using Rails naming conventions for routes ✓
- No unnecessary service objects or abstractions ✓

### Security Considerations
- TOTP verification required to disable ✓
- Recovery codes deleted on disable ✓
- Immediate enforcement when mandatory ✓
- Session-based approach (no JWT nonsense) ✓

### Testing Strategy
- Real database tests, no mocking ✓
- Integration tests cover full flows ✓
- System tests for user journeys ✓
- Fixtures over factories ✓

## Recommendations Summary

**Must Fix:**
1. ~~`two_factor_enabled?` alias~~ - Drop it or rename the column
2. ~~`requires_two_factor_setup?` in model~~ - Move to controller/view
3. Wrap recovery code deletion in transaction

**Should Consider:**
4. Rename `DisablesController` or merge into `TotpsController` as `#destroy`
5. Use `skip_before_action` instead of allowlist in `enforce_two_factor_setup`

**Nice to Have:**
6. More specific test helper like `with_required_2fa`

## Final Verdict

**Approve with changes.** The spec is 85% there. Make the "Must Fix" changes and this will be clean, simple Rails code that DHH wouldn't complain about.

The pattern is solid. No over-engineering. No unnecessary abstractions. Just needs a few tweaks to be truly clean.

---

**Overall Grade: B+**
Would be an A after addressing the model method concerns and transaction safety.
