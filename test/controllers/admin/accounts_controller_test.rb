require "test_helper"

class Admin::AccountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @app_admin = users(:app_admin)
    @regular = users(:regular_user)
  end

  test "index displays for app admin" do
    sign_in_as @app_admin
    get admin_accounts_path
    assert_response :success
  end

  test "show displays for app admin" do
    sign_in_as @app_admin
    get admin_account_path(accounts(:one))
    assert_response :success
  end

  test "denies index for non app admin" do
    sign_in_as @regular
    get admin_accounts_path
    assert_redirected_to root_path
  end

  test "denies show for non app admin" do
    sign_in_as @regular
    get admin_account_path(accounts(:one))
    assert_redirected_to root_path
  end
end
