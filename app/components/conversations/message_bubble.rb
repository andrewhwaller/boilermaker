# frozen_string_literal: true

class Components::Conversations::MessageBubble < Components::Base
  def initialize(message:)
    @message = message
  end

  def view_template
    div(
      id: "message_#{@message.id}",
      class: bubble_classes,
      data: assistant? ? { controller: "markdown", markdown_raw_value: @message.content.to_s } : {}
    ) do
      role_label
      content_area
      status_indicator if assistant?
    end
  end

  private

  def bubble_classes
    base = "ui-message-bubble p-4 rounded"
    if user?
      "#{base} bg-surface-raised"
    elsif error?
      "#{base} border border-destructive/50"
    elsif interrupted?
      "#{base} border border-yellow-500/50"
    else
      base
    end
  end

  def role_label
    div(class: "text-xs text-muted mb-1 font-semibold") do
      plain user? ? "You" : "Assistant"
    end
  end

  def content_area
    if user?
      div(class: "text-sm whitespace-pre-wrap") { plain @message.content.to_s }
    else
      div(
        class: "text-sm prose prose-sm max-w-none",
        data: { markdown_target: "output" }
      ) do
        plain @message.content.to_s
      end
    end
  end

  def status_indicator
    if interrupted?
      div(class: "mt-2 text-xs text-yellow-600 flex items-center gap-1") do
        plain "Response was interrupted"
      end
    elsif error?
      div(class: "mt-2 text-xs text-destructive") do
        plain "Response failed — try again"
      end
    elsif !@message.complete?
      div(class: "mt-2 flex items-center gap-1") do
        div(class: "w-1.5 h-1.5 rounded-full bg-accent animate-pulse")
        span(class: "text-xs text-muted") { "Generating..." }
      end
    end
  end

  def user?
    @message.role == "user"
  end

  def assistant?
    @message.role == "assistant"
  end

  def error?
    assistant? && @message.complete? && @message.content.to_s.include?("*An error occurred")
  end

  def interrupted?
    assistant? && !@message.complete?
  end
end
