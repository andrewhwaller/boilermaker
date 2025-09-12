# frozen_string_literal: true

class Components::Badge < Components::Base
  VARIANTS = {
    primary: "badge-primary",
    secondary: "badge-secondary",
    accent: "badge-accent",
    neutral: "badge-neutral",
    info: "badge-info",
    success: "badge-success",
    warning: "badge-warning",
    error: "badge-error"
  }.freeze

  SIZES = {
    xs: "badge-xs",
    sm: "badge-sm",
    md: "",  # Default size, no class needed
    lg: "badge-lg"
  }.freeze

  STYLES = {
    filled: "",  # Default style, no class needed
    outline: "badge-outline",
    ghost: "badge-ghost"
  }.freeze

  def initialize(variant: :neutral, size: :md, style: :filled, **attributes)
    @variant = variant
    @size = size
    @style = style
    @attributes = attributes
  end

  def view_template(&block)
    badge_classes = [
      "badge",
      VARIANTS[@variant],
      SIZES[@size],
      STYLES[@style]
    ].compact.reject(&:empty?).join(" ")

    span(class: badge_classes, **@attributes) do
      yield if block
    end
  end
end
