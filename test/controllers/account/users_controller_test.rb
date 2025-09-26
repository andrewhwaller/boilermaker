require "test_helper"

class Account::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:one)
    @admin_user = users(:app_admin)
    @member_user = users(:regular_user)
  end

  test "show requires account admin" do
    sign_in_as @member_user
    get account_user_path(@admin_user)
    assert_redirected_to root_path
  end

  test "show displays for account admin" do
    sign_in_as @admin_user
    get account_user_path(@member_user)
    assert_response :success
  end

  test "edit requires account admin" do
    sign_in_as @member_user
    get edit_account_user_path(@admin_user)
    assert_redirected_to root_path
  end

  test "edit displays for account admin" do
    sign_in_as @admin_user
    get edit_account_user_path(@member_user)
    assert_response :success
  end

  test "index requires account admin" do
    sign_in_as @member_user
    get account_users_path
    assert_redirected_to root_path
  end

  test "index redirects account admin to invitations" do
    sign_in_as @admin_user
    get account_users_path
    assert_redirected_to account_invitations_path
  end

  test "update toggles membership admin role" do
    sign_in_as @admin_user
    target = @member_user

    # ensure baseline membership exists
    AccountMembership.find_or_create_by!(user: target, account: @account, roles: { admin: false, member: true })

    patch account_user_path(target), params: { role: [ "member", "admin" ] }
    assert_redirected_to account_user_path(target)
    assert AccountMembership.for_account(@account).for_user(target).first.admin?

    patch account_user_path(target), params: { role: "member" }
    assert_redirected_to account_user_path(target)
    refute AccountMembership.for_account(@account).for_user(target).first.admin?
  end

  test "destroy requires account admin" do
    sign_in_as @member_user
    delete account_user_path(@admin_user)
    assert_redirected_to root_path
  end

  test "destroy removes user from account" do
    sign_in_as @admin_user
    target = @member_user

    # ensure baseline membership exists
    membership = AccountMembership.find_or_create_by!(user: target, account: @account, roles: { admin: false, member: true })

    assert_difference 'AccountMembership.count', -1 do
      delete account_user_path(target)
    end

    assert_redirected_to account_path
    assert_includes flash[:notice], target.email
    refute AccountMembership.find_by(user: target, account: @account)
  end

  test "destroy prevents users from removing themselves" do
    sign_in_as @admin_user

    # ensure baseline membership exists
    AccountMembership.find_or_create_by!(user: @admin_user, account: @account, roles: { admin: true, member: true })

    assert_no_difference 'AccountMembership.count' do
      delete account_user_path(@admin_user)
    end

    assert_redirected_to account_path
    assert_includes flash[:alert], "cannot remove yourself"
  end
end
