require "test_helper"

class AccountTest < ActiveSupport::TestCase
  def setup
    # Create owner user for accounts
    @owner = User.create!(
      email: "owner@example.com",
      password: "MyVerySecureTestPassword2024!",
      verified: true
    )

    # Create a personal account
    @personal_account = Account.create!(
      name: "Personal Account",
      owner: @owner,
      personal: true
    )

    # Create a team account
    @team_account = Account.create!(
      name: "Team Account",
      owner: @owner,
      personal: false
    )

    # Create additional user for membership tests
    @member_user = User.create!(
      email: "member@example.com",
      password: "MyVerySecureTestPassword2024!",
      verified: true
    )
  end

  # ============================================================================
  # BASIC VALIDATIONS
  # ============================================================================

  test "should be valid with required attributes" do
    account = Account.new(name: "Valid Account", owner: @owner, personal: true)
    assert account.valid?, "Account should be valid with name, owner, and personal flag"
  end

  test "should require name" do
    account = Account.new(owner: @owner, personal: true)
    assert_not account.valid?, "Account should not be valid without name"
    assert_includes account.errors[:name], "can't be blank"
  end

  test "should require owner" do
    account = Account.new(name: "Test Account", personal: true)
    assert_not account.valid?, "Account should not be valid without owner"
    assert_includes account.errors[:owner], "can't be blank"
  end

  test "should validate personal boolean is present" do
    account = Account.new(name: "Test Account", owner: @owner)
    account.personal = nil
    assert_not account.valid?, "Account should not be valid with nil personal flag"
    assert_includes account.errors[:personal], "is not included in the list"
  end

  test "should accept true for personal" do
    account = Account.new(name: "Test Account", owner: @owner, personal: true)
    assert account.valid?, "Account should accept true for personal flag"
  end

  test "should accept false for personal" do
    account = Account.new(name: "Test Account", owner: @owner, personal: false)
    assert account.valid?, "Account should accept false for personal flag"
  end

  # ============================================================================
  # ASSOCIATIONS - OWNER
  # ============================================================================

  test "should belong to owner" do
    assert_equal @owner, @personal_account.owner, "Account should belong to owner user"
    assert_equal @owner, @team_account.owner, "Team account should belong to owner user"
  end

  test "should be associated with owner's owned_accounts" do
    assert_includes @owner.owned_accounts, @personal_account, "Owner should have personal account in owned_accounts"
    assert_includes @owner.owned_accounts, @team_account, "Owner should have team account in owned_accounts"
  end

  # ============================================================================
  # ASSOCIATIONS - MEMBERSHIPS AND MEMBERS
  # ============================================================================

  test "should have many account_memberships" do
    membership1 = AccountMembership.create!(
      user: @member_user,
      account: @team_account,
      roles: { admin: false, member: true }
    )
    membership2 = AccountMembership.create!(
      user: @owner,
      account: @team_account,
      roles: { admin: true, member: true }
    )

    assert_includes @team_account.account_memberships, membership1, "Account should have membership1"
    assert_includes @team_account.account_memberships, membership2, "Account should have membership2"
    assert_equal 2, @team_account.account_memberships.count, "Account should have 2 memberships"
  end

  test "should have many members through account_memberships" do
    AccountMembership.create!(
      user: @member_user,
      account: @team_account,
      roles: { admin: false, member: true }
    )
    AccountMembership.create!(
      user: @owner,
      account: @team_account,
      roles: { admin: true, member: true }
    )

    assert_includes @team_account.members, @member_user, "Account should include member_user in members"
    assert_includes @team_account.members, @owner, "Account should include owner in members"
    assert_equal 2, @team_account.members.count, "Account should have 2 members"
  end

  test "should destroy account_memberships when account is destroyed" do
    membership = AccountMembership.create!(
      user: @member_user,
      account: @team_account,
      roles: { admin: false, member: true }
    )
    membership_id = membership.id

    @team_account.destroy!

    assert_nil AccountMembership.find_by(id: membership_id), "Membership should be destroyed with account"
  end

  # ============================================================================
  # ASSOCIATIONS - SESSIONS
  # ============================================================================

  test "should have many sessions" do
    session1 = @owner.sessions.create!(account: @personal_account)
    session2 = @member_user.sessions.create!(account: @personal_account)

    assert_includes @personal_account.sessions, session1, "Account should have session1"
    assert_includes @personal_account.sessions, session2, "Account should have session2"
    assert_equal 2, @personal_account.sessions.count, "Account should have 2 sessions"
  end

  test "should nullify sessions when account is destroyed" do
    session = @owner.sessions.create!(account: @personal_account)
    session_id = session.id

    @personal_account.destroy!

    reloaded_session = Session.find_by(id: session_id)
    assert_not_nil reloaded_session, "Session should still exist after account is destroyed"
    assert_nil reloaded_session.account_id, "Session account_id should be nullified after account is destroyed"
  end

  # ============================================================================
  # SCOPES
  # ============================================================================

  test "personal scope should return only personal accounts" do
    personal_accounts = Account.personal

    assert_includes personal_accounts, @personal_account, "Personal scope should include personal account"
    assert_not_includes personal_accounts, @team_account, "Personal scope should not include team account"
  end

  test "team scope should return only team accounts" do
    team_accounts = Account.team

    assert_includes team_accounts, @team_account, "Team scope should include team account"
    assert_not_includes team_accounts, @personal_account, "Team scope should not include personal account"
  end

  # ============================================================================
  # INSTANCE METHODS - PERSONAL? AND TEAM?
  # ============================================================================

  test "personal? should return true for personal accounts" do
    assert @personal_account.personal?, "personal? should return true for personal account"
  end

  test "personal? should return false for team accounts" do
    assert_not @team_account.personal?, "personal? should return false for team account"
  end

  test "team? should return true for team accounts" do
    assert @team_account.team?, "team? should return true for team account"
  end

  test "team? should return false for personal accounts" do
    assert_not @personal_account.team?, "team? should return false for personal account"
  end

  # ============================================================================
  # CONVERSION - CAN_CONVERT_TO_TEAM?
  # ============================================================================

  test "can_convert_to_team? should return true when owner converts personal account" do
    assert @personal_account.can_convert_to_team?(@owner),
      "Owner should be able to convert personal account to team"
  end

  test "can_convert_to_team? should return false when non-owner tries to convert" do
    other_user = User.create!(
      email: "other@example.com",
      password: "MyVerySecureTestPassword2024!",
      verified: true
    )

    assert_not @personal_account.can_convert_to_team?(other_user),
      "Non-owner should not be able to convert account to team"
  end

  test "can_convert_to_team? should return false when account is already a team" do
    assert_not @team_account.can_convert_to_team?(@owner),
      "Should not be able to convert team account to team"
  end

  # ============================================================================
  # CONVERSION - CAN_CONVERT_TO_PERSONAL?
  # ============================================================================

  test "can_convert_to_personal? should return true when owner converts team with single membership" do
    # Create single membership for owner
    AccountMembership.create!(
      user: @owner,
      account: @team_account,
      roles: { admin: true, member: true }
    )

    assert @team_account.can_convert_to_personal?(@owner),
      "Owner should be able to convert team account with single membership to personal"
  end

  test "can_convert_to_personal? should return false when team has multiple memberships" do
    # Create multiple memberships
    AccountMembership.create!(
      user: @owner,
      account: @team_account,
      roles: { admin: true, member: true }
    )
    AccountMembership.create!(
      user: @member_user,
      account: @team_account,
      roles: { admin: false, member: true }
    )

    assert_not @team_account.can_convert_to_personal?(@owner),
      "Should not be able to convert team account with multiple memberships to personal"
  end

  test "can_convert_to_personal? should return false when non-owner tries to convert" do
    # Create single membership
    AccountMembership.create!(
      user: @owner,
      account: @team_account,
      roles: { admin: true, member: true }
    )

    other_user = User.create!(
      email: "other@example.com",
      password: "MyVerySecureTestPassword2024!",
      verified: true
    )

    assert_not @team_account.can_convert_to_personal?(other_user),
      "Non-owner should not be able to convert team account to personal"
  end

  test "can_convert_to_personal? should return false when account is already personal" do
    assert_not @personal_account.can_convert_to_personal?(@owner),
      "Should not be able to convert personal account to personal"
  end

  test "can_convert_to_personal? should return false when team has zero memberships" do
    # No memberships created
    assert_not @team_account.can_convert_to_personal?(@owner),
      "Should not be able to convert team account with zero memberships to personal"
  end

  # ============================================================================
  # CONVERSION - CONVERT_TO_TEAM!
  # ============================================================================

  test "convert_to_team! should convert personal account to team" do
    assert @personal_account.personal?, "Account should start as personal"

    @personal_account.convert_to_team!
    @personal_account.reload

    assert_not @personal_account.personal?, "Account should be converted to team"
    assert @personal_account.team?, "Account should now be a team account"
  end

  test "convert_to_team! should raise error when already a team account" do
    error = assert_raises(RuntimeError) do
      @team_account.convert_to_team!
    end

    assert_equal "Already a team account", error.message,
      "Should raise error with message 'Already a team account'"
  end

  test "convert_to_team! should persist the change to database" do
    @personal_account.convert_to_team!

    reloaded = Account.find(@personal_account.id)
    assert_not reloaded.personal?, "Conversion should be persisted to database"
  end

  # ============================================================================
  # CONVERSION - CONVERT_TO_PERSONAL!
  # ============================================================================

  test "convert_to_personal! should convert team account to personal with single membership" do
    # Create single membership
    AccountMembership.create!(
      user: @owner,
      account: @team_account,
      roles: { admin: true, member: true }
    )

    assert @team_account.team?, "Account should start as team"

    @team_account.convert_to_personal!
    @team_account.reload

    assert @team_account.personal?, "Account should be converted to personal"
    assert_not @team_account.team?, "Account should no longer be a team account"
  end

  test "convert_to_personal! should raise error when already a personal account" do
    error = assert_raises(RuntimeError) do
      @personal_account.convert_to_personal!
    end

    assert_equal "Already a personal account", error.message,
      "Should raise error with message 'Already a personal account'"
  end

  test "convert_to_personal! should raise error when multiple members exist" do
    # Create multiple memberships
    AccountMembership.create!(
      user: @owner,
      account: @team_account,
      roles: { admin: true, member: true }
    )
    AccountMembership.create!(
      user: @member_user,
      account: @team_account,
      roles: { admin: false, member: true }
    )

    error = assert_raises(RuntimeError) do
      @team_account.convert_to_personal!
    end

    assert_equal "Cannot convert: multiple members", error.message,
      "Should raise error with message 'Cannot convert: multiple members'"
  end

  test "convert_to_personal! should persist the change to database" do
    # Create single membership
    AccountMembership.create!(
      user: @owner,
      account: @team_account,
      roles: { admin: true, member: true }
    )

    @team_account.convert_to_personal!

    reloaded = Account.find(@team_account.id)
    assert reloaded.personal?, "Conversion should be persisted to database"
  end

  # ============================================================================
  # EDGE CASES
  # ============================================================================

  test "should allow multiple personal accounts for same owner" do
    second_personal = Account.create!(
      name: "Second Personal",
      owner: @owner,
      personal: true
    )

    assert second_personal.valid?, "Should allow multiple personal accounts for same owner"
    assert_equal @owner, second_personal.owner, "Second account should belong to same owner"
  end

  test "should allow multiple team accounts for same owner" do
    second_team = Account.create!(
      name: "Second Team",
      owner: @owner,
      personal: false
    )

    assert second_team.valid?, "Should allow multiple team accounts for same owner"
    assert_equal @owner, second_team.owner, "Second account should belong to same owner"
  end

  test "convert_to_team! should work on newly created personal account" do
    new_account = Account.create!(
      name: "New Personal",
      owner: @owner,
      personal: true
    )

    new_account.convert_to_team!
    new_account.reload

    assert new_account.team?, "Newly created account should be convertible to team"
  end

  test "convert_to_personal! should work on newly created team account" do
    new_account = Account.create!(
      name: "New Team",
      owner: @owner,
      personal: false
    )

    # Create single membership
    AccountMembership.create!(
      user: @owner,
      account: new_account,
      roles: { admin: true, member: true }
    )

    new_account.convert_to_personal!
    new_account.reload

    assert new_account.personal?, "Newly created team account should be convertible to personal"
  end

  test "should maintain account name after conversion to team" do
    original_name = @personal_account.name
    @personal_account.convert_to_team!
    @personal_account.reload

    assert_equal original_name, @personal_account.name,
      "Account name should remain unchanged after conversion"
  end

  test "should maintain account name after conversion to personal" do
    # Create single membership
    AccountMembership.create!(
      user: @owner,
      account: @team_account,
      roles: { admin: true, member: true }
    )

    original_name = @team_account.name
    @team_account.convert_to_personal!
    @team_account.reload

    assert_equal original_name, @team_account.name,
      "Account name should remain unchanged after conversion"
  end

  test "should maintain owner after conversion to team" do
    @personal_account.convert_to_team!
    @personal_account.reload

    assert_equal @owner, @personal_account.owner,
      "Owner should remain unchanged after conversion to team"
  end

  test "should maintain owner after conversion to personal" do
    # Create single membership
    AccountMembership.create!(
      user: @owner,
      account: @team_account,
      roles: { admin: true, member: true }
    )

    @team_account.convert_to_personal!
    @team_account.reload

    assert_equal @owner, @team_account.owner,
      "Owner should remain unchanged after conversion to personal"
  end
end
