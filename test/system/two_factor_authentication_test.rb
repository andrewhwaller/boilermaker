require "application_system_test_case"

class TwoFactorAuthenticationTest < ApplicationSystemTestCase
  setup do
    @user = users(:app_admin)
    # Ensure user starts verified and without 2FA enabled for most tests
    @user.update!(verified: true, otp_required_for_sign_in: false)
  end

  # Test 1: Disable 2FA Flow
  # User with 2FA enabled navigates to settings, clicks "Disable Two-Factor Authentication",
  # sees warning on confirmation page, enters valid TOTP code, sees success message and "Disabled" status
  test "user disables 2FA from settings with valid code" do
    # Setup: Enable 2FA for user
    @user.update!(otp_required_for_sign_in: true)
    puts "\n[TEST] User #{@user.email} has 2FA enabled: #{@user.otp_required_for_sign_in?}"

    # Sign in the user
    sign_in_as(@user)
    puts "[TEST] User signed in successfully"

    # Navigate to settings page
    visit settings_path
    puts "[TEST] Navigated to settings page: #{current_path}"

    # Verify "Disable Two-Factor Authentication" button is present (case-insensitive)
    assert_selector "a", text: /disable two.factor authentication/i
    puts "[TEST] Verified 'Disable Two-Factor Authentication' button is present"

    # Click disable button
    click_on "Disable Two-Factor Authentication", match: :first
    puts "[TEST] Clicked 'Disable Two-Factor Authentication' button"

    # Should be on confirmation page
    assert_current_path destroy_confirmation_two_factor_authentication_profile_totp_path
    puts "[TEST] Navigated to confirmation page: #{current_path}"

    # Verify warning message is shown
    assert_text "Warning: This will reduce your account security"
    puts "[TEST] Verified warning message is displayed"

    # Verify confirmation instructions are shown
    assert_text "Confirm by entering your current authentication code"
    puts "[TEST] Verified confirmation instructions are displayed"

    # Generate valid TOTP code
    totp = ROTP::TOTP.new(@user.otp_secret, issuer: "Boilermaker")
    valid_code = totp.now
    puts "[TEST] Generated valid TOTP code: #{valid_code}"

    # Fill in the TOTP code
    fill_in "Authentication Code", with: valid_code
    puts "[TEST] Filled in authentication code field"

    # Click the disable button
    click_on "Disable Two-Factor Authentication", match: :first
    puts "[TEST] Clicked submit button to disable 2FA"

    # Should be redirected to settings
    assert_current_path settings_path
    puts "[TEST] Redirected back to settings page: #{current_path}"

    # Verify success message
    assert_text "has been disabled"
    puts "[TEST] Verified success message is displayed"

    # Verify in database that 2FA is disabled
    @user.reload
    refute @user.otp_required_for_sign_in?, "Expected 2FA to be disabled in database"
    puts "[TEST] Verified 2FA is disabled in database"

    # Verify recovery codes were deleted
    assert_equal 0, @user.recovery_codes.count, "Expected all recovery codes to be deleted"
    puts "[TEST] Verified recovery codes were deleted"
  end

  # Test 2: Invalid Code Error
  # User attempts to disable with invalid code, sees error message, 2FA remains enabled
  test "user sees error with invalid code when disabling" do
    # Setup: Enable 2FA for user
    @user.update!(otp_required_for_sign_in: true)
    puts "\n[TEST] User #{@user.email} has 2FA enabled: #{@user.otp_required_for_sign_in?}"

    # Sign in the user
    sign_in_as(@user)
    puts "[TEST] User signed in successfully"

    # Navigate directly to confirmation page
    visit destroy_confirmation_two_factor_authentication_profile_totp_path
    puts "[TEST] Navigated to confirmation page: #{current_path}"

    # Verify we're on the confirmation page
    assert_text "Warning: This will reduce your account security"
    puts "[TEST] Verified we're on the confirmation page"

    # Fill in an invalid code
    fill_in "Authentication Code", with: "000000"
    puts "[TEST] Filled in invalid code: 000000"

    # Click the disable button
    click_on "Disable Two-Factor Authentication", match: :first
    puts "[TEST] Clicked submit button to disable 2FA"

    # After invalid submission, the form re-renders on the destroy_confirmation path
    # (not the destroy path, because the view is re-rendered with status :unprocessable_entity)
    assert_current_path destroy_confirmation_two_factor_authentication_profile_totp_path
    puts "[TEST] Stayed on confirmation page (expected after failed submission)"

    # Verify error message is shown
    assert_text(/Please try again/)
    puts "[TEST] Verified error message is displayed"

    # Verify 2FA is still enabled in database
    @user.reload
    assert @user.otp_required_for_sign_in?, "Expected 2FA to still be enabled after invalid code"
    puts "[TEST] Verified 2FA is still enabled in database"
  end

  # Test 3: Mandatory 2FA Enforcement
  # User without 2FA when it's mandatory gets redirected to setup page and sees alert message
  test "user without 2FA is redirected to setup when mandatory" do
    # Ensure user does not have 2FA enabled
    @user.update!(otp_required_for_sign_in: false)
    puts "\n[TEST] User #{@user.email} has 2FA disabled: #{@user.otp_required_for_sign_in?}"

    # Enable mandatory 2FA via config
    with_required_2fa do
      puts "[TEST] Enabled mandatory 2FA via config"

      # Sign in the user
      sign_in_as(@user)
      puts "[TEST] User signed in successfully"

      # After sign in, should be redirected to 2FA setup page due to enforcement
      # The enforce_two_factor_setup before_action should trigger
      assert_current_path new_two_factor_authentication_profile_totp_path
      puts "[TEST] Redirected to 2FA setup page: #{current_path}"

      # Verify alert message
      assert_text "must set up two-factor authentication"
      puts "[TEST] Verified mandatory 2FA alert message is displayed"
    end
  end

  # Test 4: Settings Page Display - Correct badges and buttons based on 2FA status
  test "settings page shows correct status and buttons when 2FA enabled" do
    # Setup: Enable 2FA for user
    @user.update!(otp_required_for_sign_in: true)
    puts "\n[TEST] User #{@user.email} has 2FA enabled: #{@user.otp_required_for_sign_in?}"

    # Sign in the user
    sign_in_as(@user)
    puts "[TEST] User signed in successfully"

    # Visit settings page
    visit settings_path
    puts "[TEST] Navigated to settings page: #{current_path}"

    # Verify "View Recovery Codes" button is shown (case-insensitive)
    assert_selector "a", text: /view recovery codes/i, visible: true
    puts "[TEST] Verified 'View Recovery Codes' button is displayed"

    # Verify "Disable Two-Factor Authentication" button is shown (case-insensitive)
    assert_selector "a", text: /disable two.factor authentication/i, visible: true
    puts "[TEST] Verified 'Disable Two-Factor Authentication' button is displayed"

    # Verify "Enable Two-Factor Authentication" button is NOT shown
    assert_no_selector "a", text: /enable two.factor authentication/i
    puts "[TEST] Verified 'Enable Two-Factor Authentication' button is NOT displayed"
  end

  test "settings page shows correct status and buttons when 2FA disabled" do
    # Ensure 2FA is disabled
    @user.update!(otp_required_for_sign_in: false)
    puts "\n[TEST] User #{@user.email} has 2FA disabled: #{@user.otp_required_for_sign_in?}"

    # Sign in the user
    sign_in_as(@user)
    puts "[TEST] User signed in successfully"

    # Visit settings page
    visit settings_path
    puts "[TEST] Navigated to settings page: #{current_path}"

    # Verify "Enable Two-Factor Authentication" button is shown (case-insensitive)
    assert_selector "a", text: /enable two.factor authentication/i, visible: true
    puts "[TEST] Verified 'Enable Two-Factor Authentication' button is displayed"

    # Verify "Disable Two-Factor Authentication" button is NOT shown
    assert_no_selector "a", text: /disable two.factor authentication/i
    puts "[TEST] Verified 'Disable Two-Factor Authentication' button is NOT displayed"

    # Verify "View Recovery Codes" button is NOT shown
    assert_no_selector "a", text: /view recovery codes/i
    puts "[TEST] Verified 'View Recovery Codes' button is NOT displayed"
  end

  # Test 5: Disable button hidden when 2FA is mandatory
  test "disable button is hidden when 2FA is mandatory" do
    # Setup: Enable 2FA for user
    @user.update!(otp_required_for_sign_in: true)
    puts "\n[TEST] User #{@user.email} has 2FA enabled: #{@user.otp_required_for_sign_in?}"

    # Enable mandatory 2FA via config
    with_required_2fa do
      puts "[TEST] Enabled mandatory 2FA via config"

      # Sign in the user
      sign_in_as(@user)
      puts "[TEST] User signed in successfully"

      # Visit settings page
      visit settings_path
      puts "[TEST] Navigated to settings page: #{current_path}"

      # Verify "View Recovery Codes" button is shown (case-insensitive)
      assert_selector "a", text: /view recovery codes/i, visible: true
      puts "[TEST] Verified 'View Recovery Codes' button is displayed"

      # Verify "Disable Two-Factor Authentication" button is NOT shown
      assert_no_selector "a", text: /disable two.factor authentication/i
      puts "[TEST] Verified 'Disable Two-Factor Authentication' button is NOT displayed when mandatory"
    end
  end

  # Test 6: User cannot access disable confirmation when 2FA not enabled
  test "user cannot access disable confirmation when 2FA not enabled" do
    # Ensure 2FA is disabled
    @user.update!(otp_required_for_sign_in: false)
    puts "\n[TEST] User #{@user.email} has 2FA disabled: #{@user.otp_required_for_sign_in?}"

    # Sign in the user
    sign_in_as(@user)
    puts "[TEST] User signed in successfully"

    # Try to visit disable confirmation page directly
    visit destroy_confirmation_two_factor_authentication_profile_totp_path
    puts "[TEST] Attempted to visit disable confirmation page"

    # Should be redirected to settings
    assert_current_path settings_path
    puts "[TEST] Redirected to settings page: #{current_path}"

    # Verify error message
    assert_text "not enabled"
    puts "[TEST] Verified error message about 2FA not being enabled"
  end

  # Test 7: User cannot access disable confirmation when 2FA is mandatory
  test "user cannot access disable confirmation when 2FA is mandatory" do
    # Setup: Enable 2FA for user
    @user.update!(otp_required_for_sign_in: true)
    puts "\n[TEST] User #{@user.email} has 2FA enabled: #{@user.otp_required_for_sign_in?}"

    # Enable mandatory 2FA via config
    with_required_2fa do
      puts "[TEST] Enabled mandatory 2FA via config"

      # Sign in the user
      sign_in_as(@user)
      puts "[TEST] User signed in successfully"

      # Try to visit disable confirmation page directly
      visit destroy_confirmation_two_factor_authentication_profile_totp_path
      puts "[TEST] Attempted to visit disable confirmation page"

      # Should be redirected to settings
      assert_current_path settings_path
      puts "[TEST] Redirected to settings page: #{current_path}"

      # Verify error message
      assert_text "required and cannot be disabled"
      puts "[TEST] Verified error message about 2FA being required"
    end
  end

  # Test 8: Recovery codes are deleted when disabling 2FA
  test "recovery codes are deleted atomically when disabling 2FA" do
    # Setup: Enable 2FA and create recovery codes
    @user.update!(otp_required_for_sign_in: true)
    3.times { @user.recovery_codes.create!(code: SecureRandom.alphanumeric(10).downcase) }
    puts "\n[TEST] User #{@user.email} has 2FA enabled with #{@user.recovery_codes.count} recovery codes"

    # Sign in the user
    sign_in_as(@user)
    puts "[TEST] User signed in successfully"

    # Navigate to settings
    visit settings_path
    puts "[TEST] Navigated to settings page"

    # Click disable button
    click_on "Disable Two-Factor Authentication", match: :first
    puts "[TEST] Clicked 'Disable Two-Factor Authentication' button"

    # Generate and enter valid code
    totp = ROTP::TOTP.new(@user.otp_secret, issuer: "Boilermaker")
    fill_in "Authentication Code", with: totp.now
    click_on "Disable Two-Factor Authentication", match: :first
    puts "[TEST] Submitted valid TOTP code"

    # Verify success
    assert_current_path settings_path
    assert_text "has been disabled"
    puts "[TEST] 2FA disabled successfully"

    # Verify recovery codes were deleted
    @user.reload
    assert_equal 0, @user.recovery_codes.count, "Expected all recovery codes to be deleted"
    puts "[TEST] Verified all recovery codes were deleted atomically"
  end

  # Test 9: User can cancel disable operation
  test "user can cancel disable operation" do
    # Setup: Enable 2FA for user
    @user.update!(otp_required_for_sign_in: true)
    puts "\n[TEST] User #{@user.email} has 2FA enabled: #{@user.otp_required_for_sign_in?}"

    # Sign in the user
    sign_in_as(@user)
    puts "[TEST] User signed in successfully"

    # Navigate to settings
    visit settings_path
    puts "[TEST] Navigated to settings page"

    # Click disable button
    click_on "Disable Two-Factor Authentication", match: :first
    puts "[TEST] Clicked 'Disable Two-Factor Authentication' button"

    # Verify we're on confirmation page
    assert_current_path destroy_confirmation_two_factor_authentication_profile_totp_path
    puts "[TEST] On confirmation page"

    # Click cancel button
    click_on "Cancel"
    puts "[TEST] Clicked 'Cancel' button"

    # Should be back on settings page
    assert_current_path settings_path
    puts "[TEST] Redirected back to settings page"

    # Verify 2FA is still enabled
    @user.reload
    assert @user.otp_required_for_sign_in?, "Expected 2FA to still be enabled after canceling"
    puts "[TEST] Verified 2FA is still enabled after canceling"
  end
end
