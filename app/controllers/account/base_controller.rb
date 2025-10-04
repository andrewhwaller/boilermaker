class Account::BaseController < ApplicationController
  before_action :require_account_admin

  private

  def require_account_admin
    unless Current.account && Current.user&.account_admin_for?(Current.account)
      redirect_to root_path, alert: "Access denied. Admin privileges required." and return
    end
  end
end
