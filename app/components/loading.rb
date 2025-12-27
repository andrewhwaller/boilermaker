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
    primary: "text-accent",
    secondary: "text-muted",
    accent: "text-accent",
    neutral: "text-muted",
    info: "text-accent",
    success: "text-accent-alt",
    warning: "text-warning",
    error: "text-destructive"
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
    div(class: css_classes("flex items-center", (@text.present? ? nil : "justify-center")), **@attributes) do
      span(class: css_classes("loading-ascii", TYPES[@type], SIZES[@size], (@color ? COLORS[@color] : nil)), "aria-hidden": "true")

      if @text.present?
        span(class: "ml-2 text-sm") { @text }
      end

      yield if block
    end
  end
end
