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
      Turbo::StreamsChannel.broadcast_update_to(
        "conversation_#{conversation.id}",
        target: "message_#{assistant_message.id}",
        html: accumulated_content
      )
    end
  rescue => e
    if assistant_message&.persisted?
      assistant_message.update!(
        content: "#{assistant_message.content}\n\n---\n*Error: #{e.message}*",
        complete: true
      )
      Turbo::StreamsChannel.broadcast_update_to(
        "conversation_#{conversation.id}",
        target: "message_#{assistant_message.id}",
        html: assistant_message.content
      )
    end
    Rails.logger.error "[ResearchAssistantJob] Error: #{e.message}\n#{e.backtrace&.first(5)&.join("\n")}"
  end
end
