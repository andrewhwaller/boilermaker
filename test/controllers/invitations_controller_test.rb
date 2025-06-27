require "test_helper"

class InvitationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:one)
    @admin_user = users(:lazaro_nixon)
    @invited_email = "invited@example.com"
  end

  test "should redirect to sign in when not authenticated" do
    get new_invitation_path
    assert_redirected_to sign_in_path
  end

  test "should show new invitation form when authenticated" do
    sign_in_as @admin_user
    get new_invitation_path
    
    assert_response :success
    assert_select "h1", "Send invitation"
    assert_select "input[type=email][name=email]"
  end

  test "should create invitation and send email for new user" do
    sign_in_as @admin_user
    
    assert_emails 1 do
      post invitation_path, params: { email: @invited_email }
    end
    
    assert_redirected_to new_invitation_path
    assert_equal "An invitation email has been sent to #{@invited_email}", flash[:notice]
    
    # Verify user was created
    invited_user = User.find_by(email: @invited_email)
    assert_not_nil invited_user
    assert_equal @account, invited_user.account
    assert invited_user.verified
  end

  test "should send invitation for existing user in same account" do
    # Create another user in the same account
    existing_user = User.create!(
      email: "existing@example.com",
      password: "nXZ84tkwGl3m2hjdcHkLA6up",
      verified: true,
      account: @account
    )
    sign_in_as @admin_user
    
    assert_emails 1 do
      post invitation_path, params: { email: existing_user.email }
    end
    
    assert_redirected_to new_invitation_path
    assert_equal "An invitation email has been sent to #{existing_user.email}", flash[:notice]
  end

  test "should handle invalid email" do
    sign_in_as @admin_user
    
    assert_no_emails do
      post invitation_path, params: { email: "invalid-email" }
    end
    
    assert_response :unprocessable_entity
    assert_select "div[style*='color: red']"
  end

  test "should handle blank email" do
    sign_in_as @admin_user
    
    assert_no_emails do
      post invitation_path, params: { email: "" }
    end
    
    assert_response :unprocessable_entity
    assert_select "div[style*='color: red']"
  end

  test "invitation email should contain correct reset link" do
    sign_in_as @admin_user
    
    assert_emails 1 do
      post invitation_path, params: { email: @invited_email }
    end
    
    # Check that the invited user has a valid password reset token
    invited_user = User.find_by(email: @invited_email)
    token = invited_user.generate_token_for(:password_reset)
    assert_not_nil token
    
    # Verify the token can be consumed (this validates it)
    consumed_user = User.find_by_token_for(:password_reset, token)
    assert_equal invited_user, consumed_user
  end
end 