require "test_helper"

class AccountTest < ActiveSupport::TestCase
  def setup
    @account = Account.create!
  end

  test "should be valid" do
    assert @account.valid?
  end

  test "should have many users" do
    user1 = @account.users.create!(email: "user1@example.com", password: "MyVerySecureTestPassword2024!")
    user2 = @account.users.create!(email: "user2@example.com", password: "MyVerySecureTestPassword2024!")
    
    assert_includes @account.users, user1
    assert_includes @account.users, user2
    assert_equal 2, @account.users.count
  end



  test "users should be destroyed when account is destroyed" do
    user = @account.users.create!(email: "user@example.com", password: "MyVerySecureTestPassword2024!")
    user_id = user.id
    
    @account.destroy!
    
    assert_nil User.find_by(id: user_id)
  end
end 