# frozen_string_literal: true

require "test_helper"

module Conversations
  class MessagesControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = users(:app_admin)
      @account = accounts(:one)
      sign_in_as(@user, @account)
      @conversation = conversations(:one)
    end

    test "create saves user message and redirects to conversation" do
      content = "What is the methodology?"
      existing_message_ids = Message.pluck(:id)

      assert_difference("Message.count", 1) do
        post conversation_messages_path(@conversation), params: { content: content }
      end
      assert_redirected_to conversation_path(@conversation),
        "Should redirect to conversation after creating message"

      new_message = Message.where.not(id: existing_message_ids).first
      assert_not_nil new_message, "A new message should have been created"
      assert_equal content, new_message.content,
        "The newly created message should have the submitted content"
      assert_equal "user", new_message.role, "Created message should have role 'user'"
      assert new_message.complete?, "User message should be marked complete"
    end

    test "create enqueues ResearchAssistantJob" do
      assert_enqueued_with(job: ResearchAssistantJob) do
        post conversation_messages_path(@conversation), params: { content: "Some research question" }
      end
    end

    test "create auto-titles conversation from first user message when title is default" do
      fresh_conversation = @account.conversations.create!(title: "New conversation")

      long_content = "A" * 60
      post conversation_messages_path(fresh_conversation), params: { content: long_content }
      fresh_conversation.reload

      assert_equal long_content.truncate(50), fresh_conversation.title,
        "Auto-title should be first 50 chars of first user message"
    end

    test "create does not overwrite non-default title" do
      original_title = @conversation.title
      post conversation_messages_path(@conversation), params: { content: "Another question" }
      @conversation.reload
      assert_equal original_title, @conversation.title,
        "Title should not change when conversation already has a user message"
    end

    test "create redirects back to conversation when content is blank" do
      assert_no_difference("Message.count") do
        post conversation_messages_path(@conversation), params: { content: "   " }
      end
      assert_redirected_to conversation_path(@conversation),
        "Blank content should redirect without creating a message"
    end

    test "create redirects back to conversation when content param is missing" do
      assert_no_difference("Message.count") do
        post conversation_messages_path(@conversation)
      end
      assert_redirected_to conversation_path(@conversation)
    end

    test "create returns not found when conversation belongs to a different account" do
      other_user = users(:regular_user)
      other_account = accounts(:three)
      sign_in_as(other_user, other_account)

      post conversation_messages_path(@conversation), params: { content: "Question" }
      assert_response :not_found,
        "Should return 404 when accessing a conversation from another account"
    end

    test "create requires authentication" do
      delete session_path("current")
      post conversation_messages_path(@conversation), params: { content: "Question" }
      assert_redirected_to sign_in_path
    end
  end
end
