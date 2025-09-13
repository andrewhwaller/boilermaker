require "test_helper"

class MasqueradesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:one)
    @admin_user = users(:app_admin)
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

    assert_redirected_to root_path
    assert_equal "Masquerading as #{@regular_user.email}", flash[:notice]
  end

  test "admin can masquerade across accounts" do
    sign_in_as @admin_user
    follow_redirect!

    other_account_user = User.create!(
      email: "other@example.com",
      password: "MyVerySecurePassword2024!",
      verified: true,
      account: accounts(:two)
    )

    post user_masquerade_path(other_account_user)
    assert_redirected_to root_path
    assert_equal "Masquerading as #{other_account_user.email}", flash[:notice]
  end

  test "authenticated regular user is denied masquerade access" do
    sign_in_as @regular_user
    follow_redirect!  # Clear the sign-in flash message

    post user_masquerade_path(@admin_user)

    assert_redirected_to root_path
    assert_equal "Access denied", flash[:alert]
  end
end
