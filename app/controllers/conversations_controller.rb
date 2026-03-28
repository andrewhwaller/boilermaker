# frozen_string_literal: true

class ConversationsController < ApplicationController
  def index
    @conversations = Current.account.conversations.order(updated_at: :desc)
    @empty_state_variant = Current.account.conversation_empty_state_variant
    render Views::Conversations::Index.new(conversations: @conversations, empty_state_variant: @empty_state_variant)
  end

  def show
    @conversation = Current.account.conversations.find(params[:id])
    @messages = @conversation.messages.includes(:message_sources)
    render Views::Conversations::Show.new(conversation: @conversation, messages: @messages)
  end

  def new
    render Views::Conversations::New.new
  end

  def create
    content = params[:content].to_s.strip
    title = params[:title].presence || content.truncate(50).presence || "New conversation"

    @conversation = Current.account.conversations.create!(title: title)

    if content.present?
      @conversation.messages.create!(role: "user", content: content, complete: true)
      @conversation.touch
      ResearchAssistantJob.perform_later(@conversation, content)
    end

    redirect_to @conversation
  end

  def destroy
    conversation = Current.account.conversations.find(params[:id])
    conversation.destroy!
    redirect_to conversations_path, notice: "Conversation deleted."
  end
end
