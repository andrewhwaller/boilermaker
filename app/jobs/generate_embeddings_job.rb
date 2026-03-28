# frozen_string_literal: true

class GenerateEmbeddingsJob < ApplicationJob
  queue_as :default

  limits_concurrency to: 1, key: -> { "embeddings" }
  retry_on StandardError, wait: :polynomially_longer, attempts: 3

  def perform(zotero_item)
    chunks = zotero_item.document_chunks.where(embedding_model: nil)
    return if chunks.empty?

    service = EmbeddingService.new
    service.embed_chunks(chunks)

    zotero_item.update!(embedding_status: :completed)
  rescue => e
    zotero_item.update!(embedding_status: :failed)
    Rails.logger.error "[GenerateEmbeddingsJob] Failed for ZoteroItem #{zotero_item.id}: #{e.message}"
    raise
  end
end
