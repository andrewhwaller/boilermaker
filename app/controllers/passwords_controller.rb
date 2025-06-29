class PasswordsController < ApplicationController
  before_action :set_user

  def edit
    render Views::Passwords::EditFrame.new(user: @user, alert: flash[:alert])
  end

  def update
    if @user.update(user_params)
      respond_to do |format|
        format.html { render Views::Passwords::EditFrame.new(user: @user, notice: "Password updated successfully") }
        format.turbo_stream { render Views::Passwords::EditFrame.new(user: @user, notice: "Password updated successfully") }
      end
    else
      respond_to do |format|
        format.html { render Views::Passwords::EditFrame.new(user: @user, alert: @user.errors.full_messages.to_sentence), status: :unprocessable_entity }
        format.turbo_stream { render Views::Passwords::EditFrame.new(user: @user, alert: @user.errors.full_messages.to_sentence), status: :unprocessable_entity }
      end
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
