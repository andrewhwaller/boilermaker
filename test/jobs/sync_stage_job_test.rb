# frozen_string_literal: true

require "test_helper"

class SyncStageJobTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:three)
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
    assert_not_nil @pipeline_run.started_at,
      "Pipeline run should have started_at set after perform"
  end

  test "perform captures error message in pipeline_run on failure" do
    SyncStageJob.perform_now(@pipeline_run)
    @pipeline_run.reload
    assert_equal "failed", @pipeline_run.status
    assert @pipeline_run.error_message.present?,
      "Pipeline run should have an error message explaining the failure"
  end

  test "does not enqueue ExtractStageJob when sync fails" do
    assert_no_enqueued_jobs(only: ExtractStageJob) do
      SyncStageJob.perform_now(@pipeline_run)
    end
  end
end
