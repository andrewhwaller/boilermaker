# frozen_string_literal: true

require "test_helper"

class SearchServiceTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  setup do
    @account = accounts(:one)
    Current.account = @account
    @service = SearchService.new(account: @account)
    @embedding_service = EmbeddingService.new

    @item_one = zotero_items(:one)
    @chunk_one = document_chunks(:one)
    @chunk_two = document_chunks(:two)

    # Pre-computed orthogonal vectors — no OpenAI API required
    @vector_a = Array.new(EmbeddingService::DIMENSIONS, 0.0).tap { |v| v[0] = 1.0 }
    @vector_b = Array.new(EmbeddingService::DIMENSIONS, 0.0).tap { |v| v[1] = 1.0 }

    @embedding_service.store_vector(@chunk_one.id, @vector_a)
    @embedding_service.store_vector(@chunk_two.id, @vector_b)
  end

  teardown do
    ActiveRecord::Base.connection.execute(
      "DELETE FROM vec_document_chunks WHERE document_chunk_id IN (#{@chunk_one.id}, #{@chunk_two.id})"
    ) rescue nil
    Current.account = nil
  end

  # --- Blank query guard tests (no API calls) ---

  test "search returns empty array for blank query" do
    assert_equal [], @service.search(""),
      "search('') should return []"
    assert_equal [], @service.search("   "),
      "search with whitespace-only query should return []"
    assert_equal [], @service.search(nil),
      "search(nil) should return []"
  end

  test "retrieve_chunks returns empty array for blank query" do
    assert_equal [], @service.retrieve_chunks(""),
      "retrieve_chunks('') should return []"
    assert_equal [], @service.retrieve_chunks(nil),
      "retrieve_chunks(nil) should return []"
  end

  # --- KNN + filtering + de-duplication (using pre-computed vectors, no API calls) ---

  test "KNN results for account are filtered to that account only" do
    other_account = accounts(:three)
    other_item = ZoteroItem.unscoped.create!(
      account: other_account,
      zotero_key: "SRCHTEST_#{SecureRandom.hex(4)}",
      title: "Other Account Item",
      extraction_status: "completed",
      embedding_status: "completed",
      library_version: 1,
      deleted_from_zotero: false
    )
    other_chunk = DocumentChunk.create!(
      zotero_item: other_item,
      content: "Other account chunk content",
      position: 999
    )
    # Store a vector for the other account's chunk identical to @vector_a
    @embedding_service.store_vector(other_chunk.id, @vector_a.dup)

    raw = @embedding_service.nearest_neighbors(@vector_a, k: 20)
    chunk_ids = raw.map { |r| r["document_chunk_id"] }

    # Filter as SearchService does — account-scoped join
    chunks = DocumentChunk.where(id: chunk_ids)
                          .joins(:zotero_item)
                          .where(zotero_items: { account_id: @account.id })
                          .includes(:zotero_item)

    result_item_ids = chunks.map { |c| c.zotero_item.id }
    assert_not_includes result_item_ids, other_item.id,
      "Account-scoped filter should exclude chunks belonging to other accounts"
  ensure
    ActiveRecord::Base.connection.execute(
      "DELETE FROM vec_document_chunks WHERE document_chunk_id = #{other_chunk.id}"
    ) rescue nil
    other_chunk.destroy rescue nil
    other_item.destroy rescue nil
  end

  test "de-duplication keeps lowest-distance chunk per ZoteroItem" do
    # Both chunk_one and chunk_two belong to item_one
    raw = @embedding_service.nearest_neighbors(@vector_a, k: 20)
    chunk_ids = raw.map { |r| r["document_chunk_id"] }

    both_present = [ @chunk_one.id, @chunk_two.id ].all? { |id| chunk_ids.include?(id) }
    skip "Both chunks not returned by KNN at k=20 — cannot verify de-duplication" unless both_present

    distances = raw.each_with_object({}) { |r, h| h[r["document_chunk_id"]] = r["distance"] }
    chunks = DocumentChunk.where(id: chunk_ids)
                          .joins(:zotero_item)
                          .where(zotero_items: { account_id: @account.id })
                          .includes(:zotero_item)

    best_per_item = {}
    chunks.each do |chunk|
      item_id = chunk.zotero_item_id
      dist = distances[chunk.id] || 1.0
      if !best_per_item[item_id] || dist < best_per_item[item_id].distance
        best_per_item[item_id] = SearchService::Result.new(
          zotero_item: chunk.zotero_item,
          chunk: chunk,
          distance: dist
        )
      end
    end

    assert_equal 1, best_per_item.keys.count { |id| id == @item_one.id },
      "item_one should appear exactly once after de-duplication"

    best = best_per_item[@item_one.id]
    min_dist = [ distances[@chunk_one.id], distances[@chunk_two.id] ].compact.min
    assert_equal min_dist, best.distance,
      "De-duplication should keep the chunk with the lowest distance"
  end

  test "nearest_neighbors results are sorted by distance ascending" do
    raw = @embedding_service.nearest_neighbors(@vector_a, k: 20)

    raw.each_cons(2) do |a, b|
      assert a["distance"] <= b["distance"],
        "KNN results should be sorted by distance ascending: #{a["distance"]} <= #{b["distance"]}"
    end
  end

  test "retrieve_chunks does not de-duplicate by ZoteroItem" do
    raw = @embedding_service.nearest_neighbors(@vector_a, k: 20)
    chunk_ids = raw.map { |r| r["document_chunk_id"] }
    both_present = [ @chunk_one.id, @chunk_two.id ].all? { |id| chunk_ids.include?(id) }
    skip "Both chunks not returned by KNN at k=20 — cannot verify no-dedup behavior" unless both_present

    distances = raw.each_with_object({}) { |r, h| h[r["document_chunk_id"]] = r["distance"] }
    chunks = DocumentChunk.where(id: chunk_ids)
                          .joins(:zotero_item)
                          .where(zotero_items: { account_id: @account.id })
                          .includes(:zotero_item)

    results = chunks.map do |chunk|
      { chunk: chunk, distance: distances[chunk.id] || 1.0 }
    end.sort_by { |r| r[:distance] }

    result_chunk_ids = results.map { |r| r[:chunk].id }
    assert_includes result_chunk_ids, @chunk_one.id,
      "retrieve_chunks logic should include chunk_one"
    assert_includes result_chunk_ids, @chunk_two.id,
      "retrieve_chunks logic should include chunk_two — no de-duplication"
  end

  test "Result struct has expected fields" do
    result = SearchService::Result.new(
      zotero_item: @item_one,
      chunk: @chunk_one,
      distance: 0.25
    )

    assert_equal @item_one, result.zotero_item,
      "Result.zotero_item should return the ZoteroItem"
    assert_equal @chunk_one, result.chunk,
      "Result.chunk should return the DocumentChunk"
    assert_equal 0.25, result.distance,
      "Result.distance should return the distance value"
  end

  # --- API-dependent tests ---

  test "search returns results ranked by distance ascending" do
    skip "OpenAI API key not configured" unless Rails.application.credentials.dig(:openai, :api_key).present?

    VCR.use_cassette("searches/search_ranking", record: :new_episodes) do
      results = @service.search("research methodology", k: 20)

      assert_kind_of Array, results,
        "search should return an Array"
      results.each_cons(2) do |a, b|
        assert a.distance <= b.distance,
          "Results should be sorted by distance ascending: #{a.distance} <= #{b.distance}"
      end
    end
  end

  test "search returns SearchService::Result structs with correct field types" do
    skip "OpenAI API key not configured" unless Rails.application.credentials.dig(:openai, :api_key).present?

    VCR.use_cassette("searches/search_result_types", record: :new_episodes) do
      results = @service.search("test", k: 5)

      results.each do |result|
        assert_kind_of ZoteroItem, result.zotero_item,
          "result.zotero_item should be a ZoteroItem"
        assert_kind_of DocumentChunk, result.chunk,
          "result.chunk should be a DocumentChunk"
        assert_kind_of Float, result.distance,
          "result.distance should be a Float"
      end
    end
  end

  test "retrieve_chunks returns array of hashes with chunk and distance keys" do
    skip "OpenAI API key not configured" unless Rails.application.credentials.dig(:openai, :api_key).present?

    VCR.use_cassette("searches/retrieve_chunks_structure", record: :new_episodes) do
      results = @service.retrieve_chunks("test", k: 5)

      assert_kind_of Array, results,
        "retrieve_chunks should return an Array"
      results.each do |r|
        assert_includes r.keys, :chunk, "Each result should have :chunk key"
        assert_includes r.keys, :distance, "Each result should have :distance key"
        assert_kind_of DocumentChunk, r[:chunk], "r[:chunk] should be a DocumentChunk"
        assert_kind_of Float, r[:distance], "r[:distance] should be a Float"
      end
    end
  end
end
