# frozen_string_literal: true

require "test_helper"

class PipelineRunTest < ActiveSupport::TestCase
  setup do
    Current.account = accounts(:one)
  end

  teardown do
    Current.account = nil
  end

  test "requires account" do
    run = PipelineRun.new(status: "pending", account: nil)
    assert_not run.valid?
    assert_includes run.errors[:account], "must exist"
  end

  test "status must be valid" do
    assert_raises(ArgumentError) do
      PipelineRun.new(account: accounts(:one), status: "invalid")
    end
  end

  test "current_stage must be valid when present" do
    run = PipelineRun.new(account: accounts(:one), status: "running", current_stage: "invalid")
    assert_not run.valid?
    assert_includes run.errors[:current_stage], "is not included in the list"
  end

  test "current_stage can be nil" do
    run = PipelineRun.new(account: accounts(:one), status: "pending")
    assert run.valid?
  end

  test "running! sets status and started_at" do
    run = pipeline_runs(:completed_run)
    run.update!(status: "pending", started_at: nil)
    run.running!
    assert_equal "running", run.status
    assert_not_nil run.started_at
  end

  test "completed! sets status and completed_at" do
    run = pipeline_runs(:running_run)
    run.completed!
    assert_equal "completed", run.status
    assert_not_nil run.completed_at
  end

  test "failed! sets status, error_message, and completed_at" do
    run = pipeline_runs(:running_run)
    run.failed!("Something went wrong")
    assert_equal "failed", run.status
    assert_equal "Something went wrong", run.error_message
    assert_not_nil run.completed_at
  end

  test "defaults to pending status" do
    run = PipelineRun.create!(account: accounts(:one))
    assert_equal "pending", run.status
  end

  test "scoped to current account" do
    runs = PipelineRun.all
    assert runs.all? { |r| r.account_id == accounts(:one).id }
  end
end
