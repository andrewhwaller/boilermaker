# frozen_string_literal: true

class MessageSource < ApplicationRecord
  belongs_to :message
  belongs_to :document_chunk

  validates :document_chunk_id, uniqueness: { scope: :message_id }
end
