# frozen_string_literal: true

require "zotero"
require "net/http"
require "uri"
require "tempfile"

class ZoteroSyncService
  class SyncError < StandardError; end

  ITEMS_PER_PAGE = 100
  ZOTERO_BASE_URI = "https://api.zotero.org"

  def initialize(account:, pipeline_run:, api_key: nil, user_id: nil)
    @account = account
    @pipeline_run = pipeline_run
    @api_key = api_key || Rails.application.credentials.dig(:zotero, :api_key)
    @user_id = user_id || Rails.application.credentials.dig(:zotero, :user_id)
  end

  def call
    Current.account = account
    sync_items
    sync_deletions
    download_attachments
  end

  private

  attr_reader :account, :pipeline_run, :api_key, :user_id

  def library
    @library ||= begin
      client = Zotero::Client.new(api_key: api_key)
      client.user_library(user_id)
    end
  end

  def since_version
    @since_version = ZoteroItem.maximum(:library_version) unless defined?(@since_version)
    @since_version
  end

  MAX_PAGES = 1000

  def sync_items
    start = 0
    pages = 0

    loop do
      params = { limit: ITEMS_PER_PAGE, start: start }
      params[:since] = since_version if since_version

      items = library.items(**params)
      break if items.blank?

      items.each { |item_data| upsert_item(item_data) }

      start += items.length
      pages += 1
      break if items.length < ITEMS_PER_PAGE
      break if pages >= MAX_PAGES
    end
  end

  def upsert_item(item_data)
    data = item_data["data"]
    return unless data
    return if data["itemType"] == "attachment"

    key = data["key"]
    return if key.blank?

    item = ZoteroItem.find_or_initialize_by(zotero_key: key, account: account)
    item.item_type = data["itemType"]
    item.title = data["title"]
    item.authors_json = data["creators"]&.to_json
    item.abstract = data["abstractNote"]
    item.doi = data["DOI"]
    item.url = data["url"]
    item.publication_date = parse_date(data["date"])
    item.tags_json = data["tags"]&.to_json
    item.library_version = item_data["version"]
    item.deleted_from_zotero = false

    item.save!

    pipeline_run.increment!(:items_processed)
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("ZoteroSyncService: Failed to upsert item #{key}: #{e.message}")
    pipeline_run.increment!(:items_failed)
  end

  def sync_deletions
    return if since_version.nil?

    deletions = library.deleted_items(since: since_version)
    return unless deletions.is_a?(Hash)

    deleted_keys = deletions["items"] || []
    return if deleted_keys.empty?

    ZoteroItem.where(zotero_key: deleted_keys, account: account)
              .update_all(deleted_from_zotero: true)
  end

  def download_attachments
    ZoteroItem.active.where(account: account).find_each do |item|
      next if item.pdf.attached?

      attach_pdf_for_item(item)
    end
  end

  def attach_pdf_for_item(item)
    children = library.items(itemKey: item.zotero_key)
    pdf_child = Array(children).find do |child|
      child.dig("data", "contentType") == "application/pdf"
    end

    return unless pdf_child

    attachment_key = pdf_child.dig("data", "key")
    filename = ActiveStorage::Filename.new(pdf_child.dig("data", "filename") || "attachment.pdf").sanitized
    download_and_attach_pdf(item, attachment_key, filename)
  rescue StandardError => e
    Rails.logger.error("ZoteroSyncService: Failed to fetch children for item #{item.zotero_key}: #{e.message}")
  end

  def download_and_attach_pdf(item, attachment_key, filename)
    file_uri = URI("#{ZOTERO_BASE_URI}/users/#{user_id}/items/#{attachment_key}/file")
    response = fetch_binary(file_uri)

    return unless response.is_a?(Net::HTTPSuccess)

    Tempfile.open([ "zotero_pdf", ".pdf" ], binmode: true) do |tmp|
      tmp.write(response.body)
      tmp.rewind
      item.pdf.attach(io: tmp, filename: filename, content_type: "application/pdf")
    end
  rescue StandardError => e
    Rails.logger.error("ZoteroSyncService: Failed to download PDF for item #{item.zotero_key}: #{e.message}")
  end

  MAX_REDIRECTS = 5

  def fetch_binary(uri, redirects = 0)
    raise SyncError, "Too many redirects" if redirects > MAX_REDIRECTS

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    http.open_timeout = 15
    http.read_timeout = 60

    request = Net::HTTP::Get.new(uri)
    request["Zotero-API-Key"] = api_key unless redirects > 0
    request["Zotero-API-Version"] = "3" unless redirects > 0

    response = http.request(request)

    if response.is_a?(Net::HTTPRedirection) && response["location"]
      fetch_binary(URI(response["location"]), redirects + 1)
    else
      response
    end
  end

  def parse_date(date_string)
    return nil if date_string.blank?

    Date.parse(date_string)
  rescue Date::Error, ArgumentError
    nil
  end
end
