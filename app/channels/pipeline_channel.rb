# frozen_string_literal: true

class PipelineChannel < ApplicationCable::Channel
  def subscribed
    stream_from "pipeline_status_#{current_user.id}"
  end
end
