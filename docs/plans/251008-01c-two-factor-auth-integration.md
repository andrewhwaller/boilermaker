# Two-Factor Authentication Integration - Implementation Specification

**Date:** 2025-10-08
**Version:** 1c (Final Iteration)
**Status:** Ready for Implementation

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

## Changes from Version 1b (DHH Feedback)

1. **Simplified disable flow** - Removed Turbo Frame complexity, use simple confirmation page
2. **Better view naming** - `DestroyConfirmation` instead of `Destroy`
3. **Added flash message** - Show error when TOTP code is invalid
4. **Improved transaction test** - Simplified to test business logic, not Rails internals
5. **Added code comment** - Explain why `otp_secret` persists after disable
6. **Added test helper** - Specific `with_required_2fa` helper for readability

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
    require_two_factor_authentication: false

test:
  security:
    require_two_factor_authentication: false

production:
  security:
    require_two_factor_authentication: false
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

Add method to disable 2FA with atomic transaction:

```ruby
class User < ApplicationRecord
  # ... existing code ...

  # Disable 2FA and remove recovery codes atomically
  def disable_two_factor!
    transaction do
      update!(otp_required_for_sign_in: false)
      recovery_codes.delete_all
      # Note: otp_secret is intentionally kept to allow re-enabling without re-scanning QR code
      # Users can regenerate secret via TotpsController#update if desired
    end
  end
end
```

### 3. Controller Changes

#### 3.1 Update TotpsController: Add Destroy Actions

**File:** `app/controllers/two_factor_authentication/profile/totps_controller.rb`

Add `destroy_confirmation` and `destroy` actions to existing controller:

```ruby
class TwoFactorAuthentication::Profile::TotpsController < ApplicationController
  skip_before_action :enforce_two_factor_setup  # Allow access even when enforcement active

  before_action :set_user
  before_action :set_totp, only: %i[ new create ]
  before_action :ensure_can_disable, only: %i[ destroy_confirmation destroy ]

  def new
    qr_code = RQRCode::QRCode.new(provisioning_uri)
    @qr_code_data_url = qr_code.as_png(
      bit_depth: 1,
      border_modules: 4,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: "black",
      file: nil,
      fill: "white",
      module_px_size: 6,
      resize_exactly_to: false,
      resize_gte_to: false,
      size: 200
    ).to_data_url
    render Views::TwoFactorAuthentication::Profile::Totps::New.new(totp: @totp, qr_code: @qr_code_data_url)
  end

  def create
    if @totp.verify(params[:code], drift_behind: 15)
      @user.update! otp_required_for_sign_in: true
      redirect_to two_factor_authentication_profile_recovery_codes_path
    else
      redirect_to new_two_factor_authentication_profile_totp_path, alert: "That code didn't work. Please try again"
    end
  end

  def update
    @user.update! otp_secret: ROTP::Base32.random
    redirect_to new_two_factor_authentication_profile_totp_path
  end

  # New: Show disable confirmation page
  def destroy_confirmation
    render Views::TwoFactorAuthentication::Profile::Totps::DestroyConfirmation.new
  end

  # New: Disable 2FA with TOTP verification
  def destroy
    totp = ROTP::TOTP.new(@user.otp_secret, issuer: "Boilermaker")

    if totp.verify(params[:code], drift_behind: 15)
      @user.disable_two_factor!
      redirect_to settings_path, notice: "Two-factor authentication has been disabled"
    else
      flash.now[:alert] = "That code didn't work. Please try again"
      render Views::TwoFactorAuthentication::Profile::Totps::DestroyConfirmation.new, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = Current.user
  end

  def set_totp
    @totp = ROTP::TOTP.new(@user.otp_secret, issuer: "Boilermaker")
  end

  def provisioning_uri
    @totp.provisioning_uri @user.email
  end

  # Ensure 2FA can be disabled
  def ensure_can_disable
    unless @user.otp_required_for_sign_in?
      redirect_to settings_path, alert: "Two-factor authentication is not enabled"
    end

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
    return if Current.user.otp_required_for_sign_in?

    redirect_to new_two_factor_authentication_profile_totp_path,
                alert: "You must set up two-factor authentication to continue"
  end
end
```

#### 3.3 Update RecoveryCodesController

**File:** `app/controllers/two_factor_authentication/profile/recovery_codes_controller.rb`

Add `skip_before_action`:

```ruby
class TwoFactorAuthentication::Profile::RecoveryCodesController < ApplicationController
  skip_before_action :enforce_two_factor_setup  # Allow access even when enforcement active

  before_action :set_user

  # ... rest of existing code ...
end
```

#### 3.4 Update SessionsController

**File:** `app/controllers/sessions_controller.rb`

Add `skip_before_action` for destroy:

```ruby
class SessionsController < ApplicationController
  skip_before_action :authenticate, only: %i[ new create ]
  skip_before_action :ensure_verified
  skip_before_action :enforce_two_factor_setup, only: %i[ destroy ]  # New: Allow sign out

  # ... rest of existing code ...
end
```

### 4. Routing Changes

**File:** `config/routes.rb`

Add routes for disable confirmation and destroy:

```ruby
Rails.application.routes.draw do
  # ... existing routes ...

  # Two-factor authentication routes
  namespace :two_factor_authentication do
    namespace :profile do
      resources :recovery_codes, only: [ :index, :create ]
      resource  :totp,           only: [ :new, :create, :update, :destroy ] do
        get :destroy_confirmation, on: :member  # New: Confirmation page
      end
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
- `GET /two_factor_authentication/profile/totp/destroy_confirmation` → `TotpsController#destroy_confirmation`
- `DELETE /two_factor_authentication/profile/totp` → `TotpsController#destroy`

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
          if Current.user.otp_required_for_sign_in?
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
          if Current.user.otp_required_for_sign_in?
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
                        destroy_confirmation_two_factor_authentication_profile_totp_path,
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

#### 5.2 New View: Disable Confirmation Page

**File:** `app/views/two_factor_authentication/profile/totps/destroy_confirmation.rb`

Create simple confirmation page:

```ruby
module Views
  module TwoFactorAuthentication
    module Profile
      module Totps
        class DestroyConfirmation < Views::Base
          include Phlex::Rails::Helpers::FormWith
          include Phlex::Rails::Helpers::Routes
          include Phlex::Rails::Helpers::LinkTo

          def initialize
          end

          def view_template
            page_with_title("Disable Two-Factor Authentication") do
              div(class: "max-w-xl mx-auto space-y-6") do
                # Warning banner
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

                # Confirmation instructions
                div do
                  h2(class: "text-lg font-medium text-base-content") do
                    plain "Confirm by entering your current authentication code"
                  end
                  p(class: "mt-1 text-sm text-base-content/60") do
                    plain "Enter the 6-digit code from your authenticator app to confirm you want to disable two-factor authentication."
                  end
                end

                # Confirmation form
                form_with(
                  url: two_factor_authentication_profile_totp_path,
                  method: :delete,
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

1. User navigates to Settings
2. Sees "Two-Factor Authentication" card showing "Disabled" status
3. Clicks "Enable Two-Factor Authentication" button
4. Redirected to `/two_factor_authentication/profile/totp/new`
5. Scans QR code with authenticator app
6. Enters verification code from app
7. System sets `otp_required_for_sign_in: true`
8. Redirected to recovery codes page
9. System generates 10 recovery codes
10. User downloads/copies recovery codes
11. User returns to Settings
12. Sees "Enabled" status with action buttons

#### 6.2 Disable 2FA Flow (Optional Mode)

1. User navigates to Settings
2. Sees "Two-Factor Authentication" card showing "Enabled" status
3. Clicks "Disable Two-Factor Authentication" button
4. Navigates to `/two_factor_authentication/profile/totp/destroy_confirmation`
5. Sees warning and confirmation form
6. Enters current TOTP code from authenticator app
7. Clicks "Disable Two-Factor Authentication" button
8. System verifies TOTP code
9. If valid:
   - Transaction: Sets `otp_required_for_sign_in: false` + deletes recovery codes
   - Redirects to Settings with success message
10. If invalid:
   - Re-renders form with flash alert

#### 6.3 Mandatory 2FA Flow

**For users without 2FA:**
1. User signs in with email/password
2. `enforce_two_factor_setup` before_action fires
3. Immediately redirected to `/two_factor_authentication/profile/totp/new`
4. Alert: "You must set up two-factor authentication to continue"
5. User completes setup
6. Normal application access granted

**For users with 2FA:**
1. Sign in includes TOTP challenge (existing flow)
2. Normal application access

**In Settings:**
1. Status shows "Enabled (Required)"
2. Disable button hidden
3. "View Recovery Codes" available

### 7. Security Considerations

#### 7.1 Atomic Disable Operation

Transaction ensures both operations succeed or fail together:
```ruby
def disable_two_factor!
  transaction do
    update!(otp_required_for_sign_in: false)
    recovery_codes.delete_all
  end
end
```

#### 7.2 TOTP Verification Required

Must provide valid TOTP code to disable, preventing session hijack attacks.

#### 7.3 Enforcement via skip_before_action

Controllers explicitly opt out of enforcement, making the allowlist visible and maintainable.

### 8. Testing Strategy

#### 8.1 Model Tests

**File:** `test/models/user_test.rb`

```ruby
test "disable_two_factor! sets otp_required_for_sign_in to false" do
  user = users(:one)
  user.update!(otp_required_for_sign_in: true)

  user.disable_two_factor!

  refute user.reload.otp_required_for_sign_in?
end

test "disable_two_factor! deletes all recovery codes" do
  user = users(:one)
  user.update!(otp_required_for_sign_in: true)
  user.recovery_codes.create!(code: "test123456")
  user.recovery_codes.create!(code: "test789012")

  assert_difference "user.recovery_codes.count", -2 do
    user.disable_two_factor!
  end
end

test "disable_two_factor! keeps otp_secret for potential re-enabling" do
  user = users(:one)
  original_secret = user.otp_secret
  user.update!(otp_required_for_sign_in: true)

  user.disable_two_factor!

  assert_equal original_secret, user.reload.otp_secret
end
```

#### 8.2 Controller Tests

**File:** `test/controllers/two_factor_authentication/profile/totps_controller_test.rb`

```ruby
require "test_helper"

class TwoFactorAuthentication::Profile::TotpsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @user.update!(otp_required_for_sign_in: true)
    sign_in @user
  end

  test "should get destroy_confirmation" do
    get destroy_confirmation_two_factor_authentication_profile_totp_url
    assert_response :success
  end

  test "should disable 2FA with valid code" do
    totp = ROTP::TOTP.new(@user.otp_secret, issuer: "Boilermaker")
    valid_code = totp.now

    delete two_factor_authentication_profile_totp_url, params: { code: valid_code }

    assert_redirected_to settings_path
    assert_equal "Two-factor authentication has been disabled", flash[:notice]
    refute @user.reload.otp_required_for_sign_in?
  end

  test "should show error message with invalid code" do
    delete two_factor_authentication_profile_totp_url, params: { code: "000000" }

    assert_response :unprocessable_entity
    assert_equal "That code didn't work. Please try again", flash[:alert]
    assert @user.reload.otp_required_for_sign_in?
  end

  test "should not allow destroy_confirmation when 2FA not enabled" do
    @user.update!(otp_required_for_sign_in: false)

    get destroy_confirmation_two_factor_authentication_profile_totp_url

    assert_redirected_to settings_path
    assert_match /not enabled/, flash[:alert]
  end

  test "should not allow destroy_confirmation when 2FA is mandatory" do
    with_required_2fa do
      get destroy_confirmation_two_factor_authentication_profile_totp_url

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

  with_required_2fa do
    get root_url

    assert_redirected_to new_two_factor_authentication_profile_totp_path
    assert_match /must set up two-factor authentication/, flash[:alert]
  end
end

test "does not enforce 2FA when user has it enabled" do
  @user = users(:one)
  @user.update!(otp_required_for_sign_in: true)
  sign_in @user

  with_required_2fa do
    get root_url
    assert_response :success
  end
end

test "allows access to 2FA setup when enforcement active" do
  @user = users(:one)
  @user.update!(otp_required_for_sign_in: false)
  sign_in @user

  with_required_2fa do
    get new_two_factor_authentication_profile_totp_url
    assert_response :success
  end
end

test "allows sign out when enforcement active" do
  @user = users(:one)
  @user.update!(otp_required_for_sign_in: false)
  sign_in @user

  with_required_2fa do
    delete session_url("current")
    assert_redirected_to root_path
  end
end
```

#### 8.3 System Tests

**File:** `test/system/two_factor_authentication_test.rb`

```ruby
require "application_system_test_case"

class TwoFactorAuthenticationTest < ApplicationSystemTestCase
  test "user disables 2FA from settings" do
    user = users(:one)
    user.update!(otp_required_for_sign_in: true)
    sign_in_as user

    visit settings_path
    assert_text "Enabled"

    click_on "Disable Two-Factor Authentication"

    assert_current_path destroy_confirmation_two_factor_authentication_profile_totp_path
    assert_text "Warning: This will reduce your account security"

    totp = ROTP::TOTP.new(user.otp_secret, issuer: "Boilermaker")
    fill_in "Authentication Code", with: totp.now
    click_on "Disable Two-Factor Authentication"

    assert_current_path settings_path
    assert_text "has been disabled"
    assert_text "Disabled"
  end

  test "user sees error with invalid code when disabling" do
    user = users(:one)
    user.update!(otp_required_for_sign_in: true)
    sign_in_as user

    visit destroy_confirmation_two_factor_authentication_profile_totp_path

    fill_in "Authentication Code", with: "000000"
    click_on "Disable Two-Factor Authentication"

    assert_text "That code didn't work. Please try again"
    assert user.reload.otp_required_for_sign_in?
  end

  test "user without 2FA redirected when mandatory" do
    user = users(:one)
    user.update!(otp_required_for_sign_in: false)

    with_required_2fa do
      sign_in_as user

      assert_current_path new_two_factor_authentication_profile_totp_path
      assert_text "must set up two-factor authentication"
    end
  end
end
```

#### 8.4 Test Helpers

**File:** `test/test_helper.rb`

```ruby
module ActiveSupport
  class TestCase
    # Temporarily override config for testing
    def with_config(**overrides)
      original_config = Boilermaker.instance_variable_get(:@config)

      begin
        new_config = original_config.deep_merge(
          Rails.env => overrides.transform_keys(&:to_s)
        )
        Boilermaker.instance_variable_set(:@config, Boilermaker::Configuration.new(new_config))
        yield
      ensure
        Boilermaker.instance_variable_set(:@config, original_config)
      end
    end

    # Specific helper for 2FA requirement testing
    def with_required_2fa
      with_config(require_two_factor_authentication: true) { yield }
    end
  end
end
```

### 9. File Summary

#### Files to Create

1. `app/views/two_factor_authentication/profile/totps/destroy_confirmation.rb` - Disable confirmation page
2. `test/controllers/two_factor_authentication/profile/totps_controller_test.rb` - Add destroy tests
3. `test/views/settings/show_test.rb` - Settings view tests
4. `test/system/two_factor_authentication_test.rb` - System tests

#### Files to Modify

1. `config/boilermaker.yml` - Add `security.require_two_factor_authentication` config
2. `lib/boilermaker/configuration.rb` - Add `require_two_factor_authentication?` method
3. `app/models/user.rb` - Add `disable_two_factor!` method with transaction
4. `app/controllers/application_controller.rb` - Add `enforce_two_factor_setup` before_action
5. `app/controllers/two_factor_authentication/profile/totps_controller.rb` - Add `destroy_confirmation` and `destroy` actions with `skip_before_action`
6. `app/controllers/two_factor_authentication/profile/recovery_codes_controller.rb` - Add `skip_before_action`
7. `app/controllers/sessions_controller.rb` - Add `skip_before_action` for destroy
8. `app/views/settings/show.rb` - Add 2FA section
9. `config/routes.rb` - Add `:destroy` and `:destroy_confirmation` to TOTP resource
10. `test/models/user_test.rb` - Add tests for `disable_two_factor!`
11. `test/controllers/application_controller_test.rb` - Add enforcement tests
12. `test/test_helper.rb` - Add `with_config` and `with_required_2fa` helpers

### 10. Migration Plan

**No database migrations required.** All necessary columns exist.

### 11. Deployment Considerations

Deploy with flag off, notify users, then enable flag for enforcement.

### 12. Future Enhancements

1. **Audit Log:** Record 2FA enable/disable events
2. **Session Invalidation:** Invalidate sessions when disabling 2FA

### 13. Success Criteria

Implementation is complete when:

- [ ] Users can enable 2FA from Settings
- [ ] Users can disable 2FA via confirmation page (when not mandatory)
- [ ] Disable requires TOTP verification
- [ ] Flash message shows on invalid code
- [ ] Settings shows current 2FA status
- [ ] Config flag `require_two_factor_authentication` works
- [ ] Enforcement redirects users without 2FA to setup
- [ ] Disable button hidden when mandatory
- [ ] All tests pass
- [ ] Transaction ensures atomic disable operation
- [ ] Code comment explains otp_secret persistence

---

**End of Specification Version 1c**

**Final Status:** Production-ready implementation specification
