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

  test "denies account update for non-admin membership" do
    sign_in_as @member_user
    original_name = @account.name
    patch account_path, params: { account: { name: "New Account Name" } }
    assert_redirected_to root_path
    assert_equal "Access denied. Admin privileges required.", flash[:alert]
    @account.reload
    assert_equal original_name, @account.name
  end

  test "allows account name update for admin" do
    sign_in_as @admin_user
    new_name = "Updated Account Name"
    patch account_path, params: { account: { name: new_name } }
    assert_redirected_to account_path
    assert_equal "Account updated successfully", flash[:notice]
    @account.reload
    assert_equal new_name, @account.name
  end

  test "fails account update with empty name" do
    sign_in_as @admin_user
    original_name = @account.name
    patch account_path, params: { account: { name: "" } }
    assert_redirected_to account_path
    assert_match(/Failed to update account/, flash[:alert])
    assert_match(/Name can't be blank/, flash[:alert])
    @account.reload
    assert_equal original_name, @account.name
  end

  test "fails account update with nil name" do
    sign_in_as @admin_user
    original_name = @account.name
    patch account_path, params: { account: { name: nil } }
    assert_redirected_to account_path
    assert_match(/Failed to update account/, flash[:alert])
    assert_match(/Name can't be blank/, flash[:alert])
    @account.reload
    assert_equal original_name, @account.name
  end

  test "fails account update with whitespace-only name" do
    sign_in_as @admin_user
    original_name = @account.name
    patch account_path, params: { account: { name: "   " } }
    assert_redirected_to account_path
    assert_match(/Failed to update account/, flash[:alert])
    assert_match(/Name can't be blank/, flash[:alert])
    @account.reload
    assert_equal original_name, @account.name
  end
end
