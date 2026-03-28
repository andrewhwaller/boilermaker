# frozen_string_literal: true

require "test_helper"

class GenerateEmbeddingsJobTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  setup do
    Current.account = accounts(:one)
    @item = zotero_items(:one)
    # Ensure chunks exist with no embedding_model (needing embedding)
    @item.document_chunks.update_all(embedding_model: nil)
    @item.update_column(:embedding_status, "pending")
  end

  teardown do
    @item.document_chunks.each do |chunk|
      ActiveRecord::Base.connection.execute(
        "DELETE FROM vec_document_chunks WHERE document_chunk_id = #{chunk.id}"
      ) rescue nil
    end
    # Restore fixture state
    @item.document_chunks.update_all(embedding_model: "text-embedding-3-small")
    @item.update_column(:embedding_status, "completed")
    Current.account = nil
  end

  test "job is enqueued to default queue" do
    assert_equal "default", GenerateEmbeddingsJob.new.queue_name,
      "GenerateEmbeddingsJob should be queued on the default queue"
  end

  test "embeds all unembedded chunks and marks item as completed" do
    skip "OpenAI API key not configured" unless Rails.application.credentials.dig(:openai, :api_key).present?

    VCR.use_cassette("embeddings/generate_job", record: :new_episodes) do
      unembedded_count = @item.document_chunks.where(embedding_model: nil).count
      assert unembedded_count > 0, "Setup should leave chunks without embedding_model"

      GenerateEmbeddingsJob.perform_now(@item)

      @item.reload
      assert_equal "completed", @item.embedding_status,
        "embedding_status should be 'completed' after successful job"

      remaining = @item.document_chunks.where(embedding_model: nil).count
      assert_equal 0, remaining,
        "All chunks should have embedding_model set after job completes"
    end
  end

  test "sets embedding_model to text-embedding-3-small on each chunk" do
    skip "OpenAI API key not configured" unless Rails.application.credentials.dig(:openai, :api_key).present?

    VCR.use_cassette("embeddings/generate_job_model_name", record: :new_episodes) do
      GenerateEmbeddingsJob.perform_now(@item)

      @item.document_chunks.reload.each do |chunk|
        assert_equal EmbeddingService::MODEL, chunk.embedding_model,
          "Each chunk should have embedding_model set to '#{EmbeddingService::MODEL}'"
      end
    end
  end

  test "skips job entirely when all chunks are already embedded" do
    @item.document_chunks.update_all(embedding_model: "text-embedding-3-small")

    original_statuses = @item.document_chunks.pluck(:embedding_model)

    GenerateEmbeddingsJob.perform_now(@item)

    current_statuses = @item.document_chunks.reload.pluck(:embedding_model)
    assert_equal original_statuses, current_statuses,
      "Already-embedded chunks should not be re-embedded"
  end

  test "marks item as failed and re-raises when EmbeddingService raises" do
    # Call .new.perform directly to bypass retry_on middleware (consistent with SyncZoteroLibraryJobTest)
    failing_service = EmbeddingService.new
    failing_service.define_singleton_method(:embed_chunks) do |_chunks|
      raise EmbeddingService::EmbeddingError, "API error"
    end

    EmbeddingService.stub(:new, failing_service) do
      assert_raises(EmbeddingService::EmbeddingError) do
        GenerateEmbeddingsJob.new.perform(@item)
      end
    end

    @item.reload
    assert_equal "failed", @item.embedding_status,
      "embedding_status should be 'failed' when EmbeddingService raises an error"
  end

  test "stores vectors in vec_document_chunks for each chunk" do
    skip "OpenAI API key not configured" unless Rails.application.credentials.dig(:openai, :api_key).present?

    VCR.use_cassette("embeddings/generate_job_vectors", record: :new_episodes) do
      GenerateEmbeddingsJob.perform_now(@item)

      @item.document_chunks.each do |chunk|
        result = ActiveRecord::Base.connection.execute(
          "SELECT document_chunk_id FROM vec_document_chunks WHERE document_chunk_id = #{chunk.id}"
        )
        assert_equal 1, result.length,
          "Chunk #{chunk.id} should have a vector stored in vec_document_chunks"
      end
    end
  end
end
