# frozen_string_literal: true

class ZoteroItem < ApplicationRecord
  include AccountScoped
  include Hashid::Rails

  has_many :document_chunks, dependent: :destroy
  has_one_attached :pdf

  validates :zotero_key, presence: true, uniqueness: { scope: :account_id }

  scope :active, -> { where(deleted_from_zotero: false) }
  scope :needs_extraction, -> { active.where(extraction_status: %w[pending failed]) }
  scope :needs_embedding, -> { active.where(embedding_status: %w[pending failed]) }

  enum :extraction_status, { pending: "pending", completed: "completed", failed: "failed", low_quality: "low_quality" }, prefix: true
  enum :embedding_status, { pending: "pending", completed: "completed", failed: "failed" }, prefix: true

  def parsed_authors
    return [] unless authors_json.present?

    JSON.parse(authors_json)
  rescue JSON::ParserError
    []
  end

  def formatted_authors(style: :display)
    authors = parsed_authors
    case style
    when :citation
      authors.map { |a| [ a["lastName"], a["firstName"] ].compact.join(", ") }.join("; ")
    else
      authors.map { |a| [ a["firstName"], a["lastName"] ].compact.join(" ") }.join(", ")
    end
  end
end
