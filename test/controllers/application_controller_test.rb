require "test_helper"

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  test "enforces 2FA setup when mandatory and user has no 2FA" do
    @user = users(:app_admin)
    @user.update!(otp_required_for_sign_in: false)
    sign_in_as @user

    with_required_2fa do
      get root_url

      assert_redirected_to new_two_factor_authentication_profile_totp_path
      assert_match /must set up two-factor authentication/, flash[:alert]
    end
  end

  test "does not enforce 2FA when user has it enabled" do
    @user = users(:app_admin)
    @user.update!(otp_required_for_sign_in: false)
    sign_in_as @user
    @user.update!(otp_required_for_sign_in: true)

    with_required_2fa do
      get root_url
      assert_response :success
    end
  end

  test "allows access to 2FA setup when enforcement active" do
    @user = users(:app_admin)
    @user.update!(otp_required_for_sign_in: false)
    sign_in_as @user

    with_required_2fa do
      get new_two_factor_authentication_profile_totp_url
      assert_response :success
    end
  end

  test "allows sign out when enforcement active" do
    @user = users(:app_admin)
    @user.update!(otp_required_for_sign_in: false)
    sign_in_as @user

    with_required_2fa do
      delete session_url("current")
      assert_redirected_to root_path
    end
  end
end
