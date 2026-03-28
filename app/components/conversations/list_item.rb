# frozen_string_literal: true

class Components::Conversations::ListItem < Components::Base
  include Phlex::Rails::Helpers::LinkTo
  include ActionView::Helpers::DateHelper

  def initialize(conversation:, current: false)
    @conversation = conversation
    @current = current
  end

  def view_template
    link_to conversation_path(@conversation),
      class: item_classes do
      div(class: "truncate text-sm") { plain @conversation.title || "Untitled" }
      div(class: "text-xs text-muted") do
        plain time_ago_in_words(@conversation.updated_at) + " ago"
      end
    end
  end

  private

  def item_classes
    base = "ui-conversation-list-item block p-3 rounded hover:bg-surface-raised transition-colors"
    @current ? "#{base} bg-surface-raised" : base
  end
end
