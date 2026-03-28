# frozen_string_literal: true

class Views::Conversations::Show < Views::Base
  include Phlex::Rails::Helpers::ButtonTo
  include Phlex::Rails::Helpers::TurboStreamFrom

  def initialize(conversation:, messages: [])
    @conversation = conversation
    @messages = messages
  end

  def view_template
    page_with_title(@conversation.title) do
      div(
        class: "flex flex-col h-[calc(100vh-8rem)]",
        data: { controller: "chat", chat_conversation_id_value: @conversation.hashid }
      ) do
        conversation_header
        message_list
        typing_indicator
        message_form
      end
    end
  end

  private

  def conversation_header
    div(class: "flex items-center justify-between mb-4 pb-4 border-b border-line-muted flex-shrink-0") do
      h2(class: "font-semibold text-body truncate") { plain @conversation.title }
      button_to conversation_path(@conversation),
        method: :delete,
        class: "ui-button ui-button-ghost ui-button-sm text-destructive hover:bg-destructive/10",
        data: { turbo_confirm: "Delete this conversation? This cannot be undone." } do
        plain "Delete"
      end
    end
  end

  def message_list
    div(
      id: "messages",
      class: "flex-1 overflow-y-auto space-y-4 pb-4",
      data: { chat_target: "messages" }
    ) do
      turbo_stream_from "conversation_#{@conversation.id}"

      if @messages.any?
        @messages.each do |message|
          render Components::Conversations::MessageBubble.new(message: message)
        end
      else
        div(class: "text-center py-12 text-muted") do
          p { "Start the conversation by asking a question below." }
        end
      end
    end
  end

  def typing_indicator
    div(
      id: "typing_indicator",
      class: "hidden flex-shrink-0 py-2 px-4",
      data: { chat_target: "typingIndicator" }
    ) do
      div(class: "flex items-center gap-1") do
        div(class: "w-1.5 h-1.5 rounded-full bg-muted animate-bounce")
        div(class: "w-1.5 h-1.5 rounded-full bg-muted animate-bounce [animation-delay:0.15s]")
        div(class: "w-1.5 h-1.5 rounded-full bg-muted animate-bounce [animation-delay:0.3s]")
      end
    end
  end

  def message_form
    div(class: "flex-shrink-0 pt-4 border-t border-line-muted") do
      form_with(
        url: conversation_messages_path(@conversation),
        method: :post,
        data: {
          controller: "keyboard",
          chat_target: "form",
          keyboard_new_conversation_url_value: new_conversation_path,
          action: "submit->chat#submit"
        }
      ) do |f|
        div(class: "flex gap-2 items-end") do
          f.text_area :content,
            placeholder: streaming? ? "Waiting for response..." : "Ask a question about your library...",
            rows: 1,
            autofocus: true,
            disabled: streaming?,
            class: "ui-input flex-1 resize-none min-h-[2.5rem] max-h-32 overflow-y-auto",
            data: {
              chat_target: "input",
              keyboard_target: "textarea",
              action: "keydown->keyboard#textareaKeydown"
            }

          f.submit streaming? ? "Thinking..." : "Send",
            disabled: streaming?,
            class: "ui-button ui-button-sm flex-shrink-0 self-end",
            data: { chat_target: "submit" }
        end
      end
    end
  end

  def streaming?
    @messages.any? { |m| m.role == "assistant" && !m.complete? }
  end
end
