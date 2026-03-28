# frozen_string_literal: true

class SyncStageJob < ApplicationJob
  queue_as :default

  limits_concurrency to: 1, key: -> { "pipeline" }

  retry_on Net::OpenTimeout, Net::ReadTimeout, wait: :polynomially_longer, attempts: 3 do |_job, error|
    # Final attempt failed — handled by perform's rescue
    Rails.logger.error "[SyncStageJob] Exhausted retries: #{error.message}"
  end

  def perform(pipeline_run)
    pipeline_run.running! if pipeline_run.pending?
    pipeline_run.update!(current_stage: "sync")

    ZoteroSyncService.new(
      account: pipeline_run.account,
      pipeline_run: pipeline_run
    ).call

    ExtractStageJob.perform_later(pipeline_run)
  rescue Net::OpenTimeout, Net::ReadTimeout
    raise # Let retry_on handle transient network errors
  rescue => e
    pipeline_run.failed!(e.message)
  end
end
