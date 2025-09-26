# frozen_string_literal: true

class Components::Loading < Components::Base
  TYPES = {
    dots: "ascii-dots",
    spinner: "ascii-spinner",
    pulse: "ascii-pulse"
  }.freeze

  SIZES = {
    xs: "text-xs",
    sm: "text-sm",
    md: "text-base",
    lg: "text-lg"
  }.freeze

  COLORS = {
    primary: "text-primary",
    secondary: "text-secondary",
    accent: "text-accent",
    neutral: "text-neutral",
    info: "text-info",
    success: "text-success",
    warning: "text-warning",
    error: "text-error"
  }.freeze

  def initialize(
    type: :dots,
    size: :md,
    color: nil,
    text: nil,
    **attributes
  )
    @type = type
    @size = size
    @color = color
    @text = text
    @attributes = attributes
  end

  def view_template(&block)
    div(class: css_classes("flex items-center", (@text.present? ? nil : "justify-center")), **filtered_attributes) do
      span(class: css_classes("loading-ascii", TYPES[@type], SIZES[@size], (@color ? COLORS[@color] : nil)), "aria-hidden": "true")

      if @text.present?
        span(class: "ml-2 text-sm") { @text }
      end

      yield if block
    end
  end
end
