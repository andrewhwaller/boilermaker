require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @account = Account.create!(name: "Test Account")
    @user = @account.users.build(
      email: "test@example.com",
      password: "MyVerySecureTestPassword2024!"
    )
  end

  test "should be valid with valid attributes" do
    assert @user.valid?
  end

  test "should require email" do
    @user.email = nil
    assert_not @user.valid?
    assert_includes @user.errors[:email], "can't be blank"
  end

  test "should require valid email format" do
    @user.email = "invalid-email"
    assert_not @user.valid?
    assert_includes @user.errors[:email], "is invalid"
  end

  test "should require unique email" do
    @user.save!
    duplicate_user = @account.users.build(
      email: @user.email,
      password: "AnotherSecureTestPassword2024!"
    )
    assert_not duplicate_user.valid?
    assert_includes duplicate_user.errors[:email], "has already been taken"
  end

  test "should require password with minimum 12 characters" do
    @user.password = "short"
    assert_not @user.valid?
    assert_includes @user.errors[:password], "is too short (minimum is 12 characters)"
  end

  test "should accept secure passwords" do
    @user.password = "MyVerySecurePassword2024!"
    assert @user.valid?
  end

  test "should generate otp_secret on creation" do
    @user.save!
    assert_not_nil @user.otp_secret
    assert @user.otp_secret.length > 0
  end

  test "should default verified to false" do
    @user.save!
    assert_equal false, @user.verified?
  end

  test "should default otp_required_for_sign_in to false" do
    @user.save!
    assert_equal false, @user.otp_required_for_sign_in?
  end

  test "should belong to account" do
    @user.save!
    assert_equal @account, @user.account
  end

  test "should have many sessions" do
    @user.save!
    session = @user.sessions.create!
    assert_includes @user.sessions, session
  end

  test "should normalize email to lowercase" do
    @user.email = "TEST@EXAMPLE.COM"
    @user.save!
    assert_equal "test@example.com", @user.email
  end

  test "should set verified to false when email changes" do
    @user.save!
    @user.update!(verified: true)
    assert @user.verified?

    @user.update!(email: "newemail@example.com")
    assert_not @user.verified?
  end

  test "account_admin_for? true for app admin and membership admin" do
    # app admin overrides
    app_admin = @account.users.create!(email: "user_test_app_admin@example.com", password: "MyVerySecurePassword2024!", admin: true)
    assert app_admin.account_admin_for?(@account)

    # membership admin
    member = @account.users.create!(email: "member@example.com", password: "MyVerySecurePassword2024!", admin: false, verified: true)
    AccountMembership.create!(user: member, account: @account, roles: { admin: true, member: true })
    assert member.account_admin_for?(@account)

    # non-admin member
    non_admin = @account.users.create!(email: "plain@example.com", password: "MyVerySecurePassword2024!", admin: false, verified: true)
    AccountMembership.create!(user: non_admin, account: @account, roles: { admin: false, member: true })
    assert_not non_admin.account_admin_for?(@account)
  end
end
