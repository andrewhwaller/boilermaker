# frozen_string_literal: true

require "test_helper"
require_relative "../component_test_case"

class Components::Pipeline::StatusIndicatorTest < ComponentTestCase
  setup do
    Current.account = accounts(:one)
  end

  teardown do
    Current.account = nil
  end

  test "renders idle state when no pipeline run" do
    html = render_component(Components::Pipeline::StatusIndicator.new(pipeline_run: nil))
    assert_includes html, "Sync Library"
  end

  test "renders idle state when pipeline run is pending" do
    run = PipelineRun.create!(account: accounts(:one), status: "pending")
    html = render_component(Components::Pipeline::StatusIndicator.new(pipeline_run: run))
    assert_includes html, "Sync Library"
    run.destroy
  end

  test "renders running state" do
    run = pipeline_runs(:running_run)
    html = render_component(Components::Pipeline::StatusIndicator.new(pipeline_run: run))
    assert_includes html, "Syncing"
    assert_includes html, "Pipeline running..."
  end

  test "renders running state shows progress counts" do
    run = pipeline_runs(:running_run)
    html = render_component(Components::Pipeline::StatusIndicator.new(pipeline_run: run))
    assert_includes html, "25/100 items"
  end

  test "renders completed state" do
    run = pipeline_runs(:completed_run)
    html = render_component(Components::Pipeline::StatusIndicator.new(pipeline_run: run))
    assert_includes html, "Sync complete"
    assert_includes html, "Re-sync Library"
  end

  test "renders failed state" do
    run = PipelineRun.create!(account: accounts(:one), status: "failed", error_message: "API timeout",
                              current_stage: "sync", started_at: Time.current, completed_at: Time.current)
    html = render_component(Components::Pipeline::StatusIndicator.new(pipeline_run: run))
    assert_includes html, "Pipeline failed"
    assert_includes html, "API timeout"
    assert_includes html, "Retry Pipeline"
    run.destroy
  end

  test "renders failed state truncates long error messages" do
    long_error = "A" * 80
    run = PipelineRun.create!(account: accounts(:one), status: "failed", error_message: long_error,
                              current_stage: "embed", started_at: Time.current, completed_at: Time.current)
    html = render_component(Components::Pipeline::StatusIndicator.new(pipeline_run: run))
    assert_includes html, "Pipeline failed"
    # Should truncate to 60 chars with ellipsis
    assert_includes html, "..."
    run.destroy
  end

  test "shows progress bar when running with progress" do
    run = pipeline_runs(:running_run)
    html = render_component(Components::Pipeline::StatusIndicator.new(pipeline_run: run))
    assert_includes html, "25/100 items"
    assert_includes html, "width: 25%"
  end

  test "shows failed items count in completed state" do
    run = PipelineRun.create!(account: accounts(:one), status: "completed", current_stage: "embed",
                              items_total: 10, items_processed: 8, items_failed: 2,
                              started_at: Time.current, completed_at: Time.current)
    html = render_component(Components::Pipeline::StatusIndicator.new(pipeline_run: run))
    assert_includes html, "2 items failed"
    run.destroy
  end

  test "does not show failed items count when zero failures" do
    run = pipeline_runs(:completed_run)
    html = render_component(Components::Pipeline::StatusIndicator.new(pipeline_run: run))
    assert_not_includes html, "items failed"
  end

  test "stage label shows Extracting for extract stage" do
    run = PipelineRun.create!(account: accounts(:one), status: "running", current_stage: "extract",
                              items_total: 50, items_processed: 10, started_at: Time.current)
    html = render_component(Components::Pipeline::StatusIndicator.new(pipeline_run: run))
    assert_includes html, "Extracting"
    run.destroy
  end

  test "stage label shows Embedding for embed stage" do
    run = PipelineRun.create!(account: accounts(:one), status: "running", current_stage: "embed",
                              items_total: 50, items_processed: 30, started_at: Time.current)
    html = render_component(Components::Pipeline::StatusIndicator.new(pipeline_run: run))
    assert_includes html, "Embedding"
    run.destroy
  end
end
