class Account::DashboardsController < Account::BaseController
  def show
    account = Current.account

    render Views::Account::Dashboards::Show.new(
      account: account,
      users: account.members.verified.order(:last_name, :first_name),
      invitations: account.members.unverified.order(created_at: :desc)
    )
  end

  def update
    account = Current.account

    if account.update(account_params)
      redirect_to account_dashboard_path, notice: "Account updated successfully"
    else
      redirect_to account_dashboard_path, alert: "Failed to update account: #{account.errors.full_messages.join(', ')}"
    end
  end

  private

  def account_params
    params.expect(account: [ :name ])
  end
end
