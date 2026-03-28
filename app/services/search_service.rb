# frozen_string_literal: true

class SearchService
  DEFAULT_K = 20

  Result = Struct.new(:zotero_item, :chunk, :distance, keyword_init: true)

  def initialize(account:)
    @account = account
    @embedding_service = EmbeddingService.new
  end

  def search(query, k: DEFAULT_K)
    ranked = fetch_ranked_chunks(query, k: k)
    return [] if ranked.empty?

    best_per_item = {}
    ranked.each do |entry|
      chunk = entry[:chunk]
      dist = entry[:distance]
      item_id = chunk.zotero_item_id

      if !best_per_item[item_id] || dist < best_per_item[item_id].distance
        best_per_item[item_id] = Result.new(
          zotero_item: chunk.zotero_item,
          chunk: chunk,
          distance: dist
        )
      end
    end

    best_per_item.values.sort_by(&:distance)
  end

  def retrieve_chunks(query, k: DEFAULT_K)
    fetch_ranked_chunks(query, k: k)
  end

  private

  def fetch_ranked_chunks(query, k:)
    return [] if query.blank?

    query_vector = @embedding_service.embed_text(query)

    raw_results = @embedding_service.nearest_neighbors(query_vector, k: k)
    return [] if raw_results.empty?

    chunk_ids = raw_results.map { |r| r["document_chunk_id"] }
    chunks = DocumentChunk.where(id: chunk_ids)
                          .joins(:zotero_item)
                          .where(zotero_items: { account_id: @account.id })
                          .includes(:zotero_item)

    distances = raw_results.each_with_object({}) do |r, h|
      h[r["document_chunk_id"].to_i] = r["distance"].to_f
    end

    chunks.map do |chunk|
      { chunk: chunk, distance: distances[chunk.id] || 1.0 }
    end.sort_by { |r| r[:distance] }
  end
end
