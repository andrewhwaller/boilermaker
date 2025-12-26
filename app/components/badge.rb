# frozen_string_literal: true

class Components::Badge < Components::Base
  VARIANTS = {
    primary: "badge-primary",
    secondary: "badge-secondary",
    destructive: "badge-destructive",
    success: "badge-success",
    warning: "badge-warning",
    info: "badge-info",
    accent: "badge-accent",
    neutral: "badge-neutral",
    outline: "badge-outline",
    error: "badge-error" # alias for error styling
  }.freeze

  SIZES = {
    xs: "badge-xs",
    sm: "badge-sm",
    lg: "badge-lg"
  }.freeze

  def initialize(variant: :neutral, size: nil, **attributes)
    @variant = variant
    @size = size
    @attributes = attributes
  end

  def view_template(&block)
    classes = [ "badge", VARIANTS[@variant] ]
    classes << SIZES[@size] if @size && SIZES[@size]

    span(class: classes, **@attributes) do
      yield if block
    end
  end
end
