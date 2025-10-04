require "test_helper"

class Identity::InvitationAcceptancesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @unverified_user = users(:unverified_user)
    @verified_user = users(:app_admin)
  end

  test "should get show with valid invitation token" do
    sid = @unverified_user.generate_token_for(:invitation)

    get identity_invitation_acceptance_url(sid: sid)
    assert_response :success
  end

  test "should redirect to sign in with invalid invitation token" do
    get identity_invitation_acceptance_url(sid: "invalid_token")
    assert_redirected_to sign_in_url
    assert_equal "That invitation link is invalid or has expired.", flash[:alert]
  end

  test "should redirect to sign in with expired invitation token" do
    sid = @unverified_user.generate_token_for(:invitation)

    travel 8.days

    get identity_invitation_acceptance_url(sid: sid)
    assert_redirected_to sign_in_url
    assert_equal "That invitation link is invalid or has expired.", flash[:alert]
  end

  test "should set password and mark user verified for new user" do
    sid = @unverified_user.generate_token_for(:invitation)

    assert_not @unverified_user.verified?

    patch identity_invitation_acceptance_url, params: {
      sid: sid,
      user: {
        password: "NewPassword1*",
        password_confirmation: "NewPassword1*"
      }
    }

    assert_redirected_to sign_in_url
    assert_equal "Your account has been set up! Please sign in.", flash[:notice]

    @unverified_user.reload
    assert @unverified_user.verified?
    assert @unverified_user.authenticate("NewPassword1*")
  end

  test "should not set password with mismatched confirmation" do
    sid = @unverified_user.generate_token_for(:invitation)

    assert_not @unverified_user.verified?

    patch identity_invitation_acceptance_url, params: {
      sid: sid,
      user: {
        password: "NewPassword1*",
        password_confirmation: "DifferentPassword1*"
      }
    }

    assert_response :unprocessable_entity

    @unverified_user.reload
    assert_not @unverified_user.verified?
  end

  test "should not set password with weak password" do
    sid = @unverified_user.generate_token_for(:invitation)

    assert_not @unverified_user.verified?

    patch identity_invitation_acceptance_url, params: {
      sid: sid,
      user: {
        password: "weak",
        password_confirmation: "weak"
      }
    }

    assert_response :unprocessable_entity

    @unverified_user.reload
    assert_not @unverified_user.verified?
  end

  test "should acknowledge invitation for already verified user" do
    sid = @verified_user.generate_token_for(:invitation)

    assert @verified_user.verified?

    patch identity_invitation_acceptance_url, params: {
      sid: sid,
      user: {
        password: "ignored",
        password_confirmation: "ignored"
      }
    }

    assert_redirected_to root_path
    assert_equal "Welcome to the team! You can now access your new account.", flash[:notice]
  end
end
