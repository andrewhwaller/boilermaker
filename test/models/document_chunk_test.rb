# frozen_string_literal: true

require "test_helper"

class DocumentChunkTest < ActiveSupport::TestCase
  setup do
    Current.account = accounts(:one)
  end

  teardown do
    Current.account = nil
  end

  test "requires zotero_item" do
    chunk = DocumentChunk.new(content: "test", position: 0)
    assert_not chunk.valid?
    assert_includes chunk.errors[:zotero_item], "must exist"
  end

  test "requires content" do
    chunk = DocumentChunk.new(zotero_item: zotero_items(:one), position: 0)
    assert_not chunk.valid?
    assert_includes chunk.errors[:content], "can't be blank"
  end

  test "requires position" do
    chunk = DocumentChunk.new(zotero_item: zotero_items(:one), content: "test")
    assert_not chunk.valid?
    assert_includes chunk.errors[:position], "can't be blank"
  end

  test "default scope orders by position" do
    item = zotero_items(:one)
    chunks = item.document_chunks
    assert_equal chunks.map(&:position), chunks.map(&:position).sort
  end

  test "belongs to zotero_item" do
    chunk = document_chunks(:one)
    assert_equal zotero_items(:one), chunk.zotero_item
  end
end
