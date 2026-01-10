class Account < ApplicationRecord
  pay_customer
  include Notifiable
  include Hashid::Rails

  belongs_to :owner, class_name: "User"
  has_many :account_memberships, dependent: :destroy
  has_many :members, through: :account_memberships, source: :user
  has_many :sessions, dependent: :nullify

  validates :name, presence: true
  validates :personal, inclusion: { in: [ true, false ] }
  validates :owner, presence: true

  scope :personal, -> { where(personal: true) }
  scope :team, -> { where(personal: false) }

  def personal?
    personal
  end

  def team?
    !personal
  end

  # Conversion methods
  def can_convert_to_team?(user)
    personal? && owner == user
  end

  def can_convert_to_personal?(user)
    team? && owner == user && account_memberships.count == 1
  end

  def convert_to_team!
    raise "Already a team account" if team?
    update!(personal: false)
  end

  def convert_to_personal!
    raise "Already a personal account" if personal?
    raise "Cannot convert: multiple members" if account_memberships.count > 1
    update!(personal: true)
  end
end
