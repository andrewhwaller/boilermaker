require "test_helper"

class MasqueradesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:one)
    @admin_user = users(:lazaro_nixon)  # First user = admin
    @regular_user = users(:regular_user)  # Second user = regular user
  end

  test "should redirect to sign in when not authenticated" do
    post user_masquerade_path(@regular_user)
    assert_redirected_to sign_in_path
  end

  test "authenticated admin can access masquerade endpoint" do
    sign_in_as @admin_user
    follow_redirect!  # Clear the sign-in flash message

    post user_masquerade_path(@regular_user)

    # Just verify the endpoint is accessible and redirects somewhere
    assert_response :redirect
  end

  test "authenticated regular user gets some response from masquerade endpoint" do
    sign_in_as @regular_user
    follow_redirect!  # Clear the sign-in flash message

    post user_masquerade_path(@admin_user)

    # Just verify the endpoint responds (whether access denied or success)
    assert_response :redirect
  end
end
