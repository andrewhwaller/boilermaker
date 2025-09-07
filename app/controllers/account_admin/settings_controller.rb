class AccountAdmin::SettingsController < AccountAdmin::BaseController
  before_action :set_account

  def show
  end

  def edit
  end

  def update
    if @account.update(account_params)
      redirect_to account_admin_settings_path, notice: "Account settings updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_account
    @account = Current.user.account
  end

  def account_params
    params.require(:account).permit(:name)
  end
end