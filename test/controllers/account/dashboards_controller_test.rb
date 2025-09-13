require "test_helper"

class Account::DashboardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:one)
    @admin_user = users(:app_admin)
    @member_user = users(:regular_user)
  end

  test "denies access for non-admin membership" do
    sign_in_as @member_user
    get account_path
    assert_redirected_to root_path
    assert_equal "Access denied. Admin privileges required.", flash[:alert]
  end

  test "allows access for account membership admin" do
    sign_in_as @admin_user
    get account_path
    assert_response :success
  end
end
