# frozen_string_literal: true

class ConversationChannel < ApplicationCable::Channel
  def subscribed
    conversation = Conversation.unscoped
                               .where(account_id: current_user.accounts.select(:id))
                               .find_by(id: params[:conversation_id])

    if conversation
      stream_from "conversation_#{conversation.id}"
    else
      reject
    end
  end
end
