class Admin::BaseController < ApplicationController
  before_action :require_app_admin

  private

  def require_app_admin
    unless Current.user&.app_admin?
      redirect_to root_path, alert: "Access denied. Application admin required."
    end
  end
end
