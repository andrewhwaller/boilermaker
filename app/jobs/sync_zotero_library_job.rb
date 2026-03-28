# frozen_string_literal: true

class SyncZoteroLibraryJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: :polynomially_longer, attempts: 3

  def perform(pipeline_run)
    pipeline_run.update!(current_stage: "sync")

    ZoteroSyncService.new(
      account: pipeline_run.account,
      pipeline_run: pipeline_run
    ).call
  rescue StandardError => e
    pipeline_run.failed!(e.message)
    raise
  end
end
