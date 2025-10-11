# DHH Code Review: Two-Factor Authentication Integration Spec v1b

**Spec Version:** 1b
**Reviewed:** 2025-10-08

## Overall Assessment

Much better. You addressed the major concerns from v1a. The spec is now clean, follows Rails conventions, and avoids unnecessary abstractions. A few minor refinements needed, but this is nearly production-ready.

**Grade: A-**

## What's Better in v1b

✅ **Removed model aliases** - Using `otp_required_for_sign_in?` directly
✅ **Merged into TotpsController** - RESTful `#destroy` action instead of separate controller
✅ **Added transaction** - Atomic disable operation
✅ **Simplified enforcement** - `skip_before_action` pattern is cleaner
✅ **No configuration leakage in models** - Removed `requires_two_factor_setup?`

These changes make the code significantly better.

## Remaining Issues

### 1. Turbo Frame Usage - Maybe Over-Engineering?

In the settings view:
```ruby
link_to "Disable Two-Factor Authentication",
        two_factor_authentication_profile_totp_path,
        class: "btn btn-sm btn-outline btn-error",
        data: { turbo_method: :delete, turbo_frame: "disable_2fa_form" }
```

And then you have a Turbo Frame that loads an inline form.

**Questions:**
1. Why not just link to a dedicated disable confirmation page?
2. Or use a Turbo Modal if you want inline experience?
3. The Turbo Frame approach adds complexity - is the UX gain worth it?

**Simpler alternative:**
```ruby
# Just link to the destroy view
link_to "Disable Two-Factor Authentication",
        two_factor_authentication_profile_totp_path(confirm: true),
        class: "btn btn-sm btn-outline btn-error"

# TotpsController#destroy (GET)
def destroy
  # Show confirmation page
  render Views::TwoFactorAuthentication::Profile::Totps::Destroy.new
end

# Then form submits DELETE
```

Or even simpler - show the confirmation page on GET, process on DELETE:
```ruby
# routes.rb
resource :totp, only: [:new, :create, :update] do
  get :destroy_confirmation, on: :member  # Optional: explicit confirmation page
  delete :destroy, on: :member
end
```

**My take:** The Turbo Frame approach isn't bad, but ask yourself: does it solve a real UX problem or just add complexity? If users rarely disable 2FA, a simple confirmation page is fine.

### 2. View Naming - `destroy.rb` Renders a Form?

```ruby
# app/views/two_factor_authentication/profile/totps/destroy.rb
class Destroy < Views::Base
  # ... renders a form for confirmation ...
end
```

**Problem:** The `destroy` action name usually implies the action has been completed. This view is actually showing a confirmation form **before** destruction.

**Better naming:**
- Name the view `destroy_confirmation.rb` or `disable_confirmation.rb`
- Or handle it in the `destroy` action and render different content based on whether it's GET (show form) or DELETE (process)

**Clearest approach:**
```ruby
# Controller - one action, two behaviors
def destroy
  if request.delete?
    # Process disable with TOTP verification
    totp = ROTP::TOTP.new(@user.otp_secret, issuer: "Boilermaker")
    if totp.verify(params[:code], drift_behind: 15)
      @user.disable_two_factor!
      redirect_to settings_path, notice: "Two-factor authentication has been disabled"
    else
      render :destroy, status: :unprocessable_entity
    end
  else
    # GET - show confirmation form
    render Views::TwoFactorAuthentication::Profile::Totps::DestroyConfirmation.new
  end
end
```

Or split into two actions if you prefer clarity:
```ruby
def destroy_confirmation
  # GET - show form
end

def destroy
  # DELETE - process
end
```

I prefer the split. It's clearer what each action does.

### 3. Transaction Test - That's Not How You Test Transactions

```ruby
test "disable_two_factor! is atomic" do
  user = users(:one)
  user.update!(otp_required_for_sign_in: true)

  # Simulate failure during recovery code deletion
  user.recovery_codes.stub(:delete_all, -> { raise ActiveRecord::Rollback }) do
    assert_raises(ActiveRecord::Rollback) do
      user.disable_two_factor!
    end
  end

  assert user.reload.otp_required_for_sign_in?
end
```

**Problems:**
1. `stub` is not a standard Minitest method (you're thinking of Mocha or similar)
2. Raising `ActiveRecord::Rollback` doesn't work that way—it's caught by the transaction block
3. This test won't work as written

**How to actually test atomicity:**

**Option A:** Cause a validation failure
```ruby
test "disable_two_factor! rolls back on failure" do
  user = users(:one)
  user.update!(otp_required_for_sign_in: true)
  user.recovery_codes.create!(code: "test123")

  # Cause update to fail
  user.define_singleton_method(:update!) { raise ActiveRecord::RecordInvalid }

  assert_raises(ActiveRecord::RecordInvalid) do
    user.disable_two_factor!
  end

  # Verify rollback
  assert user.reload.otp_required_for_sign_in?
  assert_equal 1, user.recovery_codes.count
end
```

**Option B:** Just trust Rails transactions work (they do)
```ruby
# Don't test Rails internals - test your business logic
test "disable_two_factor! disables 2FA and deletes recovery codes" do
  user = users(:one)
  user.update!(otp_required_for_sign_in: true)
  user.recovery_codes.create!(code: "test123")

  user.disable_two_factor!

  refute user.reload.otp_required_for_sign_in?
  assert_equal 0, user.recovery_codes.count
end
```

**Recommendation:** Option B. Don't test Rails transaction behavior—test that your method does what it says.

### 4. Error Handling in Destroy Action

```ruby
def destroy
  totp = ROTP::TOTP.new(@user.otp_secret, issuer: "Boilermaker")

  if totp.verify(params[:code], drift_behind: 15)
    @user.disable_two_factor!
    redirect_to settings_path, notice: "Two-factor authentication has been disabled"
  else
    render Views::TwoFactorAuthentication::Profile::Totps::Destroy.new, status: :unprocessable_entity
  end
end
```

**Missing:** Flash alert for invalid code.

**Better:**
```ruby
else
  flash.now[:alert] = "That code didn't work. Please try again"
  render Views::TwoFactorAuthentication::Profile::Totps::Destroy.new, status: :unprocessable_entity
end
```

Or pass the error to the view:
```ruby
else
  render Views::TwoFactorAuthentication::Profile::Totps::Destroy.new(
    error: "That code didn't work. Please try again"
  ), status: :unprocessable_entity
end
```

Either works. Pick one and be consistent.

## Minor Observations

### OTP Secret Persistence Note

You mention keeping `otp_secret` after disable for easy re-enable. That's reasonable, but worth documenting **why** in a code comment:

```ruby
def disable_two_factor!
  transaction do
    update!(otp_required_for_sign_in: false)
    recovery_codes.delete_all
    # Note: otp_secret is kept to allow re-enabling without re-scanning QR code
    # Users can regenerate via TotpsController#update if they want a fresh secret
  end
end
```

Helps future developers understand the decision.

### Test Helper Naming

```ruby
def with_config(**overrides)
```

This is fine, but consider more specific helpers for common cases:

```ruby
def with_required_2fa
  with_config(require_two_factor_authentication: true) { yield }
end

# Usage
with_required_2fa do
  # test code
end
```

Reads better in tests. But the general `with_config` is good to have too.

## Recommendations Summary

**Must Address:**
1. Add flash message for invalid TOTP code in `destroy` action
2. Fix the transaction test (or remove it and trust Rails)
3. Clarify destroy view naming (`DestroyConfirmation` vs `Destroy`)

**Should Consider:**
4. Reconsider Turbo Frame complexity—is a simple confirmation page better?
5. Add comment explaining why `otp_secret` persists after disable

**Nice to Have:**
6. Specific test helpers like `with_required_2fa`

## Final Verdict

**Approved with minor changes.** Address the "Must" items and you're good to go.

This is clean Rails code. The architecture is sound, patterns are conventional, and there's no over-engineering. Well done on the revisions.

---

**Overall Grade: A-**
One more quick iteration to address the must-fix items and this hits A territory.
