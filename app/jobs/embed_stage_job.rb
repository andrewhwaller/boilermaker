# frozen_string_literal: true

class EmbedStageJob < ApplicationJob
  queue_as :default

  limits_concurrency to: 1, key: -> { "pipeline" }

  retry_on Net::OpenTimeout, Net::ReadTimeout, Faraday::TimeoutError,
           wait: :polynomially_longer, attempts: 3 do |_job, error|
    Rails.logger.error "[EmbedStageJob] Exhausted retries: #{error.message}"
  end

  def perform(pipeline_run)
    pipeline_run.update!(current_stage: "embed")

    service = EmbeddingService.new
    items = ZoteroItem.unscoped.where(account: pipeline_run.account).needs_embedding
    pipeline_run.update!(items_total: items.count, items_processed: 0)

    items.find_each do |item|
      chunks = item.document_chunks.where(embedding_model: nil)
      next if chunks.empty?

      begin
        service.embed_chunks(chunks)
        item.update!(embedding_status: :completed)
      rescue => e
        item.update!(embedding_status: :failed)
        pipeline_run.increment!(:items_failed)
        Rails.logger.error "[EmbedStageJob] Failed for ZoteroItem #{item.id}: #{e.message}"
        next
      end

      pipeline_run.increment!(:items_processed)
    end

    pipeline_run.completed!
  rescue Net::OpenTimeout, Net::ReadTimeout, Faraday::TimeoutError
    raise # Let retry_on handle transient network errors
  rescue => e
    pipeline_run.failed!(e.message)
  end
end
