require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @owner = User.create!(email: "owner@example.com", password: "MyVerySecureTestPassword2024!")
    @account = Account.create!(name: "Test Account", owner: @owner)
    @user = User.new(
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
    duplicate_user = User.new(
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
    app_admin = User.create!(email: "user_test_app_admin@example.com", password: "MyVerySecurePassword2024!", app_admin: true)
    assert app_admin.account_admin_for?(@account)

    # membership admin
    member = User.create!(email: "member@example.com", password: "MyVerySecurePassword2024!", app_admin: false, verified: true)
    AccountMembership.create!(user: member, account: @account, roles: { admin: true, member: true })
    assert member.account_admin_for?(@account)

    # non-admin member
    non_admin = User.create!(email: "plain@example.com", password: "MyVerySecurePassword2024!", app_admin: false, verified: true)
    AccountMembership.create!(user: non_admin, account: @account, roles: { admin: false, member: true })
    assert_not non_admin.account_admin_for?(@account)
  end

  # ACCOUNT-RELATED ASSOCIATIONS TESTS

  test "has_many account_memberships" do
    user = User.create!(email: "membership_test@example.com", password: "MyVerySecurePassword2024!")

    # Create multiple account memberships
    account1 = Account.create!(name: "Account 1", owner: user)
    account2 = Account.create!(name: "Account 2", owner: user)

    membership1 = AccountMembership.create!(user: user, account: account1, roles: { member: true, admin: false })
    membership2 = AccountMembership.create!(user: user, account: account2, roles: { member: true, admin: true })

    assert_equal 2, user.account_memberships.count
    assert_includes user.account_memberships, membership1
    assert_includes user.account_memberships, membership2
  end

  test "account_memberships destroyed when user destroyed" do
    user = User.create!(email: "membership_destroy_test@example.com", password: "MyVerySecurePassword2024!")
    account = Account.create!(name: "Test Account for Destroy", owner: user)
    membership = AccountMembership.create!(user: user, account: account, roles: { member: true, admin: false })
    membership_id = membership.id

    user.destroy!

    assert_nil AccountMembership.find_by(id: membership_id), "AccountMembership should be destroyed when user is destroyed"
  end

  test "has_many accounts through account_memberships" do
    user = User.create!(email: "accounts_through_test@example.com", password: "MyVerySecurePassword2024!")

    # Create accounts and memberships
    account1 = Account.create!(name: "Account 1", owner: user)
    account2 = Account.create!(name: "Account 2", owner: user)
    account3 = Account.create!(name: "Account 3", owner: user)

    AccountMembership.create!(user: user, account: account1, roles: { member: true, admin: false })
    AccountMembership.create!(user: user, account: account2, roles: { member: true, admin: true })

    # user should have access to account1 and account2, but not account3
    assert_equal 2, user.accounts.count
    assert_includes user.accounts, account1
    assert_includes user.accounts, account2
    assert_not_includes user.accounts, account3
  end

  test "has_many owned_accounts" do
    owner = User.create!(email: "owner_test@example.com", password: "MyVerySecurePassword2024!")

    # Create multiple accounts owned by this user
    account1 = Account.create!(name: "Owned Account 1", owner: owner, personal: false)
    account2 = Account.create!(name: "Owned Account 2", owner: owner, personal: true)
    account3 = Account.create!(name: "Owned Account 3", owner: owner, personal: false)

    # Create an account owned by someone else
    other_user = User.create!(email: "other_owner@example.com", password: "MyVerySecurePassword2024!")
    other_account = Account.create!(name: "Other Account", owner: other_user, personal: false)

    assert_equal 3, owner.owned_accounts.count
    assert_includes owner.owned_accounts, account1
    assert_includes owner.owned_accounts, account2
    assert_includes owner.owned_accounts, account3
    assert_not_includes owner.owned_accounts, other_account
  end

  test "owned_accounts destroyed when user destroyed" do
    owner = User.create!(email: "owned_destroy_test@example.com", password: "MyVerySecurePassword2024!")
    account1 = Account.create!(name: "Account to Destroy 1", owner: owner, personal: false)
    account2 = Account.create!(name: "Account to Destroy 2", owner: owner, personal: true)

    account1_id = account1.id
    account2_id = account2.id

    owner.destroy!

    assert_nil Account.find_by(id: account1_id), "Owned accounts should be destroyed when owner is destroyed"
    assert_nil Account.find_by(id: account2_id), "Personal owned accounts should be destroyed when owner is destroyed"
  end

  # PERSONAL_ACCOUNT METHOD TESTS

  test "personal_account returns nil when personal_accounts feature disabled" do
    user = User.create!(email: "personal_disabled_test@example.com", password: "MyVerySecurePassword2024!")
    personal_account = Account.create!(name: "Personal Account", owner: user, personal: true)

    # Stub the config to disable personal accounts
    original_data = Boilermaker::Config.instance_variable_get(:@data)
    temp_config = {
      "features" => {
        "personal_accounts" => false
      }
    }
    Boilermaker::Config.instance_variable_set(:@data, temp_config)

    result = user.personal_account

    # Restore original config
    Boilermaker::Config.instance_variable_set(:@data, original_data)

    assert_nil result, "personal_account should return nil when feature is disabled"
  end

  test "personal_account returns first personal owned account when feature enabled" do
    user = User.create!(email: "personal_enabled_test@example.com", password: "MyVerySecurePassword2024!")

    # Create a team account (should be ignored)
    team_account = Account.create!(name: "Team Account", owner: user, personal: false)

    # Create personal accounts
    personal_account1 = Account.create!(name: "Personal Account 1", owner: user, personal: true)
    personal_account2 = Account.create!(name: "Personal Account 2", owner: user, personal: true)

    # Stub the config to enable personal accounts
    original_data = Boilermaker::Config.instance_variable_get(:@data)
    temp_config = {
      "features" => {
        "personal_accounts" => true
      }
    }
    Boilermaker::Config.instance_variable_set(:@data, temp_config)

    result = user.personal_account

    # Restore original config
    Boilermaker::Config.instance_variable_set(:@data, original_data)

    assert_equal personal_account1, result, "personal_account should return the first personal owned account"
    assert result.personal?, "returned account should be personal"
  end

  test "personal_account returns nil when user has no personal accounts" do
    user = User.create!(email: "no_personal_test@example.com", password: "MyVerySecurePassword2024!")

    # Create only team accounts
    team_account1 = Account.create!(name: "Team Account 1", owner: user, personal: false)
    team_account2 = Account.create!(name: "Team Account 2", owner: user, personal: false)

    # Stub the config to enable personal accounts
    original_data = Boilermaker::Config.instance_variable_get(:@data)
    temp_config = {
      "features" => {
        "personal_accounts" => true
      }
    }
    Boilermaker::Config.instance_variable_set(:@data, temp_config)

    result = user.personal_account

    # Restore original config
    Boilermaker::Config.instance_variable_set(:@data, original_data)

    assert_nil result, "personal_account should return nil when user has no personal accounts"
  end

  test "personal_account returns nil for new user without any accounts" do
    user = User.create!(email: "no_accounts_test@example.com", password: "MyVerySecurePassword2024!")

    # Stub the config to enable personal accounts
    original_data = Boilermaker::Config.instance_variable_get(:@data)
    temp_config = {
      "features" => {
        "personal_accounts" => true
      }
    }
    Boilermaker::Config.instance_variable_set(:@data, temp_config)

    result = user.personal_account

    # Restore original config
    Boilermaker::Config.instance_variable_set(:@data, original_data)

    assert_nil result, "personal_account should return nil when user has no owned accounts"
  end

  # CAN_ACCESS? METHOD TESTS

  test "can_access? returns true when user is member of account" do
    user = User.create!(email: "can_access_member_test@example.com", password: "MyVerySecurePassword2024!")
    account = Account.create!(name: "Accessible Account", owner: user)

    # Create membership
    AccountMembership.create!(user: user, account: account, roles: { member: true, admin: false })

    assert user.can_access?(account), "can_access? should return true when user has membership"
  end

  test "can_access? returns false when user is not member of account" do
    user = User.create!(email: "can_access_non_member_test@example.com", password: "MyVerySecurePassword2024!")
    other_user = User.create!(email: "other_user@example.com", password: "MyVerySecurePassword2024!")
    account = Account.create!(name: "Inaccessible Account", owner: other_user)

    # Create membership for other_user, not for user
    AccountMembership.create!(user: other_user, account: account, roles: { member: true, admin: false })

    assert_not user.can_access?(account), "can_access? should return false when user has no membership"
  end

  test "can_access? returns true for admin members" do
    user = User.create!(email: "can_access_admin_test@example.com", password: "MyVerySecurePassword2024!")
    account = Account.create!(name: "Admin Accessible Account", owner: user)

    # Create admin membership
    AccountMembership.create!(user: user, account: account, roles: { member: true, admin: true })

    assert user.can_access?(account), "can_access? should return true for admin members"
  end

  test "can_access? returns true when user owns the account (implicit membership)" do
    owner = User.create!(email: "can_access_owner_test@example.com", password: "MyVerySecurePassword2024!")
    account = Account.create!(name: "Owned Account", owner: owner)

    # Create membership for owner
    AccountMembership.create!(user: owner, account: account, roles: { member: true, admin: true })

    assert owner.can_access?(account), "can_access? should return true when user owns the account"
  end

  test "can_access? works correctly with multiple accounts" do
    user = User.create!(email: "can_access_multiple_test@example.com", password: "MyVerySecurePassword2024!")
    other_user = User.create!(email: "other_multi@example.com", password: "MyVerySecurePassword2024!")

    # Create multiple accounts
    accessible_account1 = Account.create!(name: "Accessible 1", owner: user)
    accessible_account2 = Account.create!(name: "Accessible 2", owner: user)
    inaccessible_account = Account.create!(name: "Inaccessible", owner: other_user)

    # Create memberships
    AccountMembership.create!(user: user, account: accessible_account1, roles: { member: true, admin: false })
    AccountMembership.create!(user: user, account: accessible_account2, roles: { member: true, admin: true })
    AccountMembership.create!(user: other_user, account: inaccessible_account, roles: { member: true, admin: false })

    assert user.can_access?(accessible_account1), "should access first account"
    assert user.can_access?(accessible_account2), "should access second account"
    assert_not user.can_access?(inaccessible_account), "should not access other user's account"
  end

  # EDGE CASES

  test "can_access? returns false for nil account" do
    user = User.create!(email: "can_access_nil_test@example.com", password: "MyVerySecurePassword2024!")

    assert_not user.can_access?(nil), "can_access? should return false for nil account"
  end

  test "membership_for returns correct membership" do
    user = User.create!(email: "membership_for_test@example.com", password: "MyVerySecurePassword2024!")
    account1 = Account.create!(name: "Account 1", owner: user)
    account2 = Account.create!(name: "Account 2", owner: user)

    membership1 = AccountMembership.create!(user: user, account: account1, roles: { member: true, admin: false })
    membership2 = AccountMembership.create!(user: user, account: account2, roles: { member: true, admin: true })

    assert_equal membership1, user.membership_for(account1)
    assert_equal membership2, user.membership_for(account2)
  end

  test "membership_for returns nil for account without membership" do
    user = User.create!(email: "membership_for_nil_test@example.com", password: "MyVerySecurePassword2024!")
    other_user = User.create!(email: "other_membership@example.com", password: "MyVerySecurePassword2024!")
    account = Account.create!(name: "Other Account", owner: other_user)

    assert_nil user.membership_for(account), "membership_for should return nil when user has no membership"
  end

  test "membership_for handles nil account" do
    user = User.create!(email: "membership_for_nil_account_test@example.com", password: "MyVerySecurePassword2024!")

    assert_nil user.membership_for(nil), "membership_for should return nil for nil account"
  end

  test "account associations remain consistent after membership deletion" do
    user = User.create!(email: "consistency_test@example.com", password: "MyVerySecurePassword2024!")
    account = Account.create!(name: "Consistent Account", owner: user)
    membership = AccountMembership.create!(user: user, account: account, roles: { member: true, admin: false })

    # Verify user can access initially
    assert user.can_access?(account)
    assert_includes user.accounts, account

    # Delete membership
    membership.destroy!

    # Reload associations
    user.reload

    # Verify user can no longer access
    assert_not user.can_access?(account)
    assert_not_includes user.accounts, account
  end

  # TWO-FACTOR AUTHENTICATION TESTS

  test "disable_two_factor! sets otp_required_for_sign_in to false" do
    user = users(:app_admin)
    user.update!(otp_required_for_sign_in: true)

    user.disable_two_factor!

    refute user.reload.otp_required_for_sign_in?
  end

  test "disable_two_factor! deletes all recovery codes" do
    user = users(:app_admin)
    user.update!(otp_required_for_sign_in: true)
    user.recovery_codes.create!(code: "test123456")
    user.recovery_codes.create!(code: "test789012")

    assert_difference "user.recovery_codes.count", -2 do
      user.disable_two_factor!
    end
  end

  test "disable_two_factor! keeps otp_secret for potential re-enabling" do
    user = users(:app_admin)
    original_secret = user.otp_secret
    user.update!(otp_required_for_sign_in: true)

    user.disable_two_factor!

    assert_equal original_secret, user.reload.otp_secret
  end
end
