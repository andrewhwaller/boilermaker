# frozen_string_literal: true

require "test_helper"

class EmbeddingServiceTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  setup do
    Current.account = accounts(:one)
    @service = EmbeddingService.new
    @item = zotero_items(:one)
    @chunk = DocumentChunk.create!(
      zotero_item: @item,
      content: "Test content for embedding",
      position: 999,
      section_heading: "Test"
    )
  end

  teardown do
    ActiveRecord::Base.connection.execute(
      "DELETE FROM vec_document_chunks WHERE document_chunk_id = #{@chunk.id}"
    ) rescue nil
    @chunk.destroy
    Current.account = nil
  end

  # --- Vector storage tests (no API calls) ---

  test "store_vector inserts into vec0 table" do
    vector = Array.new(EmbeddingService::DIMENSIONS) { rand(-1.0..1.0) }

    @service.store_vector(@chunk.id, vector)

    result = ActiveRecord::Base.connection.execute(
      "SELECT document_chunk_id FROM vec_document_chunks WHERE document_chunk_id = #{@chunk.id}"
    )
    assert_equal 1, result.length,
      "Should have exactly one row in vec_document_chunks for chunk #{@chunk.id}"
  end

  test "store_vector replaces existing vector on re-embedding" do
    vector1 = Array.new(EmbeddingService::DIMENSIONS) { 0.5 }
    vector2 = Array.new(EmbeddingService::DIMENSIONS) { -0.5 }

    @service.store_vector(@chunk.id, vector1)
    @service.store_vector(@chunk.id, vector2)

    result = ActiveRecord::Base.connection.execute(
      "SELECT document_chunk_id FROM vec_document_chunks WHERE document_chunk_id = #{@chunk.id}"
    )
    assert_equal 1, result.length,
      "Should have exactly one vector after re-embedding, not two"
  end

  test "nearest_neighbors returns results after vector insertion" do
    vector = Array.new(EmbeddingService::DIMENSIONS) { rand(-1.0..1.0) }

    @service.store_vector(@chunk.id, vector)

    results = @service.nearest_neighbors(vector, k: 5)
    assert results.any?, "Should find at least one neighbor after inserting a vector"
    chunk_ids = results.map { |r| r["document_chunk_id"] }
    assert_includes chunk_ids, @chunk.id,
      "The inserted chunk should appear in nearest_neighbors results"
  end

  test "nearest_neighbors returns at most k results" do
    vector = Array.new(EmbeddingService::DIMENSIONS) { rand(-1.0..1.0) }
    @service.store_vector(@chunk.id, vector)

    results = @service.nearest_neighbors(vector, k: 1)
    assert results.length <= 1,
      "nearest_neighbors(k: 1) should return at most 1 result, got #{results.length}"
  end

  test "truncates long input to MAX_INPUT_LENGTH characters" do
    long_text = "x" * 50_000
    truncated = long_text[0...EmbeddingService::MAX_INPUT_LENGTH]

    assert_equal EmbeddingService::MAX_INPUT_LENGTH, truncated.length,
      "Input should be truncated to #{EmbeddingService::MAX_INPUT_LENGTH} characters"
  end

  # --- API tests (require VCR cassettes or live OpenAI credentials) ---

  test "embed_text returns 1536-dimension vector array" do
    skip "OpenAI API key not configured" unless Rails.application.credentials.dig(:openai, :api_key).present?

    VCR.use_cassette("embeddings/single_text", record: :new_episodes) do
      vector = @service.embed_text("test content for embedding")
      assert_kind_of Array, vector,
        "embed_text should return an Array"
      assert_equal EmbeddingService::DIMENSIONS, vector.length,
        "embed_text should return a #{EmbeddingService::DIMENSIONS}-dimensional vector"
      assert_kind_of Float, vector.first,
        "embed_text vector elements should be Floats"
    end
  end

  test "embed_batch returns array of vectors with correct dimensions" do
    skip "OpenAI API key not configured" unless Rails.application.credentials.dig(:openai, :api_key).present?

    VCR.use_cassette("embeddings/batch_texts", record: :new_episodes) do
      vectors = @service.embed_batch([ "text one", "text two" ])
      assert_kind_of Array, vectors,
        "embed_batch should return an Array"
      assert_equal 2, vectors.length,
        "embed_batch should return one vector per input text"
      assert_equal EmbeddingService::DIMENSIONS, vectors.first.length,
        "Each vector should have #{EmbeddingService::DIMENSIONS} dimensions"
    end
  end

  test "embed_chunks stores vectors and sets embedding_model on each chunk" do
    skip "OpenAI API key not configured" unless Rails.application.credentials.dig(:openai, :api_key).present?

    VCR.use_cassette("embeddings/embed_chunks", record: :new_episodes) do
      @chunk.update!(embedding_model: nil)

      @service.embed_chunks([ @chunk ])

      @chunk.reload
      assert_equal EmbeddingService::MODEL, @chunk.embedding_model,
        "embed_chunks should set embedding_model to '#{EmbeddingService::MODEL}' on each chunk"

      result = ActiveRecord::Base.connection.execute(
        "SELECT document_chunk_id FROM vec_document_chunks WHERE document_chunk_id = #{@chunk.id}"
      )
      assert_equal 1, result.length,
        "embed_chunks should insert a vector into vec_document_chunks"
    end
  end

  test "embed_text handles nil input by treating it as empty string" do
    skip "OpenAI API key not configured" unless Rails.application.credentials.dig(:openai, :api_key).present?

    VCR.use_cassette("embeddings/nil_text", record: :new_episodes) do
      vector = @service.embed_text(nil)
      assert_kind_of Array, vector,
        "embed_text with nil input should still return an Array"
    end
  end
end
