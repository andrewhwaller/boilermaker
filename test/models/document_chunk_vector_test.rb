# frozen_string_literal: true

require "test_helper"

class DocumentChunkVectorTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  setup do
    Current.account = accounts(:one)
    # Ensure vec_document_chunks virtual table exists (not in schema.rb because
    # Rails cannot dump vec0 virtual tables; must be created explicitly in tests).
    conn = ActiveRecord::Base.connection
    unless conn.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='vec_document_chunks'").any?
      conn.execute(<<~SQL)
        CREATE VIRTUAL TABLE vec_document_chunks USING vec0(
          document_chunk_id integer primary key,
          embedding float[1536] distance_metric=cosine
        )
      SQL
    end
    @item = zotero_items(:one)
    @chunk = DocumentChunk.create!(
      zotero_item: @item,
      content: "Vector test chunk",
      position: 99,
      embedding_model: "text-embedding-3-small"
    )
    # Insert a test vector
    embedding = Array.new(1536) { rand(-1.0..1.0) }
    conn.execute(
      "INSERT INTO vec_document_chunks(document_chunk_id, embedding) VALUES (#{@chunk.id}, '#{embedding.to_json}')"
    )
  end

  teardown do
    conn = ActiveRecord::Base.connection
    # Clean up vec0 table (not rolled back by transactions)
    conn.execute(
      "DELETE FROM vec_document_chunks WHERE document_chunk_id = #{@chunk.id}"
    ) rescue nil
    @chunk&.destroy
    Current.account = nil
  end

  test "vector insert and KNN query returns results" do
    query_vector = Array.new(1536) { rand(-1.0..1.0) }
    results = ActiveRecord::Base.connection.execute(
      "SELECT document_chunk_id, distance FROM vec_document_chunks WHERE embedding MATCH '#{query_vector.to_json}' AND k = 5"
    )
    assert results.any?, "KNN query should return at least one result"
    assert_includes results.map { |r| r["document_chunk_id"] }, @chunk.id
  end
end
