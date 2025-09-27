class Account::DashboardsController < Account::BaseController
  def show
    account = Current.user.account

    render Views::Account::Dashboards::Show.new(
      account: account,
      users: account.users.verified.order(:last_name, :first_name),
      invitations: account.users.unverified.order(created_at: :desc)
    )
  end

  def update
    account = Current.user.account

    if account.update(account_params)
      redirect_to account_path, notice: "Account updated successfully"
    else
      redirect_to account_path, alert: "Failed to update account: #{account.errors.full_messages.join(', ')}"
    end
  end

  private

  def account_params
    params.require(:account).permit(:name)
  end
end
