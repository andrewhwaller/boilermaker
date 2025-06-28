class Account < ApplicationRecord
  has_many :users, dependent: :destroy

  validates :name, presence: true
  validate :max_users_limit, on: :create

  # Create a default account if personal accounts are enabled
  def self.create_default_for_user(user_email)
    return unless Boilermaker.config.personal_accounts?

    default_name = Boilermaker.config.get("accounts.default_account_name") || "Personal"
    create!(name: "#{default_name} (#{user_email})")
  end

  # Check if this account can accept more users
  def can_add_user?
    return true unless Boilermaker.config.multi_tenant?

    max_users = Boilermaker.config.max_users_per_account
    users.count < max_users
  end

  private

  def max_users_limit
    return unless Boilermaker.config.multi_tenant?

    max_users = Boilermaker.config.max_users_per_account
    if users.count >= max_users
      errors.add(:base, "Account has reached the maximum number of users (#{max_users})")
    end
  end
end
