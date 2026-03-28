# frozen_string_literal: true

class Conversation < ApplicationRecord
  include AccountScoped
  include Hashid::Rails

  has_many :messages, dependent: :destroy

  validates :title, presence: true
end
