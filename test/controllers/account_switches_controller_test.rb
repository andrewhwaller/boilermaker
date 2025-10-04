require "test_helper"

class AccountSwitchesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @app_admin = users(:app_admin)
    @regular_user = users(:regular_user)

    # Accounts
    @personal_account = accounts(:one)  # app_admin's personal account
    @team_account = accounts(:two)      # Acme Inc - both users are members
    @regular_user_account = accounts(:three)  # regular_user's personal account
  end

  # Authentication tests
  test "should redirect to sign in when not authenticated" do
    post account_switches_path, params: { account_id: @personal_account.id }

    assert_redirected_to sign_in_path,
      "Expected redirect to sign in path when not authenticated"
    assert_nil flash[:notice],
      "Expected no success notice when not authenticated"
  end

  # Successful account switching tests
  test "should successfully switch to personal account when authenticated" do
    sign_in_as @app_admin

    # Get the current session before switching
    original_session = @app_admin.sessions.last
    assert_not_nil original_session,
      "Expected session to exist after sign in"

    # Switch to personal account
    post account_switches_path, params: { account_id: @personal_account.id }

    assert_redirected_to root_path,
      "Expected redirect to root path after successful account switch"
    assert_equal "Switched to #{@personal_account.name}", flash[:notice],
      "Expected success notice with account name after switching"

    # Verify session was updated with the new account
    original_session.reload
    assert_equal @personal_account.id, original_session.account_id,
      "Expected session account_id to be updated to the switched account"
  end

  test "should successfully switch to team account when user is member" do
    sign_in_as @app_admin

    original_session = @app_admin.sessions.last
    assert_not_nil original_session,
      "Expected session to exist after sign in"

    post account_switches_path, params: { account_id: @team_account.id }

    assert_redirected_to root_path,
      "Expected redirect to root path after switching to team account"
    assert_equal "Switched to #{@team_account.name}", flash[:notice],
      "Expected success notice showing team account name"

    original_session.reload
    assert_equal @team_account.id, original_session.account_id,
      "Expected session account_id to be updated to team account"
  end

  test "should allow regular user to switch between their accessible accounts" do
    sign_in_as @regular_user

    original_session = @regular_user.sessions.last
    assert_not_nil original_session,
      "Expected session to exist after regular user sign in"

    # Switch to team account (regular_user is a member)
    post account_switches_path, params: { account_id: @team_account.id }

    assert_redirected_to root_path,
      "Expected redirect after regular user switches to team account"
    assert_equal "Switched to #{@team_account.name}", flash[:notice],
      "Expected success notice for regular user switching to team account"

    original_session.reload
    assert_equal @team_account.id, original_session.account_id,
      "Expected regular user session to be updated to team account"

    # Switch back to personal account
    post account_switches_path, params: { account_id: @regular_user_account.id }

    assert_redirected_to root_path,
      "Expected redirect after switching back to personal account"
    assert_equal "Switched to #{@regular_user_account.name}", flash[:notice],
      "Expected success notice when switching back to personal account"

    original_session.reload
    assert_equal @regular_user_account.id, original_session.account_id,
      "Expected session to be updated back to personal account"
  end

  # Session persistence tests
  test "should persist account switch across requests" do
    sign_in_as @app_admin

    # Switch to team account
    post account_switches_path, params: { account_id: @team_account.id }
    assert_redirected_to root_path

    # Make another request and verify the account is still set
    get root_path
    assert_response :success,
      "Expected successful response after account switch"

    # Verify Current.session still has the switched account
    session_from_db = @app_admin.sessions.last
    assert_equal @team_account.id, session_from_db.account_id,
      "Expected account switch to persist across requests"
  end

  # Authorization tests - attempting to switch to inaccessible accounts
  test "should return 404 when switching to account user does not have access to" do
    sign_in_as @app_admin

    # Create a completely separate account that app_admin has no membership to
    other_user = User.create!(
      email: "other_user@example.com",
      password: "SecurePassword123!",
      verified: true
    )
    other_account = Account.create!(
      name: "Other Account",
      owner: other_user,
      personal: true
    )
    AccountMembership.create!(
      user: other_user,
      account: other_account,
      roles: { "admin" => true, "member" => true }
    )

    # Attempt to switch to this inaccessible account should return 404
    post account_switches_path, params: { account_id: other_account.id }
    assert_response :not_found

    # Verify the session was not updated
    original_session = @app_admin.sessions.last
    original_session.reload
    assert_not_equal other_account.id, original_session.account_id,
      "Expected session account_id to remain unchanged after failed switch attempt"
  end

  test "should return 404 when regular user attempts to switch to admin's personal account" do
    sign_in_as @regular_user

    # regular_user should not have access to app_admin's personal account
    post account_switches_path, params: { account_id: @personal_account.id }
    assert_response :not_found

    # Verify session was not updated
    original_session = @regular_user.sessions.last
    original_session.reload
    assert_not_equal @personal_account.id, original_session.account_id,
      "Expected regular user session to remain unchanged after attempting to switch to inaccessible account"
  end

  # Edge cases
  test "should return 404 when account_id is invalid" do
    sign_in_as @app_admin

    post account_switches_path, params: { account_id: 999999 }
    assert_response :not_found
  end

  test "should return 404 when account_id is nil" do
    sign_in_as @app_admin

    post account_switches_path, params: { account_id: nil }
    assert_response :not_found
  end

  test "should handle switching to same account user is already on" do
    sign_in_as @app_admin

    # Switch to personal account
    post account_switches_path, params: { account_id: @personal_account.id }
    assert_redirected_to root_path

    original_session = @app_admin.sessions.last
    original_session.reload
    assert_equal @personal_account.id, original_session.account_id

    # Switch to same account again
    post account_switches_path, params: { account_id: @personal_account.id }

    assert_redirected_to root_path,
      "Expected successful redirect even when switching to same account"
    assert_equal "Switched to #{@personal_account.name}", flash[:notice],
      "Expected success notice even when switching to same account"

    original_session.reload
    assert_equal @personal_account.id, original_session.account_id,
      "Expected account to remain the same"
  end

  # Verify controller uses Current.user.accounts scope
  test "should use Current.user.accounts scope to find account" do
    sign_in_as @app_admin

    # This should work because @team_account is in app_admin's accounts
    assert_nothing_raised do
      post account_switches_path, params: { account_id: @team_account.id }
    end

    assert_redirected_to root_path
    assert_match(/Switched to/, flash[:notice],
      "Expected success when account is in user's accounts collection")
  end

  # Test redirect path
  test "should always redirect to root_path after successful switch" do
    sign_in_as @app_admin

    post account_switches_path, params: { account_id: @personal_account.id }

    assert_redirected_to root_path,
      "Expected redirect to root_path, not any other path"

    # Switch to different account
    post account_switches_path, params: { account_id: @team_account.id }

    assert_redirected_to root_path,
      "Expected redirect to root_path for all successful switches"
  end

  # Test flash notice format
  test "should include account name in flash notice" do
    sign_in_as @app_admin

    post account_switches_path, params: { account_id: @team_account.id }

    assert flash[:notice].include?(@team_account.name),
      "Expected flash notice to include the account name '#{@team_account.name}'"
    assert_equal "Switched to #{@team_account.name}", flash[:notice],
      "Expected exact flash notice format: 'Switched to [account name]'"
  end
end
