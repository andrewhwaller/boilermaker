class AccountConversionsController < ApplicationController
  before_action :set_account
  before_action :require_owner

  def to_team
    if @account.can_convert_to_team?(Current.user)
      @account.convert_to_team!
      redirect_to @account, notice: "Converted to team account. You can now invite members."
    else
      redirect_to @account, alert: "Cannot convert this account to a team."
    end
  end

  def to_personal
    if @account.can_convert_to_personal?(Current.user)
      @account.convert_to_personal!
      redirect_to @account, notice: "Converted to personal account."
    else
      redirect_to @account, alert: "Cannot convert: remove other members first."
    end
  end

  private

  def set_account
    @account = Current.user.accounts.find(params[:account_id])
  end

  def require_owner
    unless @account.owner == Current.user
      redirect_to @account, alert: "Only account owners can convert accounts."
    end
  end
end
