class AccountAdmin::InvitationsController < AccountAdmin::BaseController
  before_action :set_invitation, only: [:destroy]

  def index
    @pending_users = Current.user.account.users.where(verified: false).order(created_at: :desc)
    render Views::AccountAdmin::Invitations::Index.new(pending_users: @pending_users)
  end

  def new
    render Views::AccountAdmin::Invitations::New.new
  end

  def create
    email = params[:email]&.strip&.downcase
    admin = params[:admin] == "1"
    message = params[:message]&.strip
    
    if email.blank? || !email.match?(URI::MailTo::EMAIL_REGEXP)
      redirect_to account_admin_invitations_path, alert: "Please enter a valid email address."
      return
    end
    
    user = User.create_with(
      password: SecureRandom.base58,
      verified: false,
      admin: admin,
      account: Current.user.account
    ).find_or_initialize_by(
      email: email,
      account: Current.user.account
    )

    if user.persisted? && user.verified?
      redirect_to account_admin_invitations_path, 
        alert: "#{user.email} is already a member of this account."
    elsif user.save
      send_invitation_instructions(user, message)
      redirect_to account_admin_invitations_path, 
        notice: "Invitation sent to #{user.email}"
    else
      redirect_to account_admin_invitations_path,
        alert: "Error sending invitation: #{user.errors.full_messages.join(', ')}"
    end
  end

  def destroy
    @invitation.destroy!
    redirect_to account_admin_invitations_path, notice: "Invitation cancelled."
  end

  private

  def set_invitation
    @invitation = Current.user.account.users.unverified.find(params[:id])
  end

  def invitation_params
    params.require(:invitation_form).permit(:email, :admin, :message)
  end

  def user_creation_params
    {
      password: SecureRandom.base58,
      verified: false,
      admin: @invitation.admin,
      account: Current.user.account
    }
  end

  def send_invitation_instructions(user, message = nil)
    UserMailer.with(
      user: user, 
      inviter: Current.user,
      message: message
    ).invitation_instructions.deliver_later
  end
end