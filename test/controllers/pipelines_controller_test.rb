# frozen_string_literal: true

require "test_helper"

class PipelinesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:regular_user)
    @account = accounts(:three)
    sign_in_as(@user, @account)
  end

  test "show returns pipeline status page" do
    get pipeline_path
    assert_response :success
  end

  test "show displays no pipeline runs message when none exist" do
    get pipeline_path
    assert_response :success
    assert_match(/No pipeline runs yet/i, response.body)
  end

  test "show displays most recent pipeline run" do
    PipelineRun.unscoped.create!(account: @account, status: "completed", current_stage: "embed",
                                 items_total: 5, items_processed: 5, items_failed: 0,
                                 started_at: Time.current, completed_at: Time.current)
    get pipeline_path
    assert_response :success
    assert_match(/Completed/i, response.body)
  end

  test "create starts pipeline and redirects to pipeline path" do
    assert_enqueued_with(job: SyncStageJob) do
      post pipeline_path
    end
    assert_redirected_to pipeline_path
  end

  test "create creates a pending pipeline run for the current account" do
    before_count = PipelineRun.unscoped.where(account: @account).count
    post pipeline_path
    after_count = PipelineRun.unscoped.where(account: @account).count
    assert_equal before_count + 1, after_count

    pipeline_run = PipelineRun.unscoped.where(account: @account).order(created_at: :desc).first
    assert_equal "pending", pipeline_run.status
  end

  test "create rejects when pipeline already running" do
    PipelineRun.unscoped.create!(account: @account, status: "running", current_stage: "sync",
                                 started_at: Time.current)

    assert_no_enqueued_jobs(only: SyncStageJob) do
      post pipeline_path
    end
    assert_redirected_to pipeline_path
    follow_redirect!
    assert_match(/already running/i, response.body)
  end

  test "show requires authentication" do
    delete session_path("current")
    get pipeline_path
    assert_redirected_to sign_in_path
  end

  test "create requires authentication" do
    delete session_path("current")
    post pipeline_path
    assert_redirected_to sign_in_path
  end
end
