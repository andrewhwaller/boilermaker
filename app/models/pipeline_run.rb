# frozen_string_literal: true

class PipelineRun < ApplicationRecord
  include AccountScoped
  include Hashid::Rails

  enum :status, { pending: "pending", running: "running", completed: "completed", failed: "failed" }

  validates :current_stage, inclusion: { in: %w[sync extract embed] }, allow_nil: true

  scope :recent, -> { order(created_at: :desc) }
  scope :active, -> { where(status: "running") }

  def running!
    raise "Cannot transition to running from #{status}" unless pending?

    update!(status: "running", started_at: Time.current)
  end

  def completed!
    raise "Cannot transition to completed from #{status}" unless running?

    update!(status: "completed", completed_at: Time.current)
  end

  def failed!(error)
    raise "Cannot transition to failed from #{status}" unless pending? || running?

    update!(status: "failed", error_message: error, completed_at: Time.current)
  end
end
