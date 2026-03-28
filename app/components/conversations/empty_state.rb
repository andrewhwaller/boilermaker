# frozen_string_literal: true

class Components::Conversations::EmptyState < Components::Base
  include Phlex::Rails::Helpers::ButtonTo

  VARIANTS = {
    pre_pipeline: {
      title: "Welcome to Carrel",
      message: "Configure your API keys via `rails credentials:edit`, then trigger a sync to get started.",
      action_label: "Sync Library",
      action_path: :pipeline_path
    },
    pre_embedding: {
      title: "Library synced",
      message: "Your library is synced but not yet indexed. Trigger the pipeline to enable search and Q&A.",
      action_label: "Run Pipeline",
      action_path: :pipeline_path
    },
    ready: {
      title: "Ready to research",
      message: "Your library is indexed. Start a conversation to explore your research.",
      action_label: "New Conversation",
      action_path: :new_conversation_path
    }
  }.freeze

  def initialize(variant: :pre_pipeline)
    @variant = variant
    @config = VARIANTS.fetch(variant)
  end

  def view_template
    div(class: "flex flex-col items-center justify-center py-16 px-8 text-center") do
      h2(class: "text-lg font-semibold mb-3") { @config[:title] }
      p(class: "text-sm text-muted mb-6 max-w-md") { @config[:message] }

      if @variant == :pre_pipeline || @variant == :pre_embedding
        button_to send(@config[:action_path]),
          method: :post,
          class: "ui-button" do
          plain @config[:action_label]
        end
      else
        a(href: send(@config[:action_path]), class: "ui-button") { @config[:action_label] }
      end
    end
  end
end
