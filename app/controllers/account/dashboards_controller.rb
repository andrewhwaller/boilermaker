class Account::DashboardsController < Account::BaseController
  def show
    @account = Current.user.account
    @recent_users = @account.users.verified.order(:last_name, :first_name).limit(5)
    @recent_invitations = @account.users.unverified.order(created_at: :desc).limit(5)

    render Views::Account::Dashboards::Show.new(
      account: @account,
      recent_users: @recent_users,
      recent_invitations: @recent_invitations
    )
  end
end
