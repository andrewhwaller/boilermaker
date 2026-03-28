# frozen_string_literal: true

class PipelineRun < ApplicationRecord
  include AccountScoped
  include Hashid::Rails

  STATUSES = %w[pending running completed failed].freeze
  STAGES = %w[sync extract embed].freeze

  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :current_stage, inclusion: { in: STAGES }, allow_nil: true

  scope :recent, -> { order(created_at: :desc) }
  scope :active, -> { where(status: "running") }

  def running!
    update!(status: "running", started_at: Time.current)
  end

  def completed!
    update!(status: "completed", completed_at: Time.current)
  end

  def failed!(error)
    update!(status: "failed", error_message: error, completed_at: Time.current)
  end
end
