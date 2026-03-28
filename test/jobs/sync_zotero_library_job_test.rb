# frozen_string_literal: true

require "test_helper"

class SyncZoteroLibraryJobTest < ActiveSupport::TestCase
  setup do
    Current.account = accounts(:one)
    @account = accounts(:one)
  end

  teardown do
    Current.account = nil
  end

  test "perform updates pipeline_run current_stage to sync" do
    Current.account = @account
    run = PipelineRun.create!(account: @account, status: "pending")

    noop_service = Struct.new(:account, :pipeline_run) { def call; end }.new(@account, run)

    ZoteroSyncService.stub(:new, ->(**) { noop_service }) do
      SyncZoteroLibraryJob.new.perform(run)
    end

    run.reload
    assert_equal "sync", run.current_stage
  end

  test "perform calls ZoteroSyncService with correct arguments" do
    Current.account = @account
    run = PipelineRun.create!(account: @account, status: "pending")

    service_args = {}
    noop_service = Struct.new(:account, :pipeline_run) { def call; end }.new(@account, run)

    ZoteroSyncService.stub(:new, ->(account:, pipeline_run:) {
      service_args[:account] = account
      service_args[:pipeline_run] = pipeline_run
      noop_service
    }) do
      SyncZoteroLibraryJob.new.perform(run)
    end

    assert_equal @account, service_args[:account]
    assert_equal run, service_args[:pipeline_run]
  end

  test "perform marks pipeline_run as failed when service raises" do
    Current.account = @account
    run = PipelineRun.create!(account: @account, status: "pending")

    ZoteroSyncService.stub(:new, ->(**) { raise StandardError, "API is down" }) do
      assert_raises(StandardError) do
        SyncZoteroLibraryJob.new.perform(run)
      end
    end

    run.reload
    assert_equal "failed", run.status
    assert_equal "API is down", run.error_message
  end

  test "job is enqueued to default queue" do
    assert_equal "default", SyncZoteroLibraryJob.queue_name
  end
end
