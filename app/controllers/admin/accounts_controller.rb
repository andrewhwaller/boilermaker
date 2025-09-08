class Admin::AccountsController < Admin::BaseController
  def index
    @accounts = Account.order(:name)
    render Views::Admin::Accounts::Index.new(accounts: @accounts)
  end

  def show
    @account = Account.find(params[:id])
    @members = @account.members.order(:email)
    render Views::Admin::Accounts::Show.new(account: @account, members: @members)
  end
end
