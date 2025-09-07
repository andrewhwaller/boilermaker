class Account < ApplicationRecord
  has_many :users, dependent: :destroy

  validates :name, presence: true

  # Create a default account if personal accounts are enabled
  def self.create_default_for_user(user_email)
    return unless Boilermaker.config.personal_accounts?

    default_name = Boilermaker.config.get("accounts.default_account_name") || "Personal"
    create!(name: "#{default_name} (#{user_email})")
  end
end
