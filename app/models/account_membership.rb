class AccountMembership < ApplicationRecord
  include Hashid::Rails
  belongs_to :user
  belongs_to :account

  # Known role keys for validation and helpers
  ROLE_KEYS = %w[admin member].freeze

  validate :validate_roles_shape

  scope :for_account, ->(account) { where(account_id: account) }
  scope :for_user, ->(user) { where(user_id: user) }
  scope :with_role, ->(key, value = true) do
    adapter = self.connection.adapter_name.downcase
    if adapter.include?("postgres")
      # roles is json (not jsonb). Compare stringified boolean via ->> operator
      where("roles ->> ? = ?", key.to_s, value ? "true" : "false")
    else
      # SQLite JSON1: json_extract returns 1/0 for true/false
      where("json_extract(roles, '$.' || ?) = ?", key.to_s, value ? 1 : 0)
    end
  end

  def role?(key)
    roles[key.to_s] == true
  end

  def admin?
    role?(:admin)
  end

  def member?
    role?(:member)
  end

  def grant!(key)
    update!(roles: roles.merge(key.to_s => true))
  end

  def revoke!(key)
    update!(roles: roles.merge(key.to_s => false))
  end

  private

  def validate_roles_shape
    unless roles.is_a?(Hash)
      errors.add(:roles, "must be a JSON object")
      return
    end

    roles.each do |k, v|
      unless ROLE_KEYS.include?(k.to_s)
        errors.add(:roles, "unknown role '#{k}'")
      end
      unless v == true || v == false
        errors.add(:roles, "role '#{k}' must be boolean true/false")
      end
    end
  end
end
