# frozen_string_literal: true

class Message < ApplicationRecord
  belongs_to :conversation
  has_many :message_sources, dependent: :destroy

  validates :role, presence: true, inclusion: { in: %w[system user assistant] }

  default_scope { order(:created_at) }

  def complete!
    update!(complete: true)
  end
end
