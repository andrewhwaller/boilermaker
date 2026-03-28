# frozen_string_literal: true

class PipelinesController < ApplicationController
  def show
    @pipeline_run = Current.account.pipeline_runs.recent.first
    render Views::Pipelines::Show.new(pipeline_run: @pipeline_run)
  end

  def create
    if Current.account.pipeline_runs.active.any?
      redirect_to pipeline_path, notice: "Pipeline is already running."
      return
    end

    pipeline_run = Current.account.pipeline_runs.create!(status: "pending")
    SyncStageJob.perform_later(pipeline_run)

    redirect_to pipeline_path, notice: "Pipeline started."
  rescue ActiveRecord::RecordNotUnique
    redirect_to pipeline_path, notice: "Pipeline is already running."
  end
end
