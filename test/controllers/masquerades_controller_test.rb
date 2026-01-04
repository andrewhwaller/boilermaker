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
    assert_equal "Now masquerading as #{@regular_user.email}", flash[:notice]
  end

  test "admin can masquerade across accounts" do
    sign_in_as @admin_user
    follow_redirect!

    other_account_user = User.create!(
      email: "other@example.com",
      password: "MyVerySecurePassword2024!",
      verified: true
    )
    AccountMembership.create!(
      user: other_account_user,
      account: accounts(:two),
      roles: { "admin" => true, "member" => true }
    )

    post user_masquerade_path(other_account_user)
    assert_redirected_to root_path
    assert_equal "Now masquerading as #{other_account_user.email}", flash[:notice]
  end

  test "authenticated regular user is denied masquerade access" do
    sign_in_as @regular_user
    follow_redirect!  # Clear the sign-in flash message

    post user_masquerade_path(@admin_user)

    assert_redirected_to root_path
    assert_equal "Access denied", flash[:alert]
  end

  test "admin cannot impersonate another admin" do
    other_admin = User.create!(
      email: "other_admin@example.com",
      password: "MyVerySecurePassword2024!",
      verified: true,
      app_admin: true
    )

    sign_in_as @admin_user
    follow_redirect!

    post user_masquerade_path(other_admin)

    assert_redirected_to admin_users_path
    assert_equal "Cannot impersonate other administrators", flash[:alert]
  end

  test "impersonator can stop impersonating" do
    sign_in_as @admin_user
    follow_redirect!

    # Start impersonating
    post user_masquerade_path(@regular_user)
    follow_redirect!

    # Stop impersonating
    delete stop_masquerade_path

    assert_redirected_to admin_users_path
    assert_equal "Stopped masquerading as #{@regular_user.email}", flash[:notice]
  end

  test "non-impersonating user cannot access stop endpoint" do
    sign_in_as @regular_user
    follow_redirect!

    delete stop_masquerade_path

    assert_redirected_to root_path
    assert_equal "Not currently impersonating anyone", flash[:alert]
  end
end
