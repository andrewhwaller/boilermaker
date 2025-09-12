# frozen_string_literal: true

class Components::Loading < Components::Base
  TYPES = {
    spinner: "loading-spinner",
    dots: "loading-dots",
    ring: "loading-ring",
    ball: "loading-ball",
    bars: "loading-bars",
    infinity: "loading-infinity"
  }.freeze

  SIZES = {
    xs: "loading-xs",
    sm: "loading-sm",
    md: "loading-md",
    lg: "loading-lg"
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
    type: :spinner,
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
    div(class: container_classes, **@attributes) do
      span(class: loading_classes, "aria-hidden": "true")

      if @text.present?
        span(class: "ml-2 text-sm") { @text }
      end

      yield if block
    end
  end

  private

  def container_classes
    classes = [ "flex items-center" ]
    classes << "justify-center" unless @text.present?
    classes.join(" ")
  end

  def loading_classes
    [
      "loading",
      TYPES[@type],
      SIZES[@size],
      @color ? COLORS[@color] : nil
    ].compact.join(" ")
  end
end
