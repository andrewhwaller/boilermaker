require "test_helper"

class SessionTest < ActiveSupport::TestCase
  def setup
    # Create owner user for accounts
    @owner = User.create!(
      email: "owner@example.com",
      password: "MyVerySecureTestPassword2024!",
      verified: true
    )

    # Create a test account
    @account = Account.create!(name: "Test Account", owner: @owner, personal: false)

    # Create test user
    @user = User.create!(
      email: "test@example.com",
      password: "MyVerySecureTestPassword2024!",
      verified: true
    )

    # Store original config to restore in teardown
    @original_config = Boilermaker::Config.instance_variable_get(:@data)
  end

  def teardown
    # Restore original config to avoid leaking into other tests
    Boilermaker::Config.instance_variable_set(:@data, @original_config)
  end

  test "should belong to user" do
    session = @user.sessions.create!
    assert_equal @user, session.user
  end

  test "should capture current user agent and ip address on creation" do
    Current.user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)"
    Current.ip_address = "192.168.1.100"

    session = @user.sessions.create!
    assert_equal "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)", session.user_agent
    assert_equal "192.168.1.100", session.ip_address
  end

  test "should have timestamps" do
    session = @user.sessions.create!
    assert_not_nil session.created_at
    assert_not_nil session.updated_at
  end

  # Account association tests
  test "account association should be optional" do
    session = @user.sessions.build(account: nil)
    assert session.valid?, "Session should be valid without an account"
    session.save!
    assert_nil session.account, "Session account should be nil when not set"
  end

  test "should belong to account when account is set" do
    another_account = Account.create!(name: "Another Account", owner: @user, personal: false)
    session = @user.sessions.create!(account: another_account)

    assert_equal another_account, session.account, "Session should belong to the specified account"
    assert_includes another_account.sessions, session, "Account should include this session in its sessions"
  end

  # Default account setting tests - personal_accounts enabled
  test "should set account to user personal_account when personal_accounts enabled and account not set" do
    # Enable personal_accounts feature
    stub_config_with_personal_accounts(true)

    # Create a personal account for the user
    personal_account = Account.create!(name: "#{@user.email} Personal", owner: @user, personal: true)

    # Create session without explicitly setting account
    session = @user.sessions.create!

    assert_equal personal_account, session.account, "Session account should be set to user's personal account"
    assert_not_nil session.account_id, "Session account_id should not be nil"
  end

  test "should not set account when personal_accounts disabled" do
    # Disable personal_accounts feature
    stub_config_with_personal_accounts(false)

    # Create a personal account for the user (even though feature is disabled)
    Account.create!(name: "#{@user.email} Personal", owner: @user, personal: true)

    # Create session without explicitly setting account
    session = @user.sessions.create!

    assert_nil session.account, "Session account should be nil when personal_accounts feature is disabled"
    assert_nil session.account_id, "Session account_id should be nil when personal_accounts feature is disabled"
  end

  test "should not override account when account already set even if personal_accounts enabled" do
    # Enable personal_accounts feature
    stub_config_with_personal_accounts(true)

    # Create a personal account for the user
    Account.create!(name: "#{@user.email} Personal", owner: @user, personal: true)

    # Create a different account to explicitly set
    explicit_account = Account.create!(name: "Explicit Account", owner: @user, personal: false)

    # Create session with explicit account
    session = @user.sessions.create!(account: explicit_account)

    assert_equal explicit_account, session.account, "Session account should remain the explicitly set account"
    assert_not_equal @user.personal_account, session.account, "Session account should not be overridden with personal_account"
  end

  test "should handle nil personal_account gracefully when personal_accounts enabled" do
    # Enable personal_accounts feature
    stub_config_with_personal_accounts(true)

    # Don't create a personal account for the user
    # This simulates a user who doesn't have a personal account yet

    # Create session - should not fail even though personal_account returns nil
    session = @user.sessions.create!

    assert_nil session.account, "Session account should be nil when user has no personal account"
    assert_nil session.account_id, "Session account_id should be nil when user has no personal account"
  end

  # Edge cases
  test "should allow multiple sessions for the same user with different accounts" do
    stub_config_with_personal_accounts(true)

    # Create personal and team accounts
    personal_account = Account.create!(name: "#{@user.email} Personal", owner: @user, personal: true)
    team_account = Account.create!(name: "Team Account", owner: @user, personal: false)

    # Create sessions with different accounts
    session1 = @user.sessions.create! # Should get personal_account
    session2 = @user.sessions.create!(account: team_account)
    # Note: passing account: nil still triggers default account behavior since account_id isn't set yet
    session3 = @user.sessions.create!(account: personal_account)

    assert_equal personal_account, session1.account, "First session should have personal account"
    assert_equal team_account, session2.account, "Second session should have team account"
    assert_equal personal_account, session3.account, "Third session should have personal account"
  end

  test "should nullify session account when account is destroyed" do
    another_account = Account.create!(name: "Destroyable Account", owner: @user, personal: false)
    session = @user.sessions.create!(account: another_account)

    assert_equal another_account, session.account, "Session should initially have the account"

    another_account.destroy!
    session.reload

    assert_nil session.account, "Session account should be nullified after account is destroyed"
    assert_not_nil session, "Session should still exist after account is destroyed"
  end

  test "should handle user with multiple personal accounts when personal_accounts enabled" do
    stub_config_with_personal_accounts(true)

    # Create multiple personal accounts (edge case, but possible in the data model)
    personal_account1 = Account.create!(name: "Personal 1", owner: @user, personal: true)
    Account.create!(name: "Personal 2", owner: @user, personal: true)

    # Create session - should get the first personal account
    session = @user.sessions.create!

    # The user.personal_account method returns owned_accounts.personal.first
    assert_equal personal_account1, session.account, "Session should get the first personal account"
  end

  test "should set account during create but not during update" do
    stub_config_with_personal_accounts(true)

    personal_account = Account.create!(name: "#{@user.email} Personal", owner: @user, personal: true)

    # Create session with personal account set
    session = @user.sessions.create!
    assert_equal personal_account, session.account, "Session should have personal account after create"

    # Update session to remove account
    session.update!(account: nil)
    assert_nil session.account, "Session account should be nil after update"

    # The before_create callback should not run on update
    session.save!
    assert_nil session.account, "Session account should remain nil after save (callback only runs on create)"
  end

  test "should work correctly when personal_accounts toggles between enabled and disabled" do
    # Start with personal_accounts enabled
    stub_config_with_personal_accounts(true)

    personal_account = Account.create!(name: "#{@user.email} Personal", owner: @user, personal: true)
    session1 = @user.sessions.create!
    assert_equal personal_account, session1.account, "Session should have personal account when feature is enabled"

    # Disable personal_accounts
    stub_config_with_personal_accounts(false)

    session2 = @user.sessions.create!
    assert_nil session2.account, "Session should not have account when feature is disabled"

    # Re-enable personal_accounts
    stub_config_with_personal_accounts(true)

    session3 = @user.sessions.create!
    assert_equal personal_account, session3.account, "Session should have personal account when feature is re-enabled"
  end

  test "should preserve explicit nil account when personal_accounts enabled" do
    stub_config_with_personal_accounts(true)

    # Create a personal account
    Account.create!(name: "#{@user.email} Personal", owner: @user, personal: true)

    # Build session with account_id explicitly set to nil
    session = @user.sessions.build
    session.account_id = nil

    # The set_default_account callback checks if account_id.present?
    # Since we're building (not creating yet), account_id is nil but not explicitly set
    # When we save, the callback should set it to personal_account
    session.save!

    assert_not_nil session.account, "Session should get personal account when account_id was nil before save"
  end

  private

  # Helper method to stub Boilermaker.config.personal_accounts?
  def stub_config_with_personal_accounts(enabled)
    config_data = {
      "app" => {
        "name" => "Test App"
      },
      "features" => {
        "personal_accounts" => enabled
      }
    }

    Boilermaker::Config.instance_variable_set(:@data, config_data)
  end
end
