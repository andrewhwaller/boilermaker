# frozen_string_literal: true

class Views::Conversations::Index < Views::Base
  def initialize(conversations: [], empty_state_variant: :pre_pipeline)
    @conversations = conversations
    @empty_state_variant = empty_state_variant
  end

  def view_template
    page_with_title("Conversations") do
      div(class: "max-w-3xl mx-auto space-y-4") do
        div(class: "flex justify-between items-center") do
          h2(class: "text-lg font-semibold") { "Conversations" }
          a(href: new_conversation_path, class: "ui-button ui-button-sm") { "New Conversation" }
        end

        if @conversations.any?
          div(class: "space-y-1") do
            @conversations.each do |convo|
              render Components::Conversations::ListItem.new(conversation: convo)
            end
          end
        else
          render Components::Conversations::EmptyState.new(variant: @empty_state_variant)
        end
      end
    end
  end
end
