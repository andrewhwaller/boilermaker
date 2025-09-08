require "test_helper"

class AccountMembershipTest < ActiveSupport::TestCase
  def setup
    @account = accounts(:one)
    @user = users(:regular_user)
  end

  test "valid with boolean roles" do
    m = AccountMembership.new(user: @user, account: @account, roles: { admin: false, member: true })
    assert m.valid?
  end

  test "invalid with non-boolean role value" do
    m = AccountMembership.new(user: @user, account: @account, roles: { admin: "yes" })
    assert_not m.valid?
    assert_includes m.errors[:roles], "role 'admin' must be boolean true/false"
  end

  test "role helpers and scope" do
    admin_m = AccountMembership.create!(user: @user, account: @account, roles: { admin: true, member: true })
    assert admin_m.admin?
    assert admin_m.member?

    members = AccountMembership.for_account(@account).with_role(:admin)
    assert_includes members, admin_m
  end
end
