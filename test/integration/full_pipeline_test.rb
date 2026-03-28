# frozen_string_literal: true

require "test_helper"

class FullPipelineTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:regular_user)
    @account = accounts(:three)
    sign_in_as(@user, @account)
  end

  test "authenticated user is redirected from home to conversations" do
    get root_path
    assert_redirected_to conversations_path
  end

  test "unauthenticated user is redirected to sign in" do
    delete session_path("current")
    get root_path
    assert_redirected_to sign_in_path
  end

  test "pipeline trigger creates pipeline run and redirects" do
    assert_enqueued_with(job: SyncStageJob) do
      post pipeline_path
    end
    assert_redirected_to pipeline_path
  end

  test "all new routes are accessible" do
    # Pipeline
    get pipeline_path
    assert_response :success

    # Search
    get searches_path
    assert_response :success

    # Conversations
    get conversations_path
    assert_response :success

    get new_conversation_path
    assert_response :success
  end

  test "existing pages still render after sidebar changes" do
    get settings_path
    assert_response :success

    get account_dashboard_path
    assert_response :success
  end
end
