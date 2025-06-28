class PasswordsController < ApplicationController
  before_action :set_user

  def edit
    render Views::Passwords::Edit.new(user: @user, alert: flash[:alert])
  end

  def update
    if @user.update(user_params)
      redirect_to root_path, notice: "Your password has been changed"
    else
      render Views::Passwords::Edit.new(user: @user), status: :unprocessable_entity
    end
  end

  private
    def set_user
      @user = Current.user
    end

    def user_params
      params.permit(:password, :password_confirmation, :password_challenge).with_defaults(password_challenge: "")
    end
end
