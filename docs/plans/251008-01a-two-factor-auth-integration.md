# Two-Factor Authentication Integration - Implementation Specification

**Date:** 2025-10-08
**Version:** 1a (First Iteration)
**Status:** Draft

## Overview

This specification details the integration of existing two-factor authentication (2FA) functionality into the Boilermaker settings interface. The 2FA implementation using TOTP (Time-based One-Time Passwords) already exists; this work makes it accessible, manageable, and optionally mandatory for users.

### Goals

1. **Settings Integration**: Provide a clear, accessible interface in User Settings for managing 2FA
2. **Enable/Disable Flows**: Allow users to enable and securely disable 2FA
3. **Recovery Codes**: Integrate recovery code management into settings
4. **Mandatory 2FA**: Support app-wide 2FA enforcement via configuration
5. **Security First**: Require TOTP verification to disable 2FA, enforce immediate setup when mandatory

### Non-Goals

- SMS-based 2FA (TOTP only)
- Multiple 2FA methods per user
- Grace periods for mandatory 2FA enforcement

## Current State Analysis

### Existing Implementation

The application already has a complete 2FA implementation:

**Models:**
- `User` model with `otp_required_for_sign_in` (boolean) and `otp_secret` (string)
- `RecoveryCode` model with `user_id` and `code`
- `User` initializes `otp_secret` in `before_create` callback

**Controllers:**
- `TwoFactorAuthentication::Profile::TotpsController` - Setup flow (new, create, update)
- `TwoFactorAuthentication::Challenge::TotpsController` - Login challenge (new, create)
- `TwoFactorAuthentication::Profile::RecoveryCodesController` - Generate/view codes (index, create)
- `TwoFactorAuthentication::Challenge::RecoveryCodesController` - Use codes during login

**Views (Phlex):**
- `Views::TwoFactorAuthentication::Profile::Totps::New` - QR code and setup
- `Views::TwoFactorAuthentication::Challenge::Totps::New` - Login challenge
- `Views::TwoFactorAuthentication::Profile::RecoveryCodes::Index` - View/download codes

**Routes:**
```ruby
namespace :two_factor_authentication do
  namespace :profile do
    resources :recovery_codes, only: [ :index, :create ]
    resource  :totp,           only: [ :new, :create, :update ]
  end
  namespace :challenge do
    resource :recovery_codes, only: [ :new, :create ]
    resource :totp,           only: [ :new, :create ]
  end
end
```

**Authentication Flow:**
`SessionsController#create` checks `user.otp_required_for_sign_in?` and redirects to challenge if enabled.

### What's Missing

1. **Settings UI** - No interface in User Settings to manage 2FA
2. **Disable Flow** - No way to turn off 2FA once enabled
3. **Configuration** - No `require_two_factor_authentication` config flag
4. **Enforcement Logic** - No before_action to enforce mandatory 2FA
5. **Status Visibility** - No clear indication of current 2FA status

## Implementation Plan

### 1. Configuration Changes

**File:** `config/boilermaker.yml`

Add new security configuration section:

```yaml
default:
  app:
    name: Boilermaker
    support_email: support@example.com
  features:
    user_registration: true
    personal_accounts: false
  security:
    require_two_factor_authentication: false  # New: Make 2FA mandatory
    password_min_length: 12

development:
  security:
    require_two_factor_authentication: false  # Optional in dev

test:
  security:
    require_two_factor_authentication: false  # Optional in test

production:
  security:
    require_two_factor_authentication: false  # Configurable per deployment
```

**File:** `lib/boilermaker/configuration.rb`

Add accessor method:

```ruby
module Boilermaker
  class Configuration
    # Existing methods...

    def require_two_factor_authentication?
      config.dig("security", "require_two_factor_authentication") || false
    end
  end
end
```

### 2. Model Changes

**File:** `app/models/user.rb`

Add convenience methods for 2FA status:

```ruby
class User < ApplicationRecord
  # ... existing code ...

  # Check if user has 2FA enabled
  def two_factor_enabled?
    otp_required_for_sign_in?
  end

  # Check if user needs to set up 2FA
  def requires_two_factor_setup?
    Boilermaker.config.require_two_factor_authentication? && !two_factor_enabled?
  end

  # Disable 2FA
  def disable_two_factor!
    update!(otp_required_for_sign_in: false)
    # Note: Keep otp_secret for potential re-enabling
    # Could optionally regenerate: update!(otp_secret: ROTP::Base32.random)
  end
end
```

### 3. Controller Changes

#### 3.1 New Controller: Disable 2FA

**File:** `app/controllers/two_factor_authentication/profile/disables_controller.rb`

Create new controller to handle disabling 2FA with TOTP verification:

```ruby
class TwoFactorAuthentication::Profile::DisablesController < ApplicationController
  before_action :set_user
  before_action :ensure_two_factor_enabled
  before_action :ensure_not_mandatory

  def new
    # Show form requesting TOTP code to confirm disable
    render Views::TwoFactorAuthentication::Profile::Disables::New.new
  end

  def create
    totp = ROTP::TOTP.new(@user.otp_secret, issuer: "Boilermaker")

    if totp.verify(params[:code], drift_behind: 15)
      @user.disable_two_factor!
      @user.recovery_codes.delete_all  # Remove recovery codes when disabling
      redirect_to settings_path, notice: "Two-factor authentication has been disabled"
    else
      redirect_to new_two_factor_authentication_profile_disable_path,
                  alert: "That code didn't work. Please try again"
    end
  end

  private

  def set_user
    @user = Current.user
  end

  def ensure_two_factor_enabled
    unless @user.two_factor_enabled?
      redirect_to settings_path, alert: "Two-factor authentication is not enabled"
    end
  end

  def ensure_not_mandatory
    if Boilermaker.config.require_two_factor_authentication?
      redirect_to settings_path, alert: "Two-factor authentication is required and cannot be disabled"
    end
  end
end
```

#### 3.2 Update ApplicationController

**File:** `app/controllers/application_controller.rb`

Add before_action to enforce mandatory 2FA:

```ruby
class ApplicationController < ActionController::Base
  before_action :set_current_request_details
  before_action :authenticate
  before_action :set_current_account
  before_action :enforce_two_factor_setup  # New: Enforce mandatory 2FA
  before_action :set_theme
  before_action :ensure_verified

  # ... existing methods ...

  private

  def enforce_two_factor_setup
    return unless Current.user
    return unless Boilermaker.config.require_two_factor_authentication?
    return if Current.user.two_factor_enabled?

    # Allow access to 2FA setup routes
    return if controller_path.start_with?("two_factor_authentication/profile")

    # Allow sign out
    return if controller_name == "sessions" && action_name == "destroy"

    redirect_to new_two_factor_authentication_profile_totp_path,
                alert: "You must set up two-factor authentication to continue"
  end
end
```

### 4. Routing Changes

**File:** `config/routes.rb`

Add route for disabling 2FA:

```ruby
Rails.application.routes.draw do
  # ... existing routes ...

  # Two-factor authentication routes
  namespace :two_factor_authentication do
    namespace :profile do
      resources :recovery_codes, only: [ :index, :create ]
      resource  :totp,           only: [ :new, :create, :update ]
      resource  :disable,        only: [ :new, :create ]  # New: Disable 2FA
    end

    namespace :challenge do
      resource :recovery_codes, only: [ :new, :create ]
      resource :totp,           only: [ :new, :create ]
    end
  end

  # ... rest of routes ...
end
```

New routes generated:
- `GET  /two_factor_authentication/profile/disable/new` → `#new` (disable confirmation form)
- `POST /two_factor_authentication/profile/disable` → `#create` (perform disable)

### 5. View Changes

#### 5.1 Update Settings Page

**File:** `app/views/settings/show.rb`

Add 2FA section to settings:

```ruby
module Views
  module Settings
    class Show < Views::Base
      include Phlex::Rails::Helpers::TurboFrameTag
      include Phlex::Rails::Helpers::LinkTo
      include Phlex::Rails::Helpers::ButtonTo
      include ActionView::Helpers::DateHelper

      def initialize
      end

      def view_template
        page_with_title("Settings") do
          div(class: "flex items-start justify-between mb-4") do
            h1(class: "font-bold text-base-content") { "User Settings" }
          end

          div(class: "max-w-xl space-y-6") do
            render Components::Card.new(title: "Email", header_color: :primary) do
              turbo_frame_tag "profile_settings", class: "block" do
                render Views::Identity::Emails::EditFrame.new(user: Current.user)
              end
            end

            render Components::Card.new(title: "Password", header_color: :primary) do
              turbo_frame_tag "password_settings", class: "block" do
                render Views::Passwords::EditFrame.new(user: Current.user)
              end
            end

            # New: Two-Factor Authentication section
            render Components::Card.new(title: "Two-Factor Authentication", header_color: :primary) do
              render_two_factor_section
            end
          end
        end
      end

      private

      def render_two_factor_section
        div(class: "space-y-4") do
          render_two_factor_status
          render_two_factor_actions
        end
      end

      def render_two_factor_status
        div(class: "space-y-2") do
          if Current.user.two_factor_enabled?
            div(class: "flex items-center space-x-2") do
              span(class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800") do
                plain "Enabled"
              end
              if Boilermaker.config.require_two_factor_authentication?
                span(class: "text-sm text-base-content/60") { "(Required)" }
              end
            end
            p(class: "text-sm text-base-content/80") do
              plain "Your account is protected with two-factor authentication. "
              plain "You'll need to enter a code from your authenticator app when signing in."
            end
          else
            div(class: "flex items-center space-x-2") do
              span(class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800") do
                plain "Disabled"
              end
              if Boilermaker.config.require_two_factor_authentication?
                span(class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800") do
                  plain "Setup Required"
                end
              end
            end
            p(class: "text-sm text-base-content/80") do
              plain "Two-factor authentication adds an extra layer of security to your account."
            end
          end
        end
      end

      def render_two_factor_actions
        div(class: "flex flex-col space-y-2") do
          if Current.user.two_factor_enabled?
            # Show recovery codes link
            div do
              link_to "View Recovery Codes",
                      two_factor_authentication_profile_recovery_codes_path,
                      class: "btn btn-sm btn-outline"
            end

            # Show disable button (only if not mandatory)
            unless Boilermaker.config.require_two_factor_authentication?
              div do
                link_to "Disable Two-Factor Authentication",
                        new_two_factor_authentication_profile_disable_path,
                        class: "btn btn-sm btn-outline btn-error"
              end
            end
          else
            # Show enable button
            div do
              link_to "Enable Two-Factor Authentication",
                      new_two_factor_authentication_profile_totp_path,
                      class: "btn btn-sm btn-primary"
            end
          end
        end
      end
    end
  end
end
```

#### 5.2 New View: Disable Confirmation

**File:** `app/views/two_factor_authentication/profile/disables/new.rb`

Create view for disable confirmation:

```ruby
module Views
  module TwoFactorAuthentication
    module Profile
      module Disables
        class New < Views::Base
          include Phlex::Rails::Helpers::FormWith
          include Phlex::Rails::Helpers::Routes
          include Phlex::Rails::Helpers::LinkTo

          def initialize
          end

          def view_template
            page_with_title("Disable Two-Factor Authentication") do
              div(class: "max-w-xl mx-auto space-y-6") do
                div(class: "bg-yellow-50 border border-yellow-200 rounded-lg p-4") do
                  div(class: "flex") do
                    div(class: "flex-shrink-0") do
                      svg(
                        class: "h-5 w-5 text-yellow-400",
                        xmlns: "http://www.w3.org/2000/svg",
                        viewBox: "0 0 20 20",
                        fill: "currentColor"
                      ) do |s|
                        s.path(
                          fill_rule: "evenodd",
                          d: "M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z",
                          clip_rule: "evenodd"
                        )
                      end
                    end
                    div(class: "ml-3") do
                      h3(class: "text-sm font-medium text-yellow-800") do
                        plain "Warning: This will reduce your account security"
                      end
                      div(class: "mt-2 text-sm text-yellow-700") do
                        p do
                          plain "Disabling two-factor authentication will make your account less secure. "
                          plain "Only your password will be required to sign in."
                        end
                      end
                    end
                  end
                end

                div do
                  h2(class: "text-lg font-medium text-base-content") do
                    plain "Confirm by entering your current authentication code"
                  end
                  p(class: "mt-1 text-sm text-base-content/60") do
                    plain "Enter the 6-digit code from your authenticator app to confirm you want to disable two-factor authentication."
                  end
                end

                form_with(
                  url: two_factor_authentication_profile_disable_path,
                  method: :post,
                  class: "space-y-6"
                ) do |form|
                  div(class: "space-y-2") do
                    form.label :code, "Authentication Code", class: "block text-sm font-medium text-base-content"
                    form.text_field :code,
                                    class: "block w-full rounded-lg border-input-border shadow-sm focus:border-accent focus:ring-accent sm:text-sm",
                                    autocomplete: "one-time-code",
                                    required: true,
                                    autofocus: true,
                                    maxlength: 6,
                                    placeholder: "000000"
                  end

                  div(class: "flex items-center justify-between space-x-4") do
                    link_to "Cancel", settings_path, class: "btn btn-outline"
                    form.submit "Disable Two-Factor Authentication",
                                class: "btn btn-error"
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
```

### 6. User Flows

#### 6.1 Enable 2FA Flow

**Before:**
1. User has no way to enable 2FA from UI

**After:**
1. User navigates to Settings
2. Sees "Two-Factor Authentication" card showing "Disabled" status
3. Clicks "Enable Two-Factor Authentication" button
4. Redirected to `/two_factor_authentication/profile/totp/new`
5. Scans QR code with authenticator app
6. Enters verification code from app
7. System sets `otp_required_for_sign_in: true`
8. Redirected to recovery codes page (`/two_factor_authentication/profile/recovery_codes`)
9. System generates 10 recovery codes
10. User downloads/copies recovery codes
11. User returns to Settings via navigation
12. Sees "Enabled" status with "View Recovery Codes" and "Disable" options

#### 6.2 Disable 2FA Flow (Optional Mode)

**Before:**
1. No way to disable 2FA

**After:**
1. User navigates to Settings
2. Sees "Two-Factor Authentication" card showing "Enabled" status
3. Clicks "Disable Two-Factor Authentication" button (red/warning style)
4. Redirected to `/two_factor_authentication/profile/disable/new`
5. Sees warning about security implications
6. Enters current TOTP code from authenticator app
7. Clicks "Disable Two-Factor Authentication" button
8. System verifies TOTP code
9. If valid:
   - Sets `otp_required_for_sign_in: false`
   - Deletes all recovery codes
   - Redirects to Settings with success message
   - Shows "Disabled" status
10. If invalid:
   - Shows error message
   - Stays on disable confirmation page

#### 6.3 Mandatory 2FA Flow

**Before:**
1. No enforcement mechanism

**After (when `require_two_factor_authentication: true`):**

**For users without 2FA:**
1. User signs in successfully with email/password
2. ApplicationController `enforce_two_factor_setup` before_action fires
3. User is immediately redirected to `/two_factor_authentication/profile/totp/new`
4. Alert shown: "You must set up two-factor authentication to continue"
5. User cannot access any other part of the application until setup complete
6. After setup, user can access application normally

**For users with 2FA:**
1. Sign in flow includes TOTP challenge (already implemented)
2. Normal application access

**In Settings:**
1. 2FA status shows "Enabled (Required)"
2. Disable button is hidden
3. Only "View Recovery Codes" option available

### 7. Security Considerations

#### 7.1 Disable Requires TOTP Verification

**Problem:** Allowing users to disable 2FA without verification could allow an attacker with session access to reduce account security.

**Solution:** Require current TOTP code to disable, proving possession of authenticator device.

#### 7.2 Recovery Codes Deleted on Disable

**Problem:** Keeping recovery codes after disabling 2FA could allow their misuse.

**Solution:** Delete all recovery codes when 2FA is disabled. User must generate new codes if re-enabling.

#### 7.3 Mandatory 2FA Enforcement

**Problem:** Users could ignore 2FA setup and continue using the application insecurely.

**Solution:** When `require_two_factor_authentication: true`, block all routes except:
- 2FA setup routes (`two_factor_authentication/profile/*`)
- Sign out route (`sessions#destroy`)
- Redirect immediately after authentication

#### 7.4 Session Handling After 2FA Changes

**Current behavior:** Sessions persist after 2FA enable/disable.

**Consideration:** Should we invalidate other sessions when:
- Enabling 2FA? (Probably not - user may have multiple devices)
- Disabling 2FA? (Maybe - security risk indicator)

**Recommendation:** For V1, keep current behavior. Session invalidation could be added as future enhancement.

#### 7.5 OTP Secret Persistence

**Current behavior:** `otp_secret` is generated on user creation and persisted.

**On disable:** Keep `otp_secret` to allow re-enabling without re-scanning QR code.

**Alternative:** Regenerate `otp_secret` on disable, requiring QR scan on re-enable.

**Recommendation:** For V1, keep `otp_secret` on disable. Users who want to reset can use the existing "update" action in `TotpsController`.

### 8. Testing Strategy

#### 8.1 Model Tests

**File:** `test/models/user_test.rb`

```ruby
test "two_factor_enabled? returns true when otp_required_for_sign_in is true" do
  user = users(:one)
  user.update!(otp_required_for_sign_in: true)
  assert user.two_factor_enabled?
end

test "two_factor_enabled? returns false when otp_required_for_sign_in is false" do
  user = users(:one)
  user.update!(otp_required_for_sign_in: false)
  refute user.two_factor_enabled?
end

test "requires_two_factor_setup? returns true when mandatory and not enabled" do
  user = users(:one)
  user.update!(otp_required_for_sign_in: false)

  with_config(require_two_factor_authentication: true) do
    assert user.requires_two_factor_setup?
  end
end

test "requires_two_factor_setup? returns false when not mandatory" do
  user = users(:one)
  user.update!(otp_required_for_sign_in: false)

  with_config(require_two_factor_authentication: false) do
    refute user.requires_two_factor_setup?
  end
end

test "requires_two_factor_setup? returns false when already enabled" do
  user = users(:one)
  user.update!(otp_required_for_sign_in: true)

  with_config(require_two_factor_authentication: true) do
    refute user.requires_two_factor_setup?
  end
end

test "disable_two_factor! sets otp_required_for_sign_in to false" do
  user = users(:one)
  user.update!(otp_required_for_sign_in: true)

  user.disable_two_factor!

  refute user.otp_required_for_sign_in?
end

test "disable_two_factor! keeps otp_secret for re-enabling" do
  user = users(:one)
  original_secret = user.otp_secret
  user.update!(otp_required_for_sign_in: true)

  user.disable_two_factor!

  assert_equal original_secret, user.reload.otp_secret
end
```

#### 8.2 Controller Tests

**File:** `test/controllers/two_factor_authentication/profile/disables_controller_test.rb`

```ruby
require "test_helper"

class TwoFactorAuthentication::Profile::DisablesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @user.update!(otp_required_for_sign_in: true)
    sign_in @user
  end

  test "should get new" do
    get new_two_factor_authentication_profile_disable_url
    assert_response :success
  end

  test "should disable 2FA with valid code" do
    totp = ROTP::TOTP.new(@user.otp_secret, issuer: "Boilermaker")
    valid_code = totp.now

    post two_factor_authentication_profile_disable_url, params: { code: valid_code }

    assert_redirected_to settings_path
    assert_equal "Two-factor authentication has been disabled", flash[:notice]
    refute @user.reload.otp_required_for_sign_in?
  end

  test "should delete recovery codes when disabling 2FA" do
    @user.recovery_codes.create!(code: "test123456")
    totp = ROTP::TOTP.new(@user.otp_secret, issuer: "Boilermaker")
    valid_code = totp.now

    assert_difference "@user.recovery_codes.count", -1 do
      post two_factor_authentication_profile_disable_url, params: { code: valid_code }
    end
  end

  test "should not disable 2FA with invalid code" do
    post two_factor_authentication_profile_disable_url, params: { code: "000000" }

    assert_redirected_to new_two_factor_authentication_profile_disable_path
    assert_equal "That code didn't work. Please try again", flash[:alert]
    assert @user.reload.otp_required_for_sign_in?
  end

  test "should not allow disable when 2FA not enabled" do
    @user.update!(otp_required_for_sign_in: false)

    get new_two_factor_authentication_profile_disable_url

    assert_redirected_to settings_path
    assert_equal "Two-factor authentication is not enabled", flash[:alert]
  end

  test "should not allow disable when 2FA is mandatory" do
    with_config(require_two_factor_authentication: true) do
      get new_two_factor_authentication_profile_disable_url

      assert_redirected_to settings_path
      assert_match /required and cannot be disabled/, flash[:alert]
    end
  end
end
```

**File:** `test/controllers/application_controller_test.rb`

```ruby
test "enforces 2FA setup when mandatory and user has no 2FA" do
  @user = users(:one)
  @user.update!(otp_required_for_sign_in: false)
  sign_in @user

  with_config(require_two_factor_authentication: true) do
    get root_url

    assert_redirected_to new_two_factor_authentication_profile_totp_path
    assert_match /must set up two-factor authentication/, flash[:alert]
  end
end

test "does not enforce 2FA setup when user has 2FA enabled" do
  @user = users(:one)
  @user.update!(otp_required_for_sign_in: true)
  sign_in @user

  with_config(require_two_factor_authentication: true) do
    get root_url

    assert_response :success
  end
end

test "does not enforce 2FA setup when not mandatory" do
  @user = users(:one)
  @user.update!(otp_required_for_sign_in: false)
  sign_in @user

  with_config(require_two_factor_authentication: false) do
    get root_url

    assert_response :success
  end
end

test "allows access to 2FA setup routes when enforcement active" do
  @user = users(:one)
  @user.update!(otp_required_for_sign_in: false)
  sign_in @user

  with_config(require_two_factor_authentication: true) do
    get new_two_factor_authentication_profile_totp_url

    assert_response :success  # No redirect
  end
end

test "allows sign out when enforcement active" do
  @user = users(:one)
  @user.update!(otp_required_for_sign_in: false)
  sign_in @user

  with_config(require_two_factor_authentication: true) do
    delete session_url("current")

    assert_redirected_to root_path  # Sign out redirects normally
  end
end
```

#### 8.3 View/Component Tests

**File:** `test/views/settings/show_test.rb`

```ruby
require "test_helper"

class Views::Settings::ShowTest < ActionView::TestCase
  include Phlex::Testing::ViewHelper

  setup do
    @user = users(:one)
    Current.user = @user
  end

  test "shows disabled status when 2FA not enabled" do
    @user.update!(otp_required_for_sign_in: false)

    output = render Views::Settings::Show.new

    assert_includes output, "Disabled"
    assert_includes output, "Enable Two-Factor Authentication"
  end

  test "shows enabled status when 2FA enabled" do
    @user.update!(otp_required_for_sign_in: true)

    output = render Views::Settings::Show.new

    assert_includes output, "Enabled"
    assert_includes output, "View Recovery Codes"
    assert_includes output, "Disable Two-Factor Authentication"
  end

  test "shows required indicator when 2FA mandatory and enabled" do
    @user.update!(otp_required_for_sign_in: true)

    with_config(require_two_factor_authentication: true) do
      output = render Views::Settings::Show.new

      assert_includes output, "Required"
    end
  end

  test "hides disable button when 2FA mandatory" do
    @user.update!(otp_required_for_sign_in: true)

    with_config(require_two_factor_authentication: true) do
      output = render Views::Settings::Show.new

      refute_includes output, "Disable Two-Factor Authentication"
      assert_includes output, "View Recovery Codes"  # Still show this
    end
  end

  test "shows setup required indicator when 2FA mandatory and not enabled" do
    @user.update!(otp_required_for_sign_in: false)

    with_config(require_two_factor_authentication: true) do
      output = render Views::Settings::Show.new

      assert_includes output, "Setup Required"
    end
  end
end
```

#### 8.4 System/Integration Tests

**File:** `test/system/two_factor_authentication_test.rb`

```ruby
require "application_system_test_case"

class TwoFactorAuthenticationTest < ApplicationSystemTestCase
  test "user enables 2FA from settings" do
    user = users(:one)
    user.update!(otp_required_for_sign_in: false)
    sign_in_as user

    visit settings_path
    assert_text "Disabled"

    click_on "Enable Two-Factor Authentication"

    assert_current_path new_two_factor_authentication_profile_totp_path
    assert_selector "img[alt='QR Code']"

    # Enter valid code (would need to parse QR or use known secret in test)
    totp = ROTP::TOTP.new(user.otp_secret, issuer: "Boilermaker")
    fill_in "Code", with: totp.now
    click_on "Enable two-factor authentication"

    assert_text "recovery codes"
    assert_equal 10, user.recovery_codes.count
  end

  test "user disables 2FA from settings" do
    user = users(:one)
    user.update!(otp_required_for_sign_in: true)
    sign_in_as user

    visit settings_path
    assert_text "Enabled"

    click_on "Disable Two-Factor Authentication"

    assert_current_path new_two_factor_authentication_profile_disable_path
    assert_text "reduce your account security"

    totp = ROTP::TOTP.new(user.otp_secret, issuer: "Boilermaker")
    fill_in "Authentication Code", with: totp.now
    click_on "Disable Two-Factor Authentication"

    assert_current_path settings_path
    assert_text "has been disabled"
    assert_text "Disabled"
  end

  test "user without 2FA is redirected when mandatory" do
    user = users(:one)
    user.update!(otp_required_for_sign_in: false)

    with_config(require_two_factor_authentication: true) do
      sign_in_as user

      # Immediately redirected to setup
      assert_current_path new_two_factor_authentication_profile_totp_path
      assert_text "must set up two-factor authentication"

      # Cannot navigate elsewhere
      visit settings_path
      assert_current_path new_two_factor_authentication_profile_totp_path
    end
  end

  test "disable option hidden when 2FA mandatory" do
    user = users(:one)
    user.update!(otp_required_for_sign_in: true)

    with_config(require_two_factor_authentication: true) do
      sign_in_as user

      visit settings_path
      assert_text "Enabled"
      assert_text "(Required)"
      assert_no_text "Disable Two-Factor Authentication"
      assert_text "View Recovery Codes"  # Still available
    end
  end
end
```

#### 8.5 Test Helpers

**File:** `test/test_helper.rb`

Add helper for config overrides:

```ruby
module ActiveSupport
  class TestCase
    # ... existing helpers ...

    # Temporarily override config for testing
    def with_config(**overrides)
      original_config = Boilermaker.instance_variable_get(:@config)

      begin
        # Deep merge overrides into config
        new_config = original_config.deep_merge(
          Rails.env => overrides.transform_keys(&:to_s)
        )
        Boilermaker.instance_variable_set(:@config, Boilermaker::Configuration.new(new_config))

        yield
      ensure
        Boilermaker.instance_variable_set(:@config, original_config)
      end
    end
  end
end
```

### 9. File Summary

#### Files to Create

1. `app/controllers/two_factor_authentication/profile/disables_controller.rb` - Disable 2FA controller
2. `app/views/two_factor_authentication/profile/disables/new.rb` - Disable confirmation view
3. `test/controllers/two_factor_authentication/profile/disables_controller_test.rb` - Controller tests
4. `test/views/settings/show_test.rb` - Settings view tests
5. `test/system/two_factor_authentication_test.rb` - System tests

#### Files to Modify

1. `config/boilermaker.yml` - Add `security.require_two_factor_authentication` config
2. `lib/boilermaker/configuration.rb` - Add `require_two_factor_authentication?` method
3. `app/models/user.rb` - Add `two_factor_enabled?`, `requires_two_factor_setup?`, `disable_two_factor!` methods
4. `app/controllers/application_controller.rb` - Add `enforce_two_factor_setup` before_action
5. `app/views/settings/show.rb` - Add 2FA section to settings page
6. `config/routes.rb` - Add disable route
7. `test/models/user_test.rb` - Add tests for new User methods
8. `test/controllers/application_controller_test.rb` - Add enforcement tests
9. `test/test_helper.rb` - Add `with_config` test helper

### 10. Migration Plan

**No database migrations required.** All necessary columns already exist:
- `users.otp_required_for_sign_in` (boolean)
- `users.otp_secret` (string)
- `recovery_codes` table

### 11. Deployment Considerations

#### 11.1 Configuration Rollout

For production deployments wanting to enforce 2FA:

1. **Phase 1:** Deploy code with `require_two_factor_authentication: false`
2. **Phase 2:** Notify users via email about upcoming 2FA requirement
3. **Phase 3:** Set `require_two_factor_authentication: true` in production config
4. **Phase 4:** Users without 2FA are immediately prompted on next login

#### 11.2 Rollback Plan

If issues arise:
1. Set `require_two_factor_authentication: false` in production config
2. No code rollback needed - feature degrades gracefully

### 12. Future Enhancements

**Not included in V1, potential future work:**

1. **Audit Log:** Record 2FA enable/disable events with timestamps
2. **Session Invalidation:** Invalidate other sessions when disabling 2FA

### 13. Success Criteria

Implementation is complete when:

- [ ] Users can enable 2FA from Settings page
- [ ] Users can disable 2FA from Settings page (with TOTP verification) when not mandatory
- [ ] Users can view/regenerate recovery codes from Settings page
- [ ] Settings page clearly shows current 2FA status (enabled/disabled)
- [ ] Settings page shows if 2FA is mandatory
- [ ] Configuration flag exists: `Boilermaker.config.require_two_factor_authentication?`
- [ ] When 2FA is mandatory, users without it are immediately redirected to setup
- [ ] When 2FA is mandatory, disable option is hidden in Settings
- [ ] All existing 2FA flows continue to work (login challenge, recovery codes)
- [ ] All tests pass with 100% coverage of new code
- [ ] Documentation updated in relevant files

---

**End of Specification Version 1a**
