class User < ApplicationRecord
  include Hashid::Rails
  belongs_to :account
  has_many :account_memberships, dependent: :destroy
  has_many :accounts, through: :account_memberships
  has_secure_password

  generates_token_for :email_verification, expires_in: 2.days do
    email
  end

  generates_token_for :password_reset, expires_in: 20.minutes do
    password_salt.last(10)
  end

  has_many :sessions, dependent: :destroy
  has_many :recovery_codes, dependent: :destroy

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, allow_nil: true, length: { minimum: -> { Boilermaker.config.password_min_length } }

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

  def admin?
    admin
  end

  # Returns the membership for the given account (or current single account)
  def membership_for(account = nil)
    account ||= self.account
    account_memberships.find_by(account_id: account&.id)
  end

  # Account-scoped admin via membership; app-level admins inherit access
  def account_admin_for?(account = nil)
    return true if admin?
    membership_for(account)&.admin? || false
  end
end
