# frozen_string_literal: true

class SyncStageJob < ApplicationJob
  queue_as :default

  limits_concurrency to: 1, key: -> { "pipeline" }

  def perform(pipeline_run)
    pipeline_run.running!
    pipeline_run.update!(current_stage: "sync")

    ZoteroSyncService.new(
      account: pipeline_run.account,
      pipeline_run: pipeline_run
    ).call

    ExtractStageJob.perform_later(pipeline_run)
  rescue => e
    pipeline_run.failed!(e.message)
  end
end
