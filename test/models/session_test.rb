require "test_helper"

class SessionTest < ActiveSupport::TestCase
  def setup
    @account = Account.create!
    @user = @account.users.create!(
      email: "test@example.com",
      password: "MyVerySecureTestPassword2024!"
    )
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
end 