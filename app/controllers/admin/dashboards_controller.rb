class Admin::DashboardsController < Admin::BaseController
  def show
    render Views::Admin::Dashboards::Show.new
  end
end
