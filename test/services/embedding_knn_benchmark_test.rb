# frozen_string_literal: true

require "test_helper"

# KNN performance validation for sqlite-vec at scale.
# Gate this behind RUN_KNN_BENCHMARK=1 since it inserts 100K vectors and takes minutes.
#
# Usage: RUN_KNN_BENCHMARK=1 bin/rails test test/services/embedding_knn_benchmark_test.rb
class EmbeddingKnnBenchmarkTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  VECTOR_COUNT = 100_000
  DIMENSIONS = 1536
  MAX_QUERY_TIME_MS = 200

  test "KNN query at 100K vectors completes within acceptable latency" do
    skip "KNN benchmark: set RUN_KNN_BENCHMARK=1 to run (inserts 100K vectors, takes minutes)" unless ENV["RUN_KNN_BENCHMARK"]

    conn = ActiveRecord::Base.connection

    conn.execute(
      "CREATE VIRTUAL TABLE IF NOT EXISTS vec_benchmark USING vec0(id integer primary key, embedding float[#{DIMENSIONS}] distance_metric=cosine)"
    )

    puts "\nInserting #{VECTOR_COUNT} synthetic vectors (#{DIMENSIONS} dims)..."

    VECTOR_COUNT.times.each_slice(1000) do |batch|
      values = batch.map do |i|
        vec = Array.new(DIMENSIONS) { rand(-1.0..1.0) }
        "(#{i}, '#{vec.to_json}')"
      end.join(",")
      conn.execute("INSERT INTO vec_benchmark(id, embedding) VALUES #{values}")
      print "." if batch.first % 10_000 == 0
    end

    puts "\n#{VECTOR_COUNT} vectors inserted. Running KNN query..."

    query = Array.new(DIMENSIONS) { rand(-1.0..1.0) }
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    results = conn.execute(
      "SELECT id, distance FROM vec_benchmark WHERE embedding MATCH '#{query.to_json}' AND k = 20"
    )
    elapsed_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start) * 1000).round(2)

    puts "KNN query time: #{elapsed_ms}ms (threshold: #{MAX_QUERY_TIME_MS}ms)"
    puts "Results: #{results.length} neighbors returned"

    assert_equal 20, results.length,
      "Expected 20 results from KNN query, got #{results.length}"
    assert elapsed_ms < MAX_QUERY_TIME_MS,
      "KNN query took #{elapsed_ms}ms, which exceeds the #{MAX_QUERY_TIME_MS}ms threshold. " \
      "Consider reducing embedding dimensions via Matryoshka truncation."
  ensure
    conn&.execute("DROP TABLE IF EXISTS vec_benchmark") rescue nil
  end
end
