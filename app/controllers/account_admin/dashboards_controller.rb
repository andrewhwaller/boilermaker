class AccountAdmin::DashboardsController < AccountAdmin::BaseController
  def show
    @account = Current.user.account
    @total_users = @account.users.count
    @admin_users = @account.users.where(admin: true).count
    
    render Views::AccountAdmin::Dashboards::Show.new(
      account: @account,
      total_users: @total_users,
      admin_users: @admin_users
    )
  end
end