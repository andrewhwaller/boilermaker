class Account::UsersController < Account::BaseController
  before_action :set_user, only: [ :show, :edit, :update, :destroy ]

  def index
    redirect_to account_invitations_path
  end

  def show
    render Views::Account::Users::Show.new(user: @user)
  end

  def edit
    render Views::Account::Users::Edit.new(user: @user)
  end

  def update
    # Handle role updates separately from user updates
    if params[:role].present?
      update_membership_role
    elsif params[:user].present?
      update_user_attributes
    else
      head :bad_request
    end
  end

  def destroy
    # Prevent users from removing themselves
    if @user == Current.user
      redirect_to account_path, alert: "You cannot remove yourself from the account"
      return
    end

    # Find and destroy the account membership
    membership = AccountMembership.find_by(user: @user, account: Current.user.account)

    if membership&.destroy
      redirect_to account_path, notice: "#{@user.email} has been removed from the account"
    else
      redirect_to account_path, alert: "Failed to remove user from account"
    end
  end

  private

  def set_user
    @user = Current.user.account.users.find(params[:id])
  end

  def update_membership_role
    membership = AccountMembership.find_or_create_by!(user: @user, account: Current.user.account)
    role_param = Array(params[:role]).last
    admin_flag = role_param == "admin"
    new_roles = membership.roles.merge("member" => true, "admin" => admin_flag)

    if membership.update(roles: new_roles)
      respond_to do |format|
        format.turbo_stream { head :ok }
        format.html { redirect_to account_user_path(@user) }
        format.json { head :ok }
      end
    else
      respond_to do |format|
        format.turbo_stream { head :unprocessable_entity }
        format.html { redirect_to account_user_path(@user), alert: "Failed to update role" }
        format.json { head :unprocessable_entity }
      end
    end
  end

  def update_user_attributes
    if @user.update(user_params)
      respond_to do |format|
        format.turbo_stream { head :ok }
        format.html { redirect_to account_user_path(@user) }
        format.json { head :ok }
      end
    else
      respond_to do |format|
        format.turbo_stream { head :unprocessable_entity }
        format.html { redirect_to account_user_path(@user), alert: "Failed to update user" }
        format.json { head :unprocessable_entity }
      end
    end
  end

  def user_params
    params.require(:user).permit(:email)
  end
end
