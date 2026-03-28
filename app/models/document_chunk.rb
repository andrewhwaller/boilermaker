# frozen_string_literal: true

class DocumentChunk < ApplicationRecord
  include Chunkable

  belongs_to :zotero_item
  has_many :message_sources, dependent: :destroy

  validates :content, presence: true
  validates :position, presence: true

  default_scope { order(:position) }
end
