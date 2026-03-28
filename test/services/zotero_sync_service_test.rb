# frozen_string_literal: true

require "test_helper"

class ZoteroSyncServiceTest < ActiveSupport::TestCase
  FAKE_API_KEY = "test_zotero_api_key"
  FAKE_USER_ID = 99999

  setup do
    Current.account = accounts(:one)
    @account = accounts(:one)
    @pipeline_run = pipeline_runs(:running_run)
  end

  teardown do
    Current.account = nil
  end

  # ----- Internal logic tests (no API calls) -----

  test "parse_date returns a Date for valid ISO date string" do
    service = build_service(account: @account)
    result = service.send(:parse_date, "2024-01-15")
    assert_equal Date.new(2024, 1, 15), result
  end

  test "parse_date returns nil for blank string" do
    service = build_service(account: @account)
    assert_nil service.send(:parse_date, "")
    assert_nil service.send(:parse_date, nil)
  end

  test "parse_date returns nil for unparseable string" do
    service = build_service(account: @account)
    assert_nil service.send(:parse_date, "not-a-date")
  end

  test "parse_date handles partial dates gracefully" do
    service = build_service(account: @account)
    # Zotero often stores years only — Ruby's Date.parse("2024") raises ArgumentError
    result = service.send(:parse_date, "2024")
    assert_nil result
  end

  test "upsert_item creates a new ZoteroItem with mapped fields" do
    service = build_service(account: @account)
    Current.account = @account

    item_data = {
      "version" => 200,
      "data" => {
        "key" => "BRAND_NEW",
        "itemType" => "journalArticle",
        "title" => "Brand New Article",
        "creators" => [ { "creatorType" => "author", "firstName" => "Bob", "lastName" => "Author" } ],
        "abstractNote" => "A fresh abstract.",
        "DOI" => "10.5555/brand",
        "url" => "https://brand.example.com",
        "date" => "2025-03-01",
        "tags" => [ { "tag" => "test" } ]
      }
    }

    assert_difference "ZoteroItem.unscoped.count", 1 do
      service.send(:upsert_item, item_data)
    end

    item = ZoteroItem.unscoped.find_by(zotero_key: "BRAND_NEW", account: @account)
    assert_not_nil item, "Expected ZoteroItem to be created"
    assert_equal "journalArticle", item.item_type
    assert_equal "Brand New Article", item.title
    assert_equal "A fresh abstract.", item.abstract
    assert_equal "10.5555/brand", item.doi
    assert_equal "https://brand.example.com", item.url
    assert_equal Date.new(2025, 3, 1), item.publication_date
    assert_equal 200, item.library_version
    assert_equal false, item.deleted_from_zotero

    authors = JSON.parse(item.authors_json)
    assert_equal 1, authors.length
    assert_equal "Author", authors.first["lastName"]

    tags = JSON.parse(item.tags_json)
    assert_equal 1, tags.length
    assert_equal "test", tags.first["tag"]
  end

  test "upsert_item updates an existing ZoteroItem" do
    Current.account = @account
    existing = zotero_items(:one)
    original_title = existing.title

    service = build_service(account: @account)

    item_data = {
      "version" => 999,
      "data" => {
        "key" => existing.zotero_key,
        "itemType" => "journalArticle",
        "title" => "Completely Updated Title",
        "creators" => [],
        "abstractNote" => "New abstract",
        "DOI" => "",
        "url" => "",
        "date" => "",
        "tags" => []
      }
    }

    service.send(:upsert_item, item_data)

    existing.reload
    assert_equal "Completely Updated Title", existing.title
    assert_not_equal original_title, existing.title
    assert_equal 999, existing.library_version
  end

  test "upsert_item skips attachment item types" do
    service = build_service(account: @account)
    Current.account = @account

    item_data = {
      "version" => 100,
      "data" => {
        "key" => "ATTACH1",
        "itemType" => "attachment",
        "title" => "Some PDF"
      }
    }

    assert_no_difference "ZoteroItem.unscoped.count" do
      service.send(:upsert_item, item_data)
    end
  end

  test "upsert_item skips items with missing data" do
    service = build_service(account: @account)

    assert_no_difference "ZoteroItem.unscoped.count" do
      service.send(:upsert_item, { "version" => 100 })
    end
  end

  test "upsert_item increments items_processed on success" do
    service = build_service(account: @account)
    Current.account = @account
    original_count = @pipeline_run.items_processed

    item_data = {
      "version" => 300,
      "data" => {
        "key" => "PROC_TEST",
        "itemType" => "book",
        "title" => "Progress Test Book",
        "creators" => [],
        "abstractNote" => "",
        "DOI" => "",
        "url" => "",
        "date" => "",
        "tags" => []
      }
    }

    service.send(:upsert_item, item_data)
    @pipeline_run.reload
    assert_equal original_count + 1, @pipeline_run.items_processed
  end

  test "upsert_item does not crash on blank key" do
    service = build_service(account: @account)
    Current.account = @account

    item_data = {
      "version" => 100,
      "data" => {
        "key" => "",
        "itemType" => "journalArticle",
        "title" => "Bad Item"
      }
    }

    original_failed = @pipeline_run.items_failed
    assert_nothing_raised { service.send(:upsert_item, item_data) }
    @pipeline_run.reload
    assert_equal original_failed, @pipeline_run.items_failed,
      "items_failed should not increment when item_data has blank key (early return)"
  end

  test "since_version returns maximum library_version for account" do
    service = build_service(account: @account)
    Current.account = @account
    # Fixtures for account :one have library_version 100 and 50
    assert_equal 100, service.send(:since_version)
  end

  test "since_version returns nil when account has no items" do
    Current.account = accounts(:three)
    service = build_service(account: accounts(:three))
    assert_nil service.send(:since_version)
  end

  # ----- VCR-wrapped integration tests -----

  test "full sync creates ZoteroItems with correct metadata" do
    account = accounts(:three)
    Current.account = account
    pipeline_run = PipelineRun.create!(account: account, status: "running", current_stage: "sync")

    VCR.use_cassette("zotero_sync/full_sync", record: :none) do
      service = build_service(account: account, pipeline_run: pipeline_run)
      service.call
    end

    Current.account = account

    newkey1 = ZoteroItem.unscoped.find_by(zotero_key: "NEWKEY1", account: account)
    assert_not_nil newkey1, "Expected NEWKEY1 to be created"
    assert_equal "journalArticle", newkey1.item_type
    assert_equal "Incremental Sync Article", newkey1.title
    assert_equal "Abstract here.", newkey1.abstract
    assert_equal "10.1234/test", newkey1.doi
    assert_equal "https://example.com", newkey1.url
    assert_equal Date.new(2024, 1, 15), newkey1.publication_date
    assert_equal 150, newkey1.library_version
    assert_equal false, newkey1.deleted_from_zotero

    authors = JSON.parse(newkey1.authors_json)
    assert_equal "Researcher", authors.first["lastName"]

    tags = JSON.parse(newkey1.tags_json)
    assert_equal "science", tags.first["tag"]

    newkey2 = ZoteroItem.unscoped.find_by(zotero_key: "NEWKEY2", account: account)
    assert_not_nil newkey2, "Expected NEWKEY2 to be created"
    assert_equal "book", newkey2.item_type
  end

  test "incremental sync uses since parameter and updates existing items" do
    # account :one has items with library_version 100, so since_version == 100
    VCR.use_cassette("zotero_sync/incremental_sync", record: :none) do
      service = build_service(account: @account, pipeline_run: @pipeline_run)
      service.call
    end

    Current.account = @account
    item = ZoteroItem.unscoped.find_by(zotero_key: "ABC123", account: @account)
    assert_equal "Updated Article Title", item.title
    assert_equal "10.9999/updated", item.doi
    assert_equal 150, item.library_version
  end

  test "deleted items are soft-deleted" do
    # ABC123 is in the deleted list in this cassette
    Current.account = @account
    assert_equal false, zotero_items(:one).deleted_from_zotero, "Precondition: item not yet deleted"

    VCR.use_cassette("zotero_sync/deleted_items", record: :none) do
      service = build_service(account: @account, pipeline_run: @pipeline_run)
      service.call
    end

    Current.account = @account
    assert_equal true, ZoteroItem.unscoped.find_by(zotero_key: "ABC123", account: @account).deleted_from_zotero
    # DEF456 is not in the deleted list, so it should remain active
    assert_equal false, ZoteroItem.unscoped.find_by(zotero_key: "DEF456", account: @account).deleted_from_zotero
  end

  test "empty library sync completes without error" do
    account = accounts(:three)
    Current.account = account
    pipeline_run = PipelineRun.create!(account: account, status: "running", current_stage: "sync")

    VCR.use_cassette("zotero_sync/empty_library", record: :none) do
      service = build_service(account: account, pipeline_run: pipeline_run)
      assert_nothing_raised { service.call }
    end
  end

  test "mid-sync failure preserves previously synced items" do
    # Pre-create one item as if it was synced in a prior pass
    account = accounts(:three)
    Current.account = account
    pipeline_run = PipelineRun.create!(account: account, status: "running", current_stage: "sync")

    ZoteroItem.create!(
      account: account,
      zotero_key: "PRESERVED",
      item_type: "journalArticle",
      title: "Preserved Item",
      extraction_status: "pending",
      embedding_status: "pending",
      deleted_from_zotero: false
    )

    service = build_service(account: account, pipeline_run: pipeline_run)

    # Stub sync_items to be a no-op (avoids real API call),
    # then stub sync_deletions to raise mid-pipeline.
    service.stub(:sync_items, -> {}) do
      service.stub(:sync_deletions, -> { raise ZoteroSyncService::SyncError, "mid-sync failure" }) do
        assert_raises(ZoteroSyncService::SyncError) { service.call }
      end
    end

    # The pre-existing item should survive the failure
    Current.account = account
    assert ZoteroItem.unscoped.exists?(zotero_key: "PRESERVED", account: account),
      "Previously synced item should be preserved after mid-sync failure"
  end

  private

  def build_service(account:, pipeline_run: nil)
    pipeline_run ||= @pipeline_run
    ZoteroSyncService.new(
      account: account,
      pipeline_run: pipeline_run,
      api_key: FAKE_API_KEY,
      user_id: FAKE_USER_ID
    )
  end
end
