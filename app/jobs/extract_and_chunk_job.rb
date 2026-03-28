# frozen_string_literal: true

class ExtractAndChunkJob < ApplicationJob
  queue_as :default

  retry_on PdfTextExtractor::ExtractionError, wait: 5.seconds, attempts: 2

  def perform(zotero_item)
    unless zotero_item.pdf.attached?
      zotero_item.update!(extraction_status: :failed, full_text: nil)
      Rails.logger.warn "[ExtractAndChunkJob] No PDF attached for ZoteroItem #{zotero_item.id}"
      return
    end

    zotero_item.pdf.open do |tempfile|
      result = PdfTextExtractor.new.extract(tempfile.path)

      zotero_item.transaction do
        # Store full text
        zotero_item.update!(
          full_text: result[:text],
          extraction_status: result[:quality] == :low_quality ? :low_quality : :completed
        )

        # Remove old chunks (for re-extraction)
        zotero_item.document_chunks.destroy_all

        # Create chunks
        chunks = DocumentChunk.chunk_text(result[:text])
        chunks.each do |chunk_data|
          zotero_item.document_chunks.create!(
            content: chunk_data[:content],
            position: chunk_data[:position],
            section_heading: chunk_data[:section_heading]
          )
        end
      end

      # Reset embedding status since chunks changed
      zotero_item.update!(embedding_status: :pending)
    end
  rescue PdfTextExtractor::ExtractionError => e
    zotero_item.update!(extraction_status: :failed, full_text: nil)
    Rails.logger.error "[ExtractAndChunkJob] Extraction failed for ZoteroItem #{zotero_item.id}: #{e.message}"
  end
end
