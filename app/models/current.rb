class Current < ActiveSupport::CurrentAttributes
  attribute :session, :account
  attribute :user_agent, :ip_address, :theme_name

  delegate :user, to: :session, allow_nil: true
end
