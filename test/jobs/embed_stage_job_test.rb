# frozen_string_literal: true

require "test_helper"

class EmbedStageJobTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  setup do
    @account = accounts(:one)
    Current.account = @account
    @pipeline_run = PipelineRun.create!(account: @account, status: "running", current_stage: "extract")
  end

  teardown do
    Current.account = nil
    @pipeline_run&.destroy
  end

  test "sets current_stage to embed" do
    EmbedStageJob.perform_now(@pipeline_run)
    assert_equal "embed", @pipeline_run.reload.current_stage
  end

  test "marks pipeline as completed on success" do
    EmbedStageJob.perform_now(@pipeline_run)
    assert_equal "completed", @pipeline_run.reload.status
  end

  test "sets completed_at when pipeline completes" do
    EmbedStageJob.perform_now(@pipeline_run)
    assert_not_nil @pipeline_run.reload.completed_at
  end

  test "updates items_total to count of items needing embedding" do
    pending_count = ZoteroItem.unscoped.where(account: @account).needs_embedding.count
    EmbedStageJob.perform_now(@pipeline_run)
    assert_equal pending_count, @pipeline_run.reload.items_total
  end

  test "marks pipeline as failed on unrecoverable error" do
    @pipeline_run.failed!("Embedding error")
    assert_equal "failed", @pipeline_run.reload.status
    assert_equal "Embedding error", @pipeline_run.error_message
  end
end
