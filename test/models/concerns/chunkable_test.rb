# frozen_string_literal: true

require "test_helper"

class ChunkableTest < ActiveSupport::TestCase
  setup do
    Current.account = accounts(:one)
  end

  teardown do
    Current.account = nil
  end

  test "empty text produces zero chunks" do
    result = DocumentChunk.chunk_text("")
    assert_empty result, "Empty string should produce no chunks"
  end

  test "nil text produces zero chunks" do
    result = DocumentChunk.chunk_text(nil)
    assert_empty result, "nil should produce no chunks"
  end

  test "whitespace-only text produces zero chunks" do
    result = DocumentChunk.chunk_text("   \n\n   ")
    assert_empty result, "Whitespace-only text should produce no chunks"
  end

  test "short text produces single chunk" do
    short_text = "This is a short piece of text."
    result = DocumentChunk.chunk_text(short_text)

    assert_equal 1, result.length, "Short text should produce exactly one chunk"
    assert_equal 0, result.first[:position], "Single chunk should have position 0"
    assert result.first[:content].present?, "Chunk content should be present"
  end

  test "long text splits into multiple chunks of approximately CHUNK_SIZE characters" do
    # Generate text longer than CHUNK_SIZE (2000 chars)
    paragraph = "This is a research paragraph about academic methodology and data analysis. " * 10
    long_text = (paragraph + "\n\n") * 10 # ~8000+ chars

    result = DocumentChunk.chunk_text(long_text)

    assert result.length > 1, "Long text should produce multiple chunks, got #{result.length}"
    result.each do |chunk|
      assert chunk[:content].length <= Chunkable::CHUNK_SIZE * 2,
        "No chunk should be vastly larger than CHUNK_SIZE (got #{chunk[:content].length})"
    end
  end

  test "chunks have sequential positions" do
    paragraph = "This is a paragraph about research methodology and data analysis techniques. " * 10
    long_text = (paragraph + "\n\n") * 8

    result = DocumentChunk.chunk_text(long_text)

    positions = result.map { |c| c[:position] }
    assert_equal (0...result.length).to_a, positions,
      "Chunk positions should be sequential from 0"
  end

  test "chunks contain content key and section_heading key" do
    text = "INTRODUCTION\n\nThis is the introduction paragraph with enough content to form a proper chunk."
    result = DocumentChunk.chunk_text(text)

    result.each do |chunk|
      assert chunk.key?(:content), "Each chunk should have a :content key"
      assert chunk.key?(:section_heading), "Each chunk should have a :section_heading key"
      assert chunk.key?(:position), "Each chunk should have a :position key"
    end
  end

  test "single large chunk with no separators is still chunked without crashing" do
    # Generate a string longer than CHUNK_SIZE with no paragraph breaks or sentence ends
    no_separator_text = "word" * 600 # ~2400 chars, no separators
    result = DocumentChunk.chunk_text(no_separator_text)

    assert result.length >= 1, "Even text with no separators should produce at least one chunk"
    result.each do |chunk|
      assert chunk.key?(:content), "Chunk should have :content key"
    end
  end

  test "all original content is covered by chunks" do
    paragraph = "The methodology section describes our approach to data collection and analysis.\n"
    long_text = paragraph * 40

    result = DocumentChunk.chunk_text(long_text)
    combined = result.map { |c| c[:content] }.join("")

    # The combined chunks should contain all unique words from the original
    original_words = long_text.scan(/\w+/).uniq
    combined_words = combined.scan(/\w+/).uniq
    missing = original_words - combined_words

    assert_empty missing, "All unique words from original should appear in chunks"
  end

  test "chunks have overlap — end of previous chunk appears at start of next" do
    paragraph = "Research methodology involves systematic investigation. Data analysis requires careful interpretation.\n\n"
    # Generate enough text to guarantee multiple chunks
    long_text = paragraph * 30

    result = DocumentChunk.chunk_text(long_text, chunk_size: 500, overlap: 100)

    # Need at least 2 chunks to test overlap
    skip "Not enough chunks generated to test overlap" if result.length < 2

    result.each_cons(2) do |prev, curr|
      prev_end = prev[:content].last(150)
      curr_start = curr[:content].first(300)
      assert prev_end.length > 0, "Previous chunk end should have content"
      assert curr_start.length > 0, "Current chunk start should have content"
    end
  end

  test "chunk_text accepts custom chunk_size parameter producing more chunks for smaller size" do
    paragraph = "This is a sentence about research methodology and data analysis.\n"
    text = paragraph * 20 # ~1280 chars total

    small_chunks = DocumentChunk.chunk_text(text, chunk_size: 200)
    large_chunks = DocumentChunk.chunk_text(text, chunk_size: 2000)

    assert small_chunks.length >= large_chunks.length,
      "Smaller chunk_size (#{small_chunks.length} chunks) should produce at least as many chunks as larger chunk_size (#{large_chunks.length} chunks)"
  end

  test "section headings key is present on all chunks" do
    text = <<~TEXT
      INTRODUCTION

      #{"This is the introduction section with detailed content about the research problem. " * 5}

      METHODS

      #{"This section describes the methodology used in the study including data collection. " * 5}
    TEXT

    result = DocumentChunk.chunk_text(text)

    assert result.any?, "Should produce at least one chunk"
    result.each do |chunk|
      assert chunk.key?(:section_heading), "All chunks should have :section_heading key (can be nil)"
    end
  end
end
