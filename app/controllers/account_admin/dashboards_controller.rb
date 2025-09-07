class AccountAdmin::DashboardsController < AccountAdmin::BaseController
  def show
    @account = Current.user.account
    @total_users = @account.users.count
    @admin_users = @account.users.where(admin: true).count
    @recent_users = @account.users.order(created_at: :desc).limit(5)
    
    render Views::AccountAdmin::Dashboards::Show.new(
      account: @account,
      total_users: @total_users,
      admin_users: @admin_users,
      recent_users: @recent_users
    )
  end
end