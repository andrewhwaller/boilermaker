class RegistrationsController < ApplicationController
  skip_before_action :authenticate
  skip_before_action :ensure_verified

  def new
    @user = User.new
    render Views::Registrations::New.new(user: @user)
  end

  def create
    @account = Account.create!
    @user = @account.users.build(user_params)

    if @user.save
      session_record = @user.sessions.create!
      cookies.signed.permanent[:session_token] = { value: session_record.id, httponly: true }

      send_email_verification
      redirect_to root_path, notice: "Welcome! You have signed up successfully"
    else
      render Views::Registrations::New.new(user: @user), status: :unprocessable_entity
    end
  end

  private
    def user_params
      params.permit(:email, :password, :password_confirmation)
    end

    def send_email_verification
      UserMailer.with(user: @user).email_verification.deliver_later
    end
end
