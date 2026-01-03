# frozen_string_literal: true

class MasqueradesController < ApplicationController
  before_action :authorize_admin, only: :create
  before_action :authorize_impersonation_exit, only: :destroy
  before_action :set_user, only: :create

  def create
    if @user.app_admin?
      redirect_to admin_users_path, alert: "Cannot impersonate other administrators"
      return
    end

    session_record = @user.sessions.create!(
      user_agent: request.user_agent,
      ip_address: request.remote_ip,
      impersonator: Current.user
    )
    cookies.signed.permanent[:session_token] = { value: session_record.id, httponly: true }

    redirect_to root_path, notice: "Now masquerading as #{@user.email}"
  end

  def destroy
    impersonator = Current.session.impersonator
    impersonated_user = Current.user

    Current.session.destroy

    new_session = impersonator.sessions.create!(
      user_agent: request.user_agent,
      ip_address: request.remote_ip
    )
    cookies.signed.permanent[:session_token] = { value: new_session.id, httponly: true }

    redirect_to admin_users_path, notice: "Stopped masquerading as #{impersonated_user.email}"
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def authorize_admin
    return if Current.user&.app_admin?

    redirect_to root_path, alert: "Access denied"
  end

  def authorize_impersonation_exit
    return if Current.session&.impersonator.present?

    redirect_to root_path, alert: "Not currently impersonating anyone"
  end
end
