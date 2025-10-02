class Identity::InvitationAcceptancesController < ApplicationController
  skip_before_action :authenticate
  skip_before_action :ensure_verified
  skip_before_action :set_current_account

  before_action :set_user

  def show
    render Views::Identity::InvitationAcceptances::Show.new(user: @user, sid: params[:sid])
  end

  def update
    if @user.verified?
      # Existing user - just acknowledge
      redirect_to root_path, notice: "Welcome to the team! You can now access your new account."
    else
      # New user - set password and mark verified
      if @user.update(user_params.merge(verified: true))
        redirect_to sign_in_path, notice: "Your account has been set up! Please sign in."
      else
        render Views::Identity::InvitationAcceptances::Show.new(user: @user, sid: params[:sid]),
               status: :unprocessable_entity
      end
    end
  end

  private

  def set_user
    @user = User.find_by_token_for!(:invitation, params[:sid])
  rescue StandardError
    redirect_to sign_in_path, alert: "That invitation link is invalid or has expired."
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
