# frozen_string_literal: true

class Views::Pipelines::Show < Views::Base
  def initialize(pipeline_run: nil)
    @pipeline_run = pipeline_run
  end

  def view_template
    page_with_title("Pipeline Status") do
      div(class: "max-w-2xl mx-auto space-y-6") do
        render Components::Pipeline::StatusIndicator.new(pipeline_run: @pipeline_run)

        if @pipeline_run.present?
          pipeline_details
        else
          empty_state
        end
      end
    end
  end

  private

  def pipeline_details
    card(title: "Pipeline Run") do
      div(class: "space-y-3 text-sm") do
        detail_row("Status", @pipeline_run.status.capitalize)
        detail_row("Stage", @pipeline_run.current_stage&.capitalize || "—")
        detail_row("Items Processed", "#{@pipeline_run.items_processed}/#{@pipeline_run.items_total}")
        detail_row("Failures", @pipeline_run.items_failed.to_s)
        detail_row("Started", @pipeline_run.started_at&.strftime("%Y-%m-%d %H:%M") || "—")
        detail_row("Completed", @pipeline_run.completed_at&.strftime("%Y-%m-%d %H:%M") || "—")

        if @pipeline_run.error_message.present?
          div(class: "p-3 bg-destructive/10 rounded text-destructive text-xs") do
            plain @pipeline_run.error_message
          end
        end
      end
    end
  end

  def empty_state
    card do
      div(class: "text-center py-8 text-muted") do
        p { "No pipeline runs yet." }
        p(class: "text-sm mt-2") { "Click 'Sync Library' to start your first sync." }
      end
    end
  end

  def detail_row(label, value)
    div(class: "flex justify-between") do
      span(class: "text-muted") { label }
      span(class: "font-medium") { value }
    end
  end
end
