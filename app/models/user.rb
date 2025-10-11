class User < ApplicationRecord
  include Hashid::Rails
  has_many :sessions, dependent: :destroy
  has_many :account_memberships, dependent: :destroy
  has_many :accounts, through: :account_memberships
  has_many :owned_accounts, class_name: "Account", foreign_key: :owner_id, dependent: :destroy
  has_many :recovery_codes, dependent: :destroy
  has_secure_password

  generates_token_for :email_verification, expires_in: 2.days do
    email
  end

  generates_token_for :password_reset, expires_in: 20.minutes do
    password_salt.last(10)
  end

  generates_token_for :invitation, expires_in: 7.days do
    email
  end

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, allow_nil: true, length: { minimum: 12 }

  normalizes :email, with: -> { _1.strip.downcase }

  scope :unverified, -> { where(verified: false) }
  scope :verified, -> { where(verified: true) }

  before_validation if: :email_changed?, on: :update do
    self.verified = false
  end

  before_create do
    self.otp_secret = ROTP::Base32.random if otp_secret.blank?
  end

  after_update if: :password_digest_previously_changed? do
    sessions.where.not(id: Current.session).delete_all
  end

  def app_admin?
    app_admin
  end

  # Personal account lookup (when feature enabled)
  def personal_account
    return nil unless Boilermaker.config.personal_accounts?
    owned_accounts.personal.first
  end

  # Check if user can access account
  def can_access?(account)
    accounts.include?(account)
  end

  # Returns the membership for the given account
  def membership_for(account)
    account_memberships.find_by(account_id: account&.id)
  end

  # Account-scoped admin via membership; app-level admins inherit access
  def account_admin_for?(account)
    return true if app_admin?
    membership_for(account)&.admin? || false
  end

  # Disable 2FA and remove recovery codes atomically
  def disable_two_factor!
    transaction do
      update!(otp_required_for_sign_in: false)
      recovery_codes.delete_all
      # Note: otp_secret is intentionally kept to allow re-enabling without re-scanning QR code
      # Users can regenerate secret via TotpsController#update if desired
    end
  end
end
