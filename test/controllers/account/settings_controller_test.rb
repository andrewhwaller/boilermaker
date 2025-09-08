require "test_helper"

class Account::SettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:one)
    @admin_user = users(:app_admin)
    @member_user = users(:regular_user)
  end

  test "show requires account admin" do
    sign_in_as @member_user
    get account_settings_path
    assert_redirected_to root_path
  end

  test "show displays for account admin" do
    sign_in_as @admin_user
    get account_settings_path
    assert_response :success
  end

  test "edit displays for account admin" do
    sign_in_as @admin_user
    get edit_account_settings_path
    assert_response :success
  end

  test "update updates name for account admin" do
    sign_in_as @admin_user
    patch account_settings_path, params: { account: { name: "Renamed" } }
    assert_redirected_to account_settings_path
  end
end
