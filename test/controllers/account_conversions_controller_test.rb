require "test_helper"

class AccountConversionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    # Personal account owned by app_admin
    @personal_account = accounts(:one)
    # Team account owned by app_admin with 2 members
    @team_account = accounts(:two)
    # Personal account owned by regular_user
    @regular_user_personal = accounts(:three)

    @owner = users(:app_admin)
    @non_owner = users(:regular_user)
  end

  # ===== to_team tests =====

  test "to_team successfully converts personal account to team when owner" do
    sign_in_as @owner

    # Verify preconditions
    assert @personal_account.personal?, "Account should start as personal"
    assert_equal @owner, @personal_account.owner, "Account should be owned by the signed-in user"

    # Perform conversion
    post account_conversion_to_team_path(@personal_account)

    # Verify conversion succeeded
    @personal_account.reload
    assert @personal_account.team?, "Account should now be a team account"
    refute @personal_account.personal?, "Account should no longer be personal"

    # Verify redirect and flash message
    assert_redirected_to account_path(@personal_account)
    assert_equal "Converted to team account. You can now invite members.", flash[:notice]
  end

  test "to_team prevents conversion when user is not owner" do
    # Create a personal account where regular_user is a member but not the owner
    personal_with_member = Account.create!(
      name: "Personal with Member",
      owner: @owner,
      personal: true
    )
    AccountMembership.create!(
      user: @owner,
      account: personal_with_member,
      roles: { admin: true, member: true }
    )
    AccountMembership.create!(
      user: @non_owner,
      account: personal_with_member,
      roles: { admin: false, member: true }
    )

    sign_in_as @non_owner

    post account_conversion_to_team_path(personal_with_member)

    assert_redirected_to account_path(personal_with_member)
    assert_equal "Only account owners can convert accounts.", flash[:alert]

    personal_with_member.reload
    assert personal_with_member.personal?, "Account should still be personal"
  end

  test "to_team prevents conversion when account is already a team" do
    sign_in_as @owner

    # Verify preconditions
    assert @team_account.team?, "Account should start as team"
    assert_equal @owner, @team_account.owner, "Account should be owned by the signed-in user"

    # Attempt conversion
    post account_conversion_to_team_path(@team_account)

    # Verify account was not changed
    @team_account.reload
    assert @team_account.team?, "Account should still be a team account"

    # Verify redirect and error message
    assert_redirected_to account_path(@team_account)
    assert_equal "Cannot convert this account to a team.", flash[:alert]
  end

  test "to_team returns 404 when user is not a member of the account" do
    sign_in_as @non_owner

    # personal_account (owned by app_admin) - regular_user is NOT a member
    post account_conversion_to_team_path(@personal_account)

    assert_response :not_found
  end

  # ===== to_personal tests =====

  test "to_personal successfully converts team to personal when owner and single member" do
    sign_in_as @owner

    # Setup: Create a team account with only one member (the owner)
    single_member_team = Account.create!(
      name: "Single Member Team",
      owner: @owner,
      personal: false
    )
    AccountMembership.create!(
      user: @owner,
      account: single_member_team,
      roles: { admin: true, member: true }
    )

    # Verify preconditions
    assert single_member_team.team?, "Account should start as team"
    assert_equal @owner, single_member_team.owner, "Account should be owned by the signed-in user"
    assert_equal 1, single_member_team.account_memberships.count, "Account should have exactly 1 member"

    # Perform conversion
    post account_conversion_to_personal_path(single_member_team)

    # Verify conversion succeeded
    single_member_team.reload
    assert single_member_team.personal?, "Account should now be a personal account"
    refute single_member_team.team?, "Account should no longer be a team"

    # Verify redirect and flash message
    assert_redirected_to account_path(single_member_team)
    assert_equal "Converted to personal account.", flash[:notice]
  end

  test "to_personal prevents conversion when user is not owner" do
    sign_in_as @non_owner

    # team_account has regular_user as a member but app_admin as owner
    post account_conversion_to_personal_path(@team_account)

    assert_redirected_to account_path(@team_account)
    assert_equal "Only account owners can convert accounts.", flash[:alert]

    @team_account.reload
    assert @team_account.team?, "Account should still be a team"
  end

  test "to_personal prevents conversion when account is already personal" do
    sign_in_as @owner

    # Verify preconditions
    assert @personal_account.personal?, "Account should start as personal"
    assert_equal @owner, @personal_account.owner, "Account should be owned by the signed-in user"

    # Attempt conversion
    post account_conversion_to_personal_path(@personal_account)

    # Verify account was not changed
    @personal_account.reload
    assert @personal_account.personal?, "Account should still be a personal account"

    # Verify redirect and error message
    assert_redirected_to account_path(@personal_account)
    assert_equal "Cannot convert: remove other members first.", flash[:alert]
  end

  test "to_personal prevents conversion when multiple members exist" do
    sign_in_as @owner

    # Verify preconditions
    assert @team_account.team?, "Account should be a team"
    assert_equal @owner, @team_account.owner, "Account should be owned by the signed-in user"
    assert @team_account.account_memberships.count > 1, "Account should have multiple members"

    # Get the exact count for verbose logging
    membership_count = @team_account.account_memberships.count
    assert_equal 2, membership_count, "Team account should have exactly 2 members (app_admin and regular_user)"

    # Attempt conversion
    post account_conversion_to_personal_path(@team_account)

    # Verify account was not changed
    @team_account.reload
    assert @team_account.team?, "Account should still be a team"
    assert_equal membership_count, @team_account.account_memberships.count, "Membership count should not have changed"

    # Verify redirect and error message
    assert_redirected_to account_path(@team_account)
    assert_equal "Cannot convert: remove other members first.", flash[:alert]
  end

  test "to_personal requires owner role not just admin role" do
    # Create a team with owner and a separate admin
    team_with_admin = Account.create!(
      name: "Team with Non-Owner Admin",
      owner: @owner,
      personal: false
    )
    AccountMembership.create!(
      user: @owner,
      account: team_with_admin,
      roles: { admin: true, member: true }
    )
    AccountMembership.create!(
      user: @non_owner,
      account: team_with_admin,
      roles: { admin: true, member: true }  # This user is admin but NOT owner
    )

    sign_in_as @non_owner

    # Verify preconditions
    assert team_with_admin.team?, "Account should be a team"
    assert_equal @owner, team_with_admin.owner, "Owner should be app_admin, not regular_user"
    assert_not_equal @non_owner, team_with_admin.owner, "Current user should not be the owner"

    post account_conversion_to_personal_path(team_with_admin)

    assert_redirected_to account_path(team_with_admin)
    assert_equal "Only account owners can convert accounts.", flash[:alert]

    team_with_admin.reload
    assert team_with_admin.team?, "Account should still be a team"
  end

  # ===== Edge cases and authorization =====

  test "to_team requires user to be signed in" do
    # Don't sign in - just make the request
    post account_conversion_to_team_path(@personal_account)

    # Should redirect to sign in
    assert_redirected_to sign_in_path
  end

  test "to_personal requires user to be signed in" do
    # Don't sign in - just make the request
    post account_conversion_to_personal_path(@team_account)

    # Should redirect to sign in
    assert_redirected_to sign_in_path
  end

  test "to_personal returns 404 when user is not a member of the account" do
    sign_in_as @non_owner

    # personal_account (owned by app_admin) - regular_user is NOT a member
    post account_conversion_to_personal_path(@personal_account)

    assert_response :not_found
  end

  test "conversion maintains account ownership" do
    sign_in_as @owner

    original_owner = @personal_account.owner

    # Convert to team
    post account_conversion_to_team_path(@personal_account)

    @personal_account.reload
    assert_equal original_owner, @personal_account.owner, "Owner should remain the same after conversion to team"

    # Create single member version to convert back
    # First remove any other members
    @personal_account.account_memberships.where.not(user: @owner).destroy_all

    # Convert back to personal
    post account_conversion_to_personal_path(@personal_account)

    @personal_account.reload
    assert_equal original_owner, @personal_account.owner, "Owner should remain the same after conversion to personal"
  end

  test "conversion only changes personal flag and nothing else" do
    sign_in_as @owner

    original_name = @personal_account.name
    original_owner_id = @personal_account.owner_id
    original_created_at = @personal_account.created_at

    # Convert to team
    post account_conversion_to_team_path(@personal_account)

    @personal_account.reload
    assert_equal original_name, @personal_account.name, "Name should not change"
    assert_equal original_owner_id, @personal_account.owner_id, "Owner ID should not change"
    assert_equal original_created_at.to_i, @personal_account.created_at.to_i, "Created at should not change"
    assert @personal_account.team?, "Should be converted to team"
  end
end
