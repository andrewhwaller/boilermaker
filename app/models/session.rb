class Session < ApplicationRecord
  include Hashid::Rails
  belongs_to :user
  belongs_to :account, optional: true

  before_create do
    self.user_agent = Current.user_agent
    self.ip_address = Current.ip_address
    set_default_account
  end

  private

  def set_default_account
    return if account_id.present?
    return unless Boilermaker.config.personal_accounts?

    self.account = user.personal_account
  end
end
