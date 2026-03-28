# frozen_string_literal: true

require "test_helper"

class ExtractStageJobTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:three)
    Current.account = @account
    @pipeline_run = PipelineRun.create!(account: @account, status: "running",
                                        current_stage: "sync", started_at: Time.current)
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

  test "updates items_total to count of items needing extraction with PDFs" do
    pending_with_pdf = ZoteroItem.unscoped.where(account: @account).needs_extraction
                                 .joins(:pdf_attachment).count
    ExtractStageJob.perform_now(@pipeline_run)
    assert_equal pending_with_pdf, @pipeline_run.reload.items_total
  end

  test "perform rescues errors and marks pipeline as failed" do
    ZoteroItem.stub(:unscoped, -> { raise RuntimeError, "Simulated DB failure" }) do
      ExtractStageJob.perform_now(@pipeline_run)
    end

    @pipeline_run.reload
    assert_equal "failed", @pipeline_run.status,
      "Pipeline should be marked as failed when perform raises"
    assert_match(/Simulated DB failure/, @pipeline_run.error_message,
      "Pipeline should capture the error message from the failure")
  end
end
