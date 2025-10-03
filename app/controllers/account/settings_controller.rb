class Account::SettingsController < Account::BaseController
  before_action :set_account

  def show
    render Views::Account::Settings::Show.new(account: @account)
  end

  def edit
    render Views::Account::Settings::Edit.new(account: @account)
  end

  def update
    if @account.update(account_params)
      redirect_to account_settings_path, notice: "Account settings updated successfully."
    else
      render Views::Account::Settings::Edit.new(account: @account), status: :unprocessable_entity
    end
  end

  private

  def set_account
    @account = Current.account
  end

  def account_params
    params.expect(account: [ :name ])
  end
end
