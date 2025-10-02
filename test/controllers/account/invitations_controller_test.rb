require "test_helper"

class Account::InvitationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:one)
    @admin_user = users(:app_admin)
    @member_user = users(:regular_user)
  end

  test "create invitation creates membership with roles" do
    sign_in_as @admin_user, @account
    email = "new.invitee@example.com"

    assert_difference -> { User.count }, +1 do
      post account_invitations_path, params: { email: email }
    end

    assert_redirected_to account_dashboard_path
    user = User.find_by!(email: email)
    m = AccountMembership.find_by!(user: user, account: @account)
    assert_equal false, m.roles["admin"]
    assert_equal true, m.roles["member"]
  end

  test "index requires account admin" do
    sign_in_as @member_user, @account
    get account_invitations_path
    assert_redirected_to root_path
  end

  test "new requires account admin" do
    sign_in_as @member_user, @account
    get new_account_invitation_path
    assert_redirected_to root_path
  end

  test "destroy cancels unverified invitation" do
    sign_in_as @admin_user, @account
    invited = User.create!(email: "pending@example.com", password: "MyVerySecurePassword2024!", verified: false)
    AccountMembership.create!(user: invited, account: @account, roles: { "admin" => false, "member" => true })
    assert_difference -> { User.where(id: invited.id).count }, -1 do
      delete account_invitation_path(invited)
    end
    assert_redirected_to account_dashboard_path
  end
end
