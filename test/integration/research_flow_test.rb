# frozen_string_literal: true

require "test_helper"

class ResearchFlowTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:regular_user)
    @account = accounts(:three)
    sign_in_as(@user, @account)
  end

  test "create conversation and send message enqueues assistant job" do
    # Create conversation
    post conversations_path, params: { title: "Test research" }
    assert_redirected_to conversation_path(Conversation.unscoped.last)
    follow_redirect!
    assert_response :success

    conversation = Conversation.unscoped.last
    assert_equal "Test research", conversation.title

    # Send message
    assert_enqueued_with(job: ResearchAssistantJob) do
      post conversation_messages_path(conversation), params: { content: "What is methodology?" }
    end
    assert_redirected_to conversation_path(conversation)
  end

  test "cross-account isolation for conversations" do
    # Create a conversation for account three
    post conversations_path, params: { title: "Account three convo" }
    conversation = Conversation.unscoped.last
    assert_equal @account.id, conversation.account_id

    # Sign in as different user
    other_user = users(:app_admin)
    other_account = accounts(:one)
    sign_in_as(other_user, other_account)

    # Should not see the other account's conversation
    get conversations_path
    assert_response :success
    assert_not_includes response.body, "Account three convo"

    # Direct access should fail
    get conversation_path(conversation)
    assert_response :not_found
  end

  test "cross-account isolation for pipeline" do
    # Pipeline runs are scoped to current account
    post pipeline_path
    assert_redirected_to pipeline_path

    pipeline_run = PipelineRun.unscoped.last
    assert_equal @account.id, pipeline_run.account_id
  end

  test "search page renders without errors" do
    get searches_path
    assert_response :success

    get searches_path, params: { q: "" }
    assert_response :success
  end
end
