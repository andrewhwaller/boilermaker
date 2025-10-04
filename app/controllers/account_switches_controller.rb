class AccountSwitchesController < ApplicationController
  def create
    account = Current.user.accounts.find_by!(id: params[:account_id])
    Current.session.update!(account: account)

    redirect_to root_path, notice: "Switched to #{account.name}"
  end
end
