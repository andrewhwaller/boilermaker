class MasqueradesController < ApplicationController
  before_action :authorize_admin
  before_action :set_user

  def create
    session_record = @user.sessions.create!(
      user_agent: request.user_agent,
      ip_address: request.remote_ip
    )
    cookies.signed.permanent[:session_token] = { value: session_record.id, httponly: true }

    redirect_to root_path, notice: "Masquerading as #{@user.email}"
  end

  private
    def set_user
      @user = User.find(params[:user_id])
    end

  def authorize_admin
    unless Current.user&.app_admin?
      redirect_to(root_path, alert: "Access denied")
    end
  end
end
