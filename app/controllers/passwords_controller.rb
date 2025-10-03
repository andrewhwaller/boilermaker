class PasswordsController < ApplicationController
  before_action :set_user

  def edit
    render Views::Passwords::EditFrame.new(user: @user, alert: flash[:alert])
  end

  def update
    unless @user.authenticate(params[:password_challenge].to_s)
      @user.errors.add(:base, "Password challenge is invalid")
      return respond_to do |format|
        format.html { render Views::Passwords::EditFrame.new(user: @user), status: :unprocessable_entity }
        format.turbo_stream { render Views::Passwords::EditFrame.new(user: @user), status: :unprocessable_entity }
      end
    end

    if @user.update(user_params)
      respond_to do |format|
        format.html { redirect_to root_url, notice: "Password updated successfully" }
        format.turbo_stream { render Views::Passwords::EditFrame.new(user: @user, notice: "Password updated successfully") }
      end
    else
      respond_to do |format|
        format.html { render Views::Passwords::EditFrame.new(user: @user), status: :unprocessable_entity }
        format.turbo_stream { render Views::Passwords::EditFrame.new(user: @user), status: :unprocessable_entity }
      end
    end
  end

  private
    def set_user
      @user = Current.user
    end

    def user_params
      params.permit(:password, :password_confirmation)
    end
end
