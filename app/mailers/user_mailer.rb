class UserMailer < ApplicationMailer
  def password_reset
    @user = params[:user]
    @signed_id = @user.generate_token_for(:password_reset)

    mail to: @user.email, subject: "Reset your password"
  end

  def email_verification
    @user = params[:user]
    @signed_id = @user.generate_token_for(:email_verification)

    mail to: @user.email, subject: "Verify your email"
  end

  def invitation_instructions
    @user = params[:user]
    @inviter = params[:inviter]
    @message = params[:message]
    @signed_id = @user.generate_token_for(:invitation)

    mail to: @user.email, subject: "You're invited!"
  end
end
