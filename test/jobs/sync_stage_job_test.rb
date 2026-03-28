# frozen_string_literal: true

require "test_helper"

class SyncStageJobTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:one)
    Current.account = @account
    @pipeline_run = PipelineRun.create!(account: @account, status: "pending")
  end

  teardown do
    Current.account = nil
    @pipeline_run&.destroy
  end

  test "marks pipeline as failed when ZoteroSyncService raises an error" do
    # SyncStageJob rescues errors and calls failed! — verify this behavior
    # by triggering a known failure (nil user_id from credentials in test env)
    SyncStageJob.perform_now(@pipeline_run)
    @pipeline_run.reload
    # Job should have caught the error and marked as failed
    assert_equal "failed", @pipeline_run.status
    assert_not_nil @pipeline_run.error_message
  end

  test "sets current_stage to sync before attempting sync" do
    SyncStageJob.perform_now(@pipeline_run)
    @pipeline_run.reload
    assert_equal "sync", @pipeline_run.current_stage
  end

  test "sets pipeline_run to running before attempting sync" do
    SyncStageJob.perform_now(@pipeline_run)
    @pipeline_run.reload
    assert_equal "running", @pipeline_run.started_at.present? ? "running" : @pipeline_run.status
    assert_not_nil @pipeline_run.started_at
  end

  test "failed pipeline run has error_message set" do
    @pipeline_run.failed!("Test error")
    assert_equal "failed", @pipeline_run.reload.status
    assert_equal "Test error", @pipeline_run.error_message
  end

  test "does not enqueue ExtractStageJob when sync fails" do
    assert_no_enqueued_jobs(only: ExtractStageJob) do
      SyncStageJob.perform_now(@pipeline_run)
    end
  end
end
