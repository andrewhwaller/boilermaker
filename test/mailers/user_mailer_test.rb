require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  setup do
    @user = users(:lazaro_nixon)
  end

  test "password_reset" do
    mail = UserMailer.with(user: @user).password_reset
    assert_equal "Reset your password", mail.subject
    assert_equal [@user.email], mail.to
  end

  test "email_verification" do
    mail = UserMailer.with(user: @user).email_verification
    assert_equal "Verify your email", mail.subject
    assert_equal [@user.email], mail.to
  end

  test "invitation_instructions" do
    mail = UserMailer.with(user: @user).invitation_instructions
    assert_equal "You're invited!", mail.subject
    assert_equal [@user.email], mail.to
    assert_match "Someone has invited you", mail.body.to_s
    assert_match "Accept invitation", mail.body.to_s
  end
end
