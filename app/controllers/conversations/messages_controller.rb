# frozen_string_literal: true

module Conversations
  class MessagesController < ApplicationController
    def create
      @conversation = Current.account.conversations.find(params[:conversation_id])

      content = params[:content].to_s.strip
      return redirect_to(@conversation) if content.blank?

      @conversation.messages.create!(role: "user", content: content, complete: true)

      if @conversation.title == "New conversation" && @conversation.messages.where(role: "user").count == 1
        @conversation.update!(title: content.truncate(50))
      end

      @conversation.touch

      ResearchAssistantJob.perform_later(@conversation, content)

      redirect_to @conversation
    end
  end
end
