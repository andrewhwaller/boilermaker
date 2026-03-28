# frozen_string_literal: true

class Components::Pipeline::StatusIndicator < Components::Base
  include Phlex::Rails::Helpers::ButtonTo

  STAGE_LABELS = {
    "sync" => "Syncing",
    "extract" => "Extracting",
    "embed" => "Embedding"
  }.freeze

  def initialize(pipeline_run: nil)
    @pipeline_run = pipeline_run
  end

  def view_template
    div(id: "pipeline-status", class: "p-3 border-t border-line-muted") do
      if @pipeline_run.nil? || @pipeline_run.status == "pending"
        idle_state
      elsif @pipeline_run.status == "running"
        running_state
      elsif @pipeline_run.status == "completed"
        completed_state
      elsif @pipeline_run.status == "failed"
        failed_state
      end
    end
  end

  private

  def idle_state
    div(class: "space-y-2") do
      button_to pipeline_path,
        method: :post,
        class: "ui-button ui-button-sm w-full" do
        plain "Sync Library"
      end
    end
  end

  def running_state
    div(class: "space-y-2") do
      div(class: "flex items-center gap-2") do
        div(class: "w-2 h-2 rounded-full bg-accent animate-pulse")
        span(class: "text-xs text-muted") do
          plain stage_label
        end
      end

      if @pipeline_run.items_total > 0
        div(class: "text-xs text-muted") do
          plain "#{@pipeline_run.items_processed}/#{@pipeline_run.items_total} items"
        end
        progress_bar
      end

      button_to pipeline_path,
        method: :post,
        class: "ui-button ui-button-sm ui-button-ghost w-full opacity-50",
        disabled: true do
        plain "Pipeline running..."
      end
    end
  end

  def completed_state
    div(class: "space-y-2") do
      div(class: "flex items-center gap-2") do
        div(class: "w-2 h-2 rounded-full bg-green-500")
        span(class: "text-xs text-muted") { plain "Sync complete" }
      end

      if @pipeline_run.items_failed > 0
        div(class: "text-xs text-destructive") do
          plain "#{@pipeline_run.items_failed} items failed"
        end
      end

      button_to pipeline_path,
        method: :post,
        class: "ui-button ui-button-sm w-full" do
        plain "Re-sync Library"
      end
    end
  end

  def failed_state
    div(class: "space-y-2") do
      div(class: "flex items-center gap-2") do
        div(class: "w-2 h-2 rounded-full bg-destructive")
        span(class: "text-xs text-destructive") { plain "Pipeline failed" }
      end

      if @pipeline_run.error_message.present?
        div(class: "text-xs text-muted truncate", title: @pipeline_run.error_message) do
          plain @pipeline_run.error_message.truncate(60)
        end
      end

      button_to pipeline_path,
        method: :post,
        class: "ui-button ui-button-sm w-full" do
        plain "Retry Pipeline"
      end
    end
  end

  def stage_label
    STAGE_LABELS[@pipeline_run.current_stage] || @pipeline_run.current_stage&.capitalize || "Processing"
  end

  def progress_bar
    return unless @pipeline_run.items_total > 0

    pct = ((@pipeline_run.items_processed.to_f / @pipeline_run.items_total) * 100).round
    div(class: "w-full bg-surface-raised rounded-full h-1") do
      div(class: "bg-accent h-1 rounded-full transition-all", style: "width: #{pct}%")
    end
  end
end
