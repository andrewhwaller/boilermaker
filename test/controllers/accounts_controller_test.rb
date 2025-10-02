require "test_helper"

class AccountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @app_admin = users(:app_admin)
    @regular_user = users(:regular_user)
    @personal_account = accounts(:one)
    @team_account = accounts(:two)
    @regular_user_account = accounts(:three)
  end

  test "should redirect to sign in when not authenticated for index" do
    get accounts_url
    assert_redirected_to sign_in_url
  end

  test "index should show all user's accounts separated by personal and team" do
    sign_in_as @app_admin

    get accounts_url
    assert_response :success

    personal_accounts = controller.instance_variable_get(:@personal_accounts)
    team_accounts = controller.instance_variable_get(:@team_accounts)

    assert_not_nil personal_accounts
    assert_not_nil team_accounts
    assert_includes personal_accounts.to_a, @personal_account
    assert_includes team_accounts.to_a, @team_account
  end

  test "index should only show accounts user has access to" do
    sign_in_as @regular_user

    get accounts_url
    assert_response :success

    personal_accounts = controller.instance_variable_get(:@personal_accounts).to_a
    team_accounts = controller.instance_variable_get(:@team_accounts).to_a

    assert_includes personal_accounts, @regular_user_account
    assert_includes team_accounts, @team_account
    assert_not_includes personal_accounts, @personal_account
    assert_not_includes team_accounts, @personal_account
  end

  test "should redirect to sign in when not authenticated for show" do
    get account_url(@team_account)
    assert_redirected_to sign_in_url
  end

  test "show should return 404 when user is not a member" do
    sign_in_as @regular_user

    get account_url(@personal_account)
    assert_response :not_found
  end

  test "should redirect to sign in when not authenticated for new" do
    get new_account_url
    assert_redirected_to sign_in_url
  end

  test "should redirect to sign in when not authenticated for create" do
    assert_no_difference("Account.count") do
      post accounts_url, params: {account: {name: "New Team"}}
    end
    assert_redirected_to sign_in_url
  end

  test "create should create team account and add user as owner and admin member" do
    sign_in_as @app_admin

    assert_difference("Account.count", 1) do
      assert_difference("AccountMembership.count", 1) do
        post accounts_url, params: {account: {name: "New Team Account"}}
      end
    end

    assert_redirected_to account_url(Account.last)
    follow_redirect!
    assert_response :success

    new_account = Account.last
    assert_equal "New Team Account", new_account.name
    assert_equal false, new_account.personal
    assert_equal @app_admin, new_account.owner

    membership = @app_admin.account_memberships.find_by(account: new_account)
    assert_not_nil membership
    assert_equal true, membership.roles["admin"]
    assert_equal true, membership.roles["member"]
    assert_equal "Team created successfully.", flash[:notice]
  end

  test "create should fail with invalid account name" do
    sign_in_as @app_admin

    assert_no_difference("Account.count") do
      assert_no_difference("AccountMembership.count") do
        post accounts_url, params: {account: {name: ""}}
      end
    end

    assert_response :unprocessable_entity
  end

  test "should redirect to sign in when not authenticated for edit" do
    get edit_account_url(@team_account)
    assert_redirected_to sign_in_url
  end

  test "edit should redirect non-owner with alert" do
    sign_in_as @regular_user

    get edit_account_url(@team_account)
    assert_redirected_to account_url(@team_account)
    assert_equal "Only account owners can perform this action.", flash[:alert]
  end

  test "edit should not allow access to accounts user is not a member of" do
    sign_in_as @regular_user

    get edit_account_url(@personal_account)
    assert_response :not_found
  end

  test "should redirect to sign in when not authenticated for update" do
    patch account_url(@team_account), params: {account: {name: "Updated Name"}}
    assert_redirected_to sign_in_url
  end

  test "update should update account when user is owner" do
    sign_in_as @app_admin
    original_name = @team_account.name

    patch account_url(@team_account), params: {account: {name: "Updated Acme Inc"}}
    assert_redirected_to account_url(@team_account)

    @team_account.reload
    assert_equal "Updated Acme Inc", @team_account.name
    assert_equal "Account updated successfully.", flash[:notice]
  end

  test "update should redirect non-owner with alert" do
    sign_in_as @regular_user
    original_name = @team_account.name

    patch account_url(@team_account), params: {account: {name: "Hacked Name"}}
    assert_redirected_to account_url(@team_account)
    assert_equal "Only account owners can perform this action.", flash[:alert]

    @team_account.reload
    assert_equal original_name, @team_account.name
  end

  test "update should fail with invalid data" do
    sign_in_as @app_admin
    original_name = @team_account.name

    patch account_url(@team_account), params: {account: {name: ""}}
    assert_response :unprocessable_entity

    @team_account.reload
    assert_equal original_name, @team_account.name
  end

  test "update should not allow access to accounts user is not a member of" do
    sign_in_as @regular_user

    patch account_url(@personal_account), params: {account: {name: "Hacked Personal"}}
    assert_response :not_found
    @personal_account.reload
    assert_not_equal "Hacked Personal", @personal_account.name
  end

  test "should redirect to sign in when not authenticated for destroy" do
    assert_no_difference("Account.count") do
      delete account_url(@team_account)
    end
    assert_redirected_to sign_in_url
  end

  test "destroy should delete account when user is owner" do
    sign_in_as @app_admin
    account_to_delete = @team_account

    assert_difference("Account.count", -1) do
      delete account_url(account_to_delete)
    end

    assert_redirected_to accounts_url
    assert_equal "Account deleted successfully.", flash[:notice]

    assert_raises(ActiveRecord::RecordNotFound) do
      Account.find(account_to_delete.id)
    end
  end

  test "destroy should redirect non-owner with alert" do
    sign_in_as @regular_user

    assert_no_difference("Account.count") do
      delete account_url(@team_account)
    end

    assert_redirected_to account_url(@team_account)
    assert_equal "Only account owners can perform this action.", flash[:alert]
  end

  test "destroy should not allow access to accounts user is not a member of" do
    sign_in_as @regular_user

    assert_no_difference("Account.count") do
      delete account_url(@personal_account)
    end
    assert_response :not_found
  end

  test "destroy should cascade delete account memberships" do
    sign_in_as @app_admin
    account_to_delete = @team_account
    membership_ids = account_to_delete.account_memberships.pluck(:id)

    assert_difference("Account.count", -1) do
      assert_difference("AccountMembership.count", -membership_ids.count) do
        delete account_url(account_to_delete)
      end
    end

    assert_redirected_to accounts_url

    membership_ids.each do |id|
      assert_not AccountMembership.exists?(id)
    end
  end
end
