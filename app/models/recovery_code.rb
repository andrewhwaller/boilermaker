class RecoveryCode < ApplicationRecord
  include Hashid::Rails
  belongs_to :user
end
