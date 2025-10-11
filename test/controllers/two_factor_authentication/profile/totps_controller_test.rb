require "test_helper"

class TwoFactorAuthentication::Profile::TotpsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:app_admin)
    # Ensure user doesn't have 2FA enabled for sign-in to work
    @user.update!(otp_required_for_sign_in: false)
    sign_in_as @user
    # Now enable 2FA for the tests
    @user.update!(otp_required_for_sign_in: true)
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
    assert flash[:notice].present?
    assert_match(/two-factor authentication has been disabled/i, flash[:notice])
    refute @user.reload.otp_required_for_sign_in?
  end

  test "should show error message with invalid code" do
    delete two_factor_authentication_profile_totp_url, params: { code: "000000" }

    assert_response :unprocessable_entity
    assert flash[:alert].present?
    assert_match(/code.*please try again/i, flash[:alert])
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
