class AccountsController < ApplicationController
  before_action :set_account, only: [ :show, :edit, :update, :destroy ]
  before_action :require_owner, only: [ :edit, :update, :destroy ]

  def index
    @personal_accounts = Current.user.accounts.personal.order(:name)
    @team_accounts = Current.user.accounts.team.order(:name)
    render Views::Accounts::Index.new(
      personal_accounts: @personal_accounts,
      team_accounts: @team_accounts
    )
  end

  def show
    render Views::Accounts::Show.new(account: @account)
  end

  def new
    @account = Account.new
    render Views::Accounts::New.new(account: @account)
  end

  def create
    @account = Account.new(account_params)
    @account.personal = false
    @account.owner = Current.user

    if @account.save
      Current.user.account_memberships.create!(account: @account, roles: { "admin" => true, "member" => true })
      redirect_to @account, notice: "Team created successfully."
    else
      render Views::Accounts::New.new(account: @account), status: :unprocessable_entity
    end
  end

  def edit
    render Views::Accounts::Edit.new(account: @account)
  end

  def update
    if @account.update(account_params)
      redirect_to @account, notice: "Account updated successfully."
    else
      render Views::Accounts::Edit.new(account: @account), status: :unprocessable_entity
    end
  end

  def destroy
    @account.destroy
    redirect_to accounts_path, notice: "Account deleted successfully."
  end

  private

  def set_account
    @account = Current.user.accounts.find_by_hashid(params[:id])
  end

  def require_owner
    unless @account.owner == Current.user
      redirect_to @account, alert: "Only account owners can perform this action."
    end
  end

  def account_params
    params.expect(account: [ :name ])
  end
end
