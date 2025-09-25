class SessionsController < ApplicationController
  skip_before_action :authenticate, only: %i[ new create ]
  skip_before_action :ensure_verified

  before_action :set_session, only: :destroy

  def index
    render Views::Sessions::Index.new
  end

  def new
    render Views::Sessions::New.new(email_hint: params[:email_hint])
  end

  def create
    if user = User.authenticate_by(email: params[:email], password: params[:password])
      if user.otp_required_for_sign_in?
        session[:challenge_token] = user.signed_id(purpose: :authentication_challenge, expires_in: 10.minutes)
        redirect_to new_two_factor_authentication_challenge_totp_path
      else
        @session = user.sessions.create!
        cookies.signed.permanent[:session_token] = { value: @session.id, httponly: true }

        redirect_to root_path, notice: "Signed in successfully"
      end
    else
      redirect_to sign_in_path(email_hint: params[:email]), alert: "That email or password is incorrect"
    end
  end

  def destroy
    @session.destroy; redirect_to(root_path, notice: "That session has been logged out")
  end

  private
    def set_session
      if params[:id] == "current"
        @session = Current.session
      else
        @session = Current.user.sessions.find(params[:id])
      end
    end
end
