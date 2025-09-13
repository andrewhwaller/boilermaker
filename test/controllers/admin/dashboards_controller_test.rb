require "test_helper"

class Admin::DashboardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:one)
    @regular = users(:regular_user)
    @app_admin = users(:app_admin)
  end

  test "denies access for non app admin" do
    sign_in_as @regular
    get admin_path
    assert_redirected_to root_path
  end

  test "allows access for app admin" do
    sign_in_as @app_admin
    get admin_path
    assert_response :success
  end
end
