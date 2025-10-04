class Account::InvitationsController < Account::BaseController
  before_action :set_invitation, only: [ :destroy ]

  def index
    @pending_users = Current.account.members.where(verified: false).order(created_at: :desc)
    render Views::Account::Invitations::Index.new(pending_users: @pending_users)
  end

  def new
    render Views::Account::Invitations::New.new(email: params[:email])
  end

  def create
    email = params[:email]&.strip&.downcase
    message = params[:message]&.strip

    if email.blank? || !email.match?(URI::MailTo::EMAIL_REGEXP)
      redirect_to account_dashboard_path, alert: "Please enter a valid email address."
      return
    end

    # Find existing user or create new one
    user = User.find_or_initialize_by(email: email)

    if user.new_record?
      user.password = SecureRandom.base58
      user.verified = false
      user.app_admin = false
    end

    if user.persisted? && user.verified? && Current.account.members.include?(user)
      redirect_to account_dashboard_path,
        alert: "#{user.email} is already a member of this account."
    elsif user.save
      membership = AccountMembership.find_or_create_by!(user: user, account: Current.account)
      roles = membership.roles.merge("member" => true, "admin" => false)
      membership.update!(roles: roles)
      send_invitation_instructions(user, message)
      redirect_to account_dashboard_path,
        notice: "Invitation sent to #{user.email}"
    else
      redirect_to account_dashboard_path,
        alert: "Error sending invitation: #{user.errors.full_messages.join(', ')}"
    end
  end

  def destroy
    @invitation.destroy!
    redirect_to account_dashboard_path, notice: "Invitation cancelled."
  end

  private

  def set_invitation
    @invitation = Current.account.members.unverified.find(params[:id])
  end

  def send_invitation_instructions(user, message = nil)
    UserMailer.with(
      user: user,
      inviter: Current.user,
      message: message
    ).invitation_instructions.deliver_later
  end
end
