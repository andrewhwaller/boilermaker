# Two-Factor Authentication Integration

## Overview

Complete the integration of two-factor authentication (2FA) into the Boilermaker settings interface. The 2FA implementation using authentication-zero already exists but needs to be made accessible and manageable through the user settings page.

## Current State

The application already has:
- TOTP-based 2FA controllers (setup and challenge)
- Recovery codes generation and validation
- Phlex views for 2FA flows
- Database schema (otp_required_for_sign_in, otp_secret columns)
- Routes for 2FA profile and challenge flows
- Session flow integration (SessionsController checks otp_required_for_sign_in)

## Requirements

### 1. Settings Page Integration

Add a Two-Factor Authentication section to the Settings page (`app/views/settings/show.rb`) that allows users to:

- Enable 2FA if not currently enabled
- View their current 2FA status (enabled/disabled)
- Disable 2FA if currently enabled (only when 2FA is not mandatory)
- Regenerate recovery codes
- View existing recovery codes

### 2. Enable/Disable Flow

**Enable Flow:**
- User clicks "Enable Two-Factor Authentication" from Settings
- Redirect to existing `/two_factor_authentication/profile/totp/new` path
- User scans QR code and verifies TOTP code
- System sets `otp_required_for_sign_in: true`
- System generates 10 recovery codes
- User is shown recovery codes with download/copy option
- User returns to Settings page with success message

**Disable Flow:**
- Only available when `require_two_factor_authentication: false`
- User clicks "Disable Two-Factor Authentication" from Settings
- System prompts for current TOTP code to confirm (security requirement)
- Upon successful verification:
  - Set `otp_required_for_sign_in: false`
  - Optionally: keep otp_secret for re-enabling, or regenerate on next enable
  - Optionally: delete recovery codes or keep them
- Redirect to Settings with success message

### 3. Recovery Codes Management

Users with 2FA enabled should be able to:
- View a link to see their recovery codes (with TOTP verification required)
- Regenerate recovery codes (existing route at `/two_factor_authentication/profile/recovery_codes`)

### 4. Mandatory 2FA Configuration

Add a Boilermaker configuration option to allow apps to enforce 2FA for all users:

```yaml
# config/boilermaker.yml
security:
  require_two_factor_authentication: false  # Default: optional
```

**When `require_two_factor_authentication: true`:**
- Users without 2FA enabled are **immediately required** to set it up
- After successful authentication, redirect to 2FA setup flow before allowing access to the app
- No grace period - setup is mandatory and blocking
- Settings page shows 2FA as "Required" and does not allow disabling
- Disable button/option is hidden when 2FA is mandatory
- New registrations must complete 2FA setup as part of onboarding

**When `require_two_factor_authentication: false`:**
- 2FA is completely optional
- Users can enable/disable at will
- No prompts or redirects to setup

## Clarifications

1. **Enforcement vs. Optional**: 2FA should be optional by default, but we should add a Boilermaker config flag (`require_two_factor_authentication`) to allow apps using the template to force 2FA for all users.

2. **Recovery Mechanisms**: Use backup codes (already implemented). Users can download/print them. In the future, admins could have the ability to disable 2FA for a user if needed.

3. **2FA Methods**: Only support TOTP (time-based one-time passwords via apps like Google Authenticator). No SMS.

4. **Migration Strategy**: This is a greenfield starter repo, so no migration concerns for existing users.

5. **User Experience**: 2FA setup should be accessible from account settings. The existing setup flow at `/two_factor_authentication/profile/totp/new` can be used.

6. **Scope**: Apply to all authentication methods. No API tokens or service accounts exist currently.

7. **Immediate Enforcement**: When `require_two_factor_authentication: true`, users without 2FA are required to set it up immediately - no grace period, they cannot access the application until setup is complete.

## Success Criteria

- [ ] Users can enable 2FA from Settings page
- [ ] Users can disable 2FA from Settings page (with TOTP verification) when not mandatory
- [ ] Users can view/regenerate recovery codes from Settings page
- [ ] Settings page clearly shows current 2FA status
- [ ] Configuration flag exists to make 2FA mandatory app-wide
- [ ] When 2FA is mandatory and user doesn't have it enabled, they are immediately redirected to setup (blocking)
- [ ] When 2FA is mandatory, disable option is not shown in Settings
- [ ] All existing 2FA flows continue to work (login challenge, recovery codes)
- [ ] Tests cover enable/disable flows and settings integration
- [ ] Tests cover mandatory 2FA enforcement and blocking behavior
