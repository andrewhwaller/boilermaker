# frozen_string_literal: true

class EmbeddingService
  MODEL = "text-embedding-3-small"
  DIMENSIONS = 1536
  BATCH_SIZE = 50
  MAX_INPUT_LENGTH = 30_000 # ~8000 tokens, well within model limits

  class EmbeddingError < StandardError; end

  def embed_text(text)
    truncated = text.to_s[0...MAX_INPUT_LENGTH]
    result = RubyLLM.embed(truncated, model: MODEL)
    result.vectors
  end

  def embed_batch(texts)
    truncated = texts.map { |t| t.to_s[0...MAX_INPUT_LENGTH] }
    result = RubyLLM.embed(truncated, model: MODEL)
    result.vectors
  end

  def embed_chunks(chunks)
    chunks.each_slice(BATCH_SIZE) do |batch|
      texts = batch.map(&:content)
      vectors = embed_batch(texts)

      batch.zip(vectors).each do |chunk, vector|
        store_vector(chunk.id, vector)
        chunk.update!(embedding_model: MODEL)
      end
    end
  end

  def store_vector(chunk_id, vector)
    conn = ActiveRecord::Base.connection
    # Delete existing vector if any (for re-embedding)
    conn.execute("DELETE FROM vec_document_chunks WHERE document_chunk_id = #{chunk_id.to_i}")
    conn.execute("INSERT INTO vec_document_chunks(document_chunk_id, embedding) VALUES (#{chunk_id.to_i}, #{conn.quote(vector.to_json)})")
  end

  def delete_vectors(chunk_ids)
    return if chunk_ids.empty?

    conn = ActiveRecord::Base.connection
    sanitized_ids = chunk_ids.map(&:to_i).join(",")
    conn.execute("DELETE FROM vec_document_chunks WHERE document_chunk_id IN (#{sanitized_ids})")
  end

  def nearest_neighbors(query_vector, k: 20)
    conn = ActiveRecord::Base.connection
    results = conn.execute(
      "SELECT document_chunk_id, distance FROM vec_document_chunks WHERE embedding MATCH #{conn.quote(query_vector.to_json)} AND k = #{k.to_i}"
    )
    results.to_a
  end
end
