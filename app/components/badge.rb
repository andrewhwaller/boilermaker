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
    md: nil,
    lg: "badge-lg"
  }.freeze

  STYLES = {
    filled: nil,
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
    span(class: css_classes("badge", VARIANTS[@variant], SIZES[@size], STYLES[@style]), **filtered_attributes) do
      yield if block
    end
  end
end
