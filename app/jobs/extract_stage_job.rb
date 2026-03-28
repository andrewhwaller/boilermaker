# frozen_string_literal: true

class ExtractStageJob < ApplicationJob
  queue_as :default

  limits_concurrency to: 1, key: -> { "pipeline" }

  def perform(pipeline_run)
    pipeline_run.update!(current_stage: "extract")

    items = ZoteroItem.unscoped.where(account: pipeline_run.account).needs_extraction
    pipeline_run.update!(items_total: items.count, items_processed: 0)

    items.find_each do |item|
      next unless item.pdf.attached?

      begin
        item.pdf.open do |tempfile|
          result = PdfTextExtractor.new.extract(tempfile.path)

          item.transaction do
            item.update!(
              full_text: result[:text],
              extraction_status: result[:quality] == :low_quality ? :low_quality : :completed
            )
            EmbeddingService.new.delete_vectors(item.document_chunks.pluck(:id))
            item.document_chunks.destroy_all
            chunks = DocumentChunk.chunk_text(result[:text])
            chunks.each do |chunk_data|
              item.document_chunks.create!(
                content: chunk_data[:content],
                position: chunk_data[:position],
                section_heading: chunk_data[:section_heading]
              )
            end
          end
        end
      rescue => e
        item.update!(extraction_status: :failed)
        pipeline_run.increment!(:items_failed)
        Rails.logger.error "[ExtractStageJob] Failed for ZoteroItem #{item.id}: #{e.message}"
        next
      end

      pipeline_run.increment!(:items_processed)
      item.update!(embedding_status: :pending)
    end

    EmbedStageJob.perform_later(pipeline_run)
  rescue => e
    pipeline_run.failed!(e.message)
  end
end
