# frozen_string_literal: true

require "test_helper"

class ExtractAndChunkJobTest < ActiveSupport::TestCase
  SAMPLE_PDF_PATH = Rails.root.join("test/fixtures/files/sample_academic.pdf")

  setup do
    Current.account = accounts(:one)
    @account = accounts(:one)
    @item = zotero_items(:two) # pending extraction, no PDF attached yet
  end

  teardown do
    Current.account = nil
  end

  test "job is enqueued to default queue" do
    assert_equal "default", ExtractAndChunkJob.queue_name
  end

  test "sets extraction_status to failed when no PDF is attached" do
    assert_not @item.pdf.attached?, "Fixture item should not have a PDF attached"

    ExtractAndChunkJob.new.perform(@item)

    @item.reload
    assert_equal "failed", @item.extraction_status,
      "extraction_status should be 'failed' when no PDF is attached"
  end

  test "sets full_text to nil when no PDF is attached" do
    ExtractAndChunkJob.new.perform(@item)

    @item.reload
    assert_nil @item.full_text, "full_text should be nil when no PDF is attached"
  end

  test "extracts text and creates document chunks from attached PDF" do
    @item.pdf.attach(
      io: File.open(SAMPLE_PDF_PATH),
      filename: "sample_academic.pdf",
      content_type: "application/pdf"
    )

    # Clear any existing chunks
    @item.document_chunks.destroy_all

    ExtractAndChunkJob.new.perform(@item)

    @item.reload
    assert @item.document_chunks.any?,
      "Document chunks should be created after successful extraction"
  end

  test "sets extraction_status to completed on successful extraction" do
    @item.pdf.attach(
      io: File.open(SAMPLE_PDF_PATH),
      filename: "sample_academic.pdf",
      content_type: "application/pdf"
    )
    @item.document_chunks.destroy_all

    ExtractAndChunkJob.new.perform(@item)

    @item.reload
    assert_includes [ "completed", "low_quality" ], @item.extraction_status,
      "extraction_status should be completed or low_quality after successful extraction"
  end

  test "stores full_text on zotero_item after extraction" do
    @item.pdf.attach(
      io: File.open(SAMPLE_PDF_PATH),
      filename: "sample_academic.pdf",
      content_type: "application/pdf"
    )
    @item.document_chunks.destroy_all

    ExtractAndChunkJob.new.perform(@item)

    @item.reload
    assert @item.full_text.present?,
      "full_text should be stored on the ZoteroItem after extraction"
    assert_match(/introduction|method/i, @item.full_text,
      "full_text should contain content from the PDF")
  end

  test "creates document chunks with sequential positions" do
    # Use a PDF that will produce enough text for at least one chunk
    @item.pdf.attach(
      io: File.open(SAMPLE_PDF_PATH),
      filename: "sample_academic.pdf",
      content_type: "application/pdf"
    )
    @item.document_chunks.destroy_all

    ExtractAndChunkJob.new.perform(@item)

    @item.reload
    chunks = @item.document_chunks.order(:position)
    positions = chunks.map(&:position)

    assert positions == positions.sort,
      "Document chunk positions should be in order"
    assert positions.first == 0 || positions.empty?,
      "First chunk should have position 0"
  end

  test "resets embedding_status to pending after re-extraction" do
    @item.pdf.attach(
      io: File.open(SAMPLE_PDF_PATH),
      filename: "sample_academic.pdf",
      content_type: "application/pdf"
    )
    # Simulate a previously completed embedding
    @item.update!(embedding_status: :completed)

    ExtractAndChunkJob.new.perform(@item)

    @item.reload
    assert_equal "pending", @item.embedding_status,
      "embedding_status should be reset to pending after re-extraction"
  end

  test "destroys existing chunks before creating new ones" do
    @item.pdf.attach(
      io: File.open(SAMPLE_PDF_PATH),
      filename: "sample_academic.pdf",
      content_type: "application/pdf"
    )

    # Run extraction twice to test idempotency
    ExtractAndChunkJob.new.perform(@item)
    first_count = @item.document_chunks.count

    ExtractAndChunkJob.new.perform(@item)
    second_count = @item.document_chunks.count

    assert_equal first_count, second_count,
      "Re-extraction should produce the same number of chunks, not accumulate duplicates"
  end

  test "sets extraction_status to failed when PdfTextExtractor raises ExtractionError" do
    @item.pdf.attach(
      io: File.open(SAMPLE_PDF_PATH),
      filename: "sample_academic.pdf",
      content_type: "application/pdf"
    )

    PdfTextExtractor.stub(:new, -> {
      extractor = Object.new
      def extractor.extract(_path)
        raise PdfTextExtractor::ExtractionError, "pdftotext produced empty output (likely scanned/image-only PDF)"
      end
      extractor
    }) do
      ExtractAndChunkJob.new.perform(@item)
    end

    @item.reload
    assert_equal "failed", @item.extraction_status,
      "extraction_status should be failed when ExtractionError is raised"
  end

  test "each created chunk belongs to the correct zotero_item" do
    @item.pdf.attach(
      io: File.open(SAMPLE_PDF_PATH),
      filename: "sample_academic.pdf",
      content_type: "application/pdf"
    )
    @item.document_chunks.destroy_all

    ExtractAndChunkJob.new.perform(@item)

    @item.document_chunks.each do |chunk|
      assert_equal @item.id, chunk.zotero_item_id,
        "Each chunk should belong to the correct ZoteroItem"
    end
  end
end
