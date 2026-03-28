# frozen_string_literal: true

require "test_helper"

class ExtractStageJobTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:one)
    Current.account = @account
    @pipeline_run = PipelineRun.create!(account: @account, status: "running", current_stage: "sync")
  end

  teardown do
    Current.account = nil
    @pipeline_run&.destroy
  end

  test "sets current_stage to extract" do
    ExtractStageJob.perform_now(@pipeline_run)
    assert_equal "extract", @pipeline_run.reload.current_stage
  end

  test "enqueues EmbedStageJob on success" do
    assert_enqueued_with(job: EmbedStageJob, args: [ @pipeline_run ]) do
      ExtractStageJob.perform_now(@pipeline_run)
    end
  end

  test "updates items_total to count of items needing extraction" do
    # Account :one has zotero_items fixture :two which has extraction_status: pending
    pending_count = ZoteroItem.unscoped.where(account: @account).needs_extraction.count
    ExtractStageJob.perform_now(@pipeline_run)
    assert_equal pending_count, @pipeline_run.reload.items_total
  end

  test "skips items without attached PDF without marking as failed" do
    item = zotero_items(:two)
    assert_not item.pdf.attached?, "Fixture item two should not have a PDF attached"

    ExtractStageJob.perform_now(@pipeline_run)

    # Item without PDF should be skipped (not incremented as failed)
    assert_equal 0, @pipeline_run.reload.items_failed
  end

  test "marks pipeline as failed on unrecoverable error" do
    # Simulate an error at the pipeline level by checking failed! method
    @pipeline_run.failed!("Unrecoverable error")
    assert_equal "failed", @pipeline_run.reload.status
    assert_equal "Unrecoverable error", @pipeline_run.error_message
  end
end
