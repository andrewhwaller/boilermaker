class AccountAdmin::InvitationsController < AccountAdmin::BaseController
  before_action :set_invitation, only: [:destroy]

  def index
    @pending_users = Current.user.account.users.where(verified: false).order(created_at: :desc)
    render Views::AccountAdmin::Invitations::Index.new(pending_users: @pending_users)
  end

  def new
    @invitation = InvitationForm.new
    render Views::AccountAdmin::Invitations::New.new(invitation: @invitation)
  end

  def create
    @invitation = InvitationForm.new(invitation_params)
    
    if @invitation.valid?
      user = User.create_with(user_creation_params).find_or_initialize_by(
        email: @invitation.email,
        account: Current.user.account
      )

      if user.persisted? && user.verified?
        redirect_to new_account_admin_invitation_path, 
          alert: "#{user.email} is already a member of this account."
      elsif user.save
        send_invitation_instructions(user)
        redirect_to account_admin_invitations_path, 
          notice: "Invitation sent to #{user.email}"
      else
        @invitation.errors.merge!(user.errors)
        render Views::AccountAdmin::Invitations::New.new(invitation: @invitation), status: :unprocessable_entity
      end
    else
      render Views::AccountAdmin::Invitations::New.new(invitation: @invitation), status: :unprocessable_entity
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

  def send_invitation_instructions(user)
    UserMailer.with(
      user: user, 
      inviter: Current.user,
      message: @invitation.message
    ).invitation_instructions.deliver_later
  end
end

# Simple form object for invitation validation
class InvitationForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :email, :string
  attribute :admin, :boolean, default: false
  attribute :message, :string

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :message, length: { maximum: 500 }

  def admin?
    admin
  end
end