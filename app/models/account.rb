class Account < ApplicationRecord
  include Hashid::Rails
  has_many :users, dependent: :destroy
  has_many :account_memberships, dependent: :destroy
  has_many :members, through: :account_memberships, source: :user

  validates :name, presence: true

  # Create a default account if personal accounts are enabled
  def self.create_default_for_user(user_email)
    return unless Boilermaker.config.personal_accounts?

    default_name = Boilermaker.config.get("accounts.default_account_name") || "Personal"
    create!(name: "#{default_name} (#{user_email})")
  end
end
