class Account::UsersController < Account::BaseController
  before_action :set_user, only: [ :show, :edit, :update ]

  def index
    @users = Current.user.account.users.verified.order(:last_name, :first_name)
    @invitations = Current.user.account.users.unverified.order(created_at: :desc)

    render Views::Account::Users::Index.new(users: @users, invitations: @invitations)
  end

  def show
    render Views::Account::Users::Show.new(user: @user)
  end

  def edit
    render Views::Account::Users::Edit.new(user: @user)
  end

  def update
    admin_flag = params.dig(:user, :admin) == "1"

    if @user.update(user_params)
      membership = AccountMembership.find_or_create_by!(user: @user, account: Current.user.account)
      new_roles = membership.roles.merge("member" => true, "admin" => admin_flag)
      membership.update!(roles: new_roles)
      redirect_to account_user_path(@user), notice: "User updated successfully."
    else
      render Views::Account::Users::Edit.new(user: @user), status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = Current.user.account.users.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :verified)
  end
end
