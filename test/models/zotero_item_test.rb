# frozen_string_literal: true

require "test_helper"

class ZoteroItemTest < ActiveSupport::TestCase
  setup do
    Current.account = accounts(:one)
  end

  teardown do
    Current.account = nil
  end

  test "requires account" do
    item = ZoteroItem.new(zotero_key: "NEW123", account: nil)
    assert_not item.valid?
    assert_includes item.errors[:account], "must exist"
  end

  test "requires zotero_key" do
    item = ZoteroItem.new(account: accounts(:one))
    assert_not item.valid?
    assert_includes item.errors[:zotero_key], "can't be blank"
  end

  test "zotero_key uniqueness scoped to account" do
    existing = zotero_items(:one)
    duplicate = ZoteroItem.new(account: existing.account, zotero_key: existing.zotero_key)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:zotero_key], "has already been taken"
  end

  test "same zotero_key allowed in different accounts" do
    other_account = accounts(:three)
    item = ZoteroItem.new(account: other_account, zotero_key: zotero_items(:one).zotero_key)
    assert item.valid?
  end

  test "scoped to current account via AccountScoped" do
    items = ZoteroItem.all
    assert items.all? { |i| i.account_id == accounts(:one).id },
      "All items should belong to the current account"
  end

  test "active scope excludes deleted items" do
    active_items = ZoteroItem.active
    assert_not active_items.include?(zotero_items(:deleted_item)),
      "Active scope should exclude deleted items"
  end

  test "needs_extraction scope returns pending extraction items" do
    items = ZoteroItem.needs_extraction
    assert items.include?(zotero_items(:two))
    assert_not items.include?(zotero_items(:one))
  end

  test "needs_extraction scope includes failed items for retry" do
    item = zotero_items(:two)
    item.update!(extraction_status: "failed")
    assert ZoteroItem.needs_extraction.include?(item),
      "Failed items should be included in needs_extraction for retry"
  end

  test "needs_embedding scope returns pending embedding items" do
    items = ZoteroItem.needs_embedding
    assert items.include?(zotero_items(:two))
    assert_not items.include?(zotero_items(:one))
  end

  test "needs_embedding scope includes failed items for retry" do
    item = zotero_items(:two)
    item.update!(embedding_status: "failed")
    assert ZoteroItem.needs_embedding.include?(item),
      "Failed items should be included in needs_embedding for retry"
  end

  test "has many document_chunks with dependent destroy" do
    item = zotero_items(:one)
    assert item.document_chunks.any?
    chunk_ids = item.document_chunks.pluck(:id)

    item.destroy!
    assert_empty DocumentChunk.unscoped.where(id: chunk_ids)
  end

  test "soft delete via deleted_from_zotero flag" do
    item = zotero_items(:one)
    item.update!(deleted_from_zotero: true)
    assert_not ZoteroItem.active.include?(item)
  end

  test "parsed_authors returns array from valid JSON" do
    item = zotero_items(:one)
    item.update!(authors_json: '[{"firstName": "Jane", "lastName": "Doe"}]')
    assert_equal [ { "firstName" => "Jane", "lastName" => "Doe" } ], item.parsed_authors
  end

  test "parsed_authors returns empty array for nil" do
    item = zotero_items(:one)
    item.update!(authors_json: nil)
    assert_equal [], item.parsed_authors
  end

  test "parsed_authors returns empty array for malformed JSON" do
    item = zotero_items(:one)
    item.update!(authors_json: "not valid json")
    assert_equal [], item.parsed_authors
  end

  test "formatted_authors returns display format by default" do
    item = zotero_items(:one)
    item.update!(authors_json: '[{"firstName": "Jane", "lastName": "Doe"}, {"firstName": "John", "lastName": "Smith"}]')
    assert_equal "Jane Doe, John Smith", item.formatted_authors
  end

  test "formatted_authors returns citation format" do
    item = zotero_items(:one)
    item.update!(authors_json: '[{"firstName": "Jane", "lastName": "Doe"}, {"firstName": "John", "lastName": "Smith"}]')
    assert_equal "Doe, Jane; Smith, John", item.formatted_authors(style: :citation)
  end

  test "formatted_authors handles author with only lastName" do
    item = zotero_items(:one)
    item.update!(authors_json: '[{"lastName": "Aristotle"}]')
    assert_equal "Aristotle", item.formatted_authors(style: :citation)
  end
end
