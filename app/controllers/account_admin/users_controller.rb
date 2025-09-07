class AccountAdmin::UsersController < AccountAdmin::BaseController
  before_action :set_user, only: [:show, :edit, :update]

  def index
    @users = Current.user.account.users.order(created_at: :desc)
    @users = @users.where("email ILIKE ?", "%#{params[:search]}%") if params[:search].present?
    
    render Views::AccountAdmin::Users::Index.new(users: @users)
  end

  def show
    render Views::AccountAdmin::Users::Show.new(user: @user)
  end

  def edit
    render Views::AccountAdmin::Users::Edit.new(user: @user)
  end

  def update
    if @user.update(user_params)
      redirect_to account_admin_user_path(@user), notice: "User updated successfully."
    else
      render Views::AccountAdmin::Users::Edit.new(user: @user), status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = Current.user.account.users.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :admin, :verified)
  end
end