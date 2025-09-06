class Identity::EmailsController < ApplicationController
  skip_before_action :ensure_verified
  before_action :set_user

  def edit
    render Views::Identity::Emails::EditFrame.new(user: @user, alert: flash[:alert])
  end

  def update
    unless @user.authenticate(params[:password_challenge].to_s)
      @user.errors.add(:base, "Password challenge is invalid")
      return respond_to do |format|
        format.html { render Views::Identity::Emails::EditFrame.new(user: @user), status: :unprocessable_entity }
        format.turbo_stream { render Views::Identity::Emails::EditFrame.new(user: @user), status: :unprocessable_entity }
      end
    end

    if @user.update(user_params.except(:password_challenge))
      # Send verification email if email was changed
      if @user.email_previously_changed?
        resend_email_verification
        notice_message = "Email updated successfully. Verification email sent to #{@user.email}"
      else
        notice_message = "Email updated successfully"
      end

      respond_to do |format|
        format.html { redirect_to root_url, notice: notice_message }
        format.turbo_stream { render Views::Identity::Emails::EditFrame.new(user: @user, notice: notice_message) }
      end
    else
      respond_to do |format|
        format.html { render Views::Identity::Emails::EditFrame.new(user: @user), status: :unprocessable_entity }
        format.turbo_stream { render Views::Identity::Emails::EditFrame.new(user: @user), status: :unprocessable_entity }
      end
    end
  end

  private
    def set_user
      @user = Current.user
    end

    def user_params
      params.permit(:email, :password_challenge).with_defaults(password_challenge: "")
    end



    def resend_email_verification
      UserMailer.with(user: @user).email_verification.deliver_later
    end
end
