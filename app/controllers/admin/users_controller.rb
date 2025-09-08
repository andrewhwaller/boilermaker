class Admin::UsersController < Admin::BaseController
  def index
    @users = User.order(:email)
    render Views::Admin::Users::Index.new(users: @users)
  end

  def show
    @user = User.find(params[:id])
    render Views::Admin::Users::Show.new(user: @user)
  end
end
