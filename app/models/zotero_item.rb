# frozen_string_literal: true

class ZoteroItem < ApplicationRecord
  include AccountScoped
  include Hashid::Rails

  has_many :document_chunks, dependent: :destroy
  has_one_attached :pdf

  validates :zotero_key, presence: true, uniqueness: { scope: :account_id }

  scope :active, -> { where(deleted_from_zotero: false) }
  scope :needs_extraction, -> { active.where(extraction_status: "pending") }
  scope :needs_embedding, -> { active.where(embedding_status: "pending") }

  enum :extraction_status, { pending: "pending", completed: "completed", failed: "failed", low_quality: "low_quality" }, prefix: true
  enum :embedding_status, { pending: "pending", completed: "completed", failed: "failed" }, prefix: true
end
