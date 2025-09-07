class AccountAdmin::BaseController < ApplicationController
  before_action :require_account_admin

  private

  def require_account_admin
    unless Current.user&.admin?
      redirect_to root_path, alert: "Access denied. Admin privileges required."
    end
  end
end