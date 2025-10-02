class RegistrationsController < ApplicationController
  skip_before_action :authenticate
  skip_before_action :ensure_verified
  skip_before_action :set_current_account

  def new
    @user = User.new
    render Views::Registrations::New.new(user: @user)
  end

  def create
    @user = User.new(user_params)

    ActiveRecord::Base.transaction do
      @user.save!

      # Create account based on configuration
      if Boilermaker.config.personal_accounts?
        account_name = params[:account_name].presence || "Personal"
        @account = Account.create!(
          name: account_name,
          personal: true,
          owner: @user
        )
      else
        account_name = params[:account_name].presence || "#{@user.email}'s Team"
        @account = Account.create!(
          name: account_name,
          personal: false,
          owner: @user
        )
      end

      # Create membership
      AccountMembership.create!(
        user: @user,
        account: @account,
        roles: { "admin" => true, "member" => true }
      )

      # Create session with account
      session_record = @user.sessions.create!(account: @account)
      cookies.signed.permanent[:session_token] = { value: session_record.id, httponly: true }

      send_email_verification
    end

    redirect_to root_path, notice: "Welcome! You have signed up successfully"
  rescue ActiveRecord::RecordInvalid => e
    @user.errors.add(:base, e.message) unless @user.errors.any?
    render Views::Registrations::New.new(user: @user), status: :unprocessable_entity
  end

  private
    def user_params
      params.permit(:email, :password, :password_confirmation)
    end

    def send_email_verification
      UserMailer.with(user: @user).email_verification.deliver_later
    end
end
