# frozen_string_literal: true

class ConversationChannel < ApplicationCable::Channel
  def subscribed
    conversation = Conversation.unscoped.find_by(id: params[:conversation_id])

    if conversation && user_owns_conversation?(conversation)
      stream_from "conversation_#{conversation.id}"
    else
      reject
    end
  end

  private

  def user_owns_conversation?(conversation)
    current_user.accounts.pluck(:id).include?(conversation.account_id)
  end
end
