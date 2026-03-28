# frozen_string_literal: true

require "test_helper"

class PdfTextExtractorTest < ActiveSupport::TestCase
  SAMPLE_PDF_PATH = Rails.root.join("test/fixtures/files/sample_academic.pdf").to_s

  setup do
    @extractor = PdfTextExtractor.new
  end

  test "extracts text from a well-formed PDF" do
    result = @extractor.extract(SAMPLE_PDF_PATH)

    assert_kind_of Hash, result, "Expected a Hash result"
    assert result[:text].present?, "Expected non-empty text"
    assert_includes result[:text], "introduction", "Expected extracted text to include content"
    assert_includes [ :good, :low_quality ], result[:quality], "Expected quality to be :good or :low_quality"
  end

  test "extracted text includes content from PDF" do
    result = @extractor.extract(SAMPLE_PDF_PATH)

    assert_match(/introduction/i, result[:text], "Extracted text should include introduction section")
    assert_match(/method/i, result[:text], "Extracted text should include methods section")
  end

  test "returns good quality for well-formed text" do
    result = @extractor.extract(SAMPLE_PDF_PATH)

    assert_equal :good, result[:quality], "Well-formed PDF text should be :good quality"
  end

  test "raises ExtractionError for non-existent file" do
    assert_raises(PdfTextExtractor::ExtractionError) do
      @extractor.extract("/nonexistent/path/file.pdf")
    end
  end

  test "raises ExtractionError for empty output (scanned PDF)" do
    # Create a minimal PDF with no extractable text (only images would work in real life,
    # but we can test by writing a valid but text-free PDF)
    Tempfile.create([ "empty_scan", ".pdf" ]) do |file|
      # Write a minimal valid PDF with no text content
      file.write("%PDF-1.4\n1 0 obj<</Type/Catalog/Pages 2 0 R>>endobj\n2 0 obj<</Type/Pages/Kids[3 0 R]/Count 1>>endobj\n3 0 obj<</Type/Page/Parent 2 0 R/MediaBox[0 0 612 792]>>endobj\nxref\n0 4\n0000000000 65535 f \n0000000009 00000 n \n0000000058 00000 n \n0000000115 00000 n \ntrailer<</Size 4/Root 1 0 R>>\nstartxref\n190\n%%EOF")
      file.flush

      assert_raises(PdfTextExtractor::ExtractionError) do
        @extractor.extract(file.path)
      end
    end
  end

  test "assess_quality returns low_quality for high Unicode replacement char density" do
    # Build a string with >5% replacement characters
    normal_text = "a" * 900
    replacement_chars = "\uFFFD" * 100
    garbled_text = normal_text + replacement_chars

    result = @extractor.send(:assess_quality, garbled_text)
    assert_equal :low_quality, result, "High replacement char density should be flagged as low_quality"
  end

  test "assess_quality returns good for normal text" do
    normal_text = "This is a normal research paper with proper English words and sentences." * 20
    result = @extractor.send(:assess_quality, normal_text)
    assert_equal :good, result, "Normal text should be :good quality"
  end

  test "assess_quality returns low_quality for character soup with many short words" do
    # Generate 100+ words all of length 1 (avg < MIN_WORD_LENGTH_AVG of 2.0)
    soup = ([ "a" ] * 120).join(" ")
    result = @extractor.send(:assess_quality, soup)
    assert_equal :low_quality, result, "Character soup with avg word length < 2.0 should be low_quality"
  end

  test "assess_quality skips character soup check when fewer than 100 words" do
    # Short text with single-char words should not be flagged (too short to judge)
    short_soup = ([ "a" ] * 50).join(" ")
    result = @extractor.send(:assess_quality, short_soup)
    # Specifically: no replacement chars, and < 100 words → should be :good
    assert_equal :good, result, "Short text with < 100 words should not trigger character soup check"
  end

  test "raises PdftotextNotFound when pdftotext binary is missing" do
    # Use a simple struct to simulate a failing process status
    failing_status = Struct.new(:success_result) {
      def success?
        success_result
      end
    }.new(false)

    Open3.stub(:capture3, ->(*args) {
      [ "", "", failing_status ]
    }) do
      assert_raises(PdfTextExtractor::PdftotextNotFound) do
        PdfTextExtractor.new
      end
    end
  end
end
