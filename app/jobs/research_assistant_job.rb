# frozen_string_literal: true

class ResearchAssistantJob < ApplicationJob
  queue_as :default

  def perform(conversation, user_message_content)
    assistant_message = conversation.messages.create!(
      role: "assistant",
      content: "",
      complete: false
    )

    service = ResearchAssistantService.new(conversation: conversation)

    service.answer(user_message_content, assistant_message: assistant_message) do |accumulated_content|
      broadcast_message_update(conversation, assistant_message)
    end
  rescue => e
    if assistant_message&.persisted?
      assistant_message.update!(
        content: "#{assistant_message.content}\n\n---\n*An error occurred while generating a response. Please try again.*",
        complete: true
      )
      broadcast_message_update(conversation, assistant_message)
    end
    Rails.logger.error "[ResearchAssistantJob] Error: #{e.message}\n#{e.backtrace&.first(5)&.join("\n")}"
  end

  private

  def broadcast_message_update(conversation, message)
    Turbo::StreamsChannel.broadcast_replace_to(
      "conversation_#{conversation.id}",
      target: "message_#{message.id}",
      html: Components::Conversations::MessageBubble.new(message: message).call
    )
  end
end
