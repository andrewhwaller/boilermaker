class Account::DashboardsController < Account::BaseController
  def show
    account = Current.user.account

    render Views::Account::Dashboards::Show.new(
      account: account,
      users: account.users.verified.order(:last_name, :first_name),
      invitations: account.users.unverified.order(created_at: :desc)
    )
  end
end
