class AccountAdmin::DashboardsController < AccountAdmin::BaseController
  def show
    @account = Current.user.account
    @total_users = @account.users.count
    @admin_users = @account.users.where(admin: true).count
    @recent_users = @account.users.order(created_at: :desc).limit(5)
  end
end