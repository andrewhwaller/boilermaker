# frozen_string_literal: true

require "test_helper"

class ConversationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:app_admin)
    @account = accounts(:one)
    sign_in_as(@user, @account)
  end

  # Index

  test "index returns success" do
    get conversations_path
    assert_response :success, "GET /conversations should return 200"
  end

  test "index shows conversations for the current account" do
    get conversations_path
    assert_response :success
    assert_match(/Research on methodology/, response.body,
      "Should show conversations belonging to the current account")
  end

  test "index does not show conversations from another account" do
    sign_in_as(users(:regular_user), accounts(:three))
    get conversations_path
    assert_response :success
    assert_no_match(/Research on methodology/, response.body,
      "Should not show conversations from another account")
  end

  test "index requires authentication" do
    delete session_path("current")
    get conversations_path
    assert_redirected_to sign_in_path, "Unauthenticated request should redirect to sign in"
  end

  test "index shows empty state when no conversations exist for account" do
    sign_in_as(users(:regular_user), accounts(:three))
    get conversations_path
    assert_response :success
    assert_match(/Welcome to Carrel|Library synced|Ready to research/i, response.body,
      "Empty state component should appear when no conversations exist")
  end

  # Show

  test "show returns success for owned conversation" do
    conversation = conversations(:one)
    get conversation_path(conversation)
    assert_response :success, "GET /conversations/:id should return 200 for owned conversation"
  end

  test "show returns not found for conversation belonging to different account" do
    conversation = conversations(:one)
    sign_in_as(users(:regular_user), accounts(:three))
    get conversation_path(conversation)
    assert_response :not_found,
      "Show should return 404 for conversation not owned by current account"
  end

  test "show displays conversation messages" do
    conversation = conversations(:one)
    get conversation_path(conversation)
    assert_response :success
    assert_match(/What does my library say about research methodology/, response.body,
      "User message content should appear in conversation view")
  end

  test "show displays conversation title" do
    conversation = conversations(:one)
    get conversation_path(conversation)
    assert_response :success
    assert_match(conversation.title, response.body,
      "Conversation title should appear in the show view")
  end

  # New

  test "new returns success" do
    get new_conversation_path
    assert_response :success, "GET /conversations/new should return 200"
  end

  test "new requires authentication" do
    delete session_path("current")
    get new_conversation_path
    assert_redirected_to sign_in_path
  end

  test "new shows input form" do
    get new_conversation_path
    assert_response :success
    assert_match(/name="content"/, response.body,
      "New conversation form should include content textarea")
  end

  # Create

  test "create with title only creates conversation and redirects to it" do
    assert_difference("Conversation.unscoped.count", 1) do
      post conversations_path, params: { title: "My new conversation" }
    end
    conversation = Conversation.unscoped.order(created_at: :desc).first
    assert_redirected_to conversation_path(conversation)
    assert_equal "My new conversation", conversation.title
  end

  test "create with content creates conversation with truncated title and first message" do
    content = "What is the main theme of my research?"
    assert_difference("Conversation.unscoped.count", 1) do
      assert_difference("Message.count", 1) do
        post conversations_path, params: { content: content }
      end
    end
    conversation = Conversation.unscoped.order(created_at: :desc).first
    assert_redirected_to conversation_path(conversation)
    assert_equal content.truncate(50), conversation.title
    message = conversation.messages.first
    assert_equal "user", message.role
    assert_equal content, message.content
  end

  test "create with content enqueues ResearchAssistantJob" do
    assert_enqueued_with(job: ResearchAssistantJob) do
      post conversations_path, params: { content: "Tell me about methodology" }
    end
  end

  test "create without content or title uses default title and creates no message" do
    assert_difference("Conversation.unscoped.count", 1) do
      assert_no_difference("Message.count") do
        post conversations_path
      end
    end
    conversation = Conversation.unscoped.order(created_at: :desc).first
    assert_equal "New conversation", conversation.title
  end

  test "create scopes new conversation to current account" do
    post conversations_path, params: { title: "Account scoped test" }
    conversation = Conversation.unscoped.order(created_at: :desc).first
    assert_not_nil conversation, "Conversation should have been created"
    assert_equal @account.id, conversation.account_id
  end

  test "create requires authentication" do
    delete session_path("current")
    post conversations_path, params: { title: "Test" }
    assert_redirected_to sign_in_path
  end

  # Destroy

  test "destroy deletes conversation and redirects to index" do
    conversation = conversations(:one)
    assert_difference("Conversation.unscoped.count", -1) do
      delete conversation_path(conversation)
    end
    assert_redirected_to conversations_path
    assert_equal "Conversation deleted.", flash[:notice]
  end

  test "destroy returns not found for conversation from another account" do
    conversation = conversations(:one)
    sign_in_as(users(:regular_user), accounts(:three))
    delete conversation_path(conversation)
    assert_response :not_found,
      "Destroy should return 404 for conversation not owned by current account"
  end

  test "destroy requires authentication" do
    conversation = conversations(:one)
    delete session_path("current")
    delete conversation_path(conversation)
    assert_redirected_to sign_in_path
  end
end
