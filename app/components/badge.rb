# frozen_string_literal: true

class Components::Badge < Components::Base
  VARIANTS = {
    primary: "ui-badge-primary",
    secondary: "ui-badge-secondary",
    destructive: "ui-badge-destructive",
    success: "ui-badge-success",
    warning: "ui-badge-warning",
    info: "ui-badge-info",
    accent: "ui-badge-accent",
    neutral: "ui-badge-neutral",
    outline: "ui-badge-outline",
    error: "ui-badge-error" # alias for error styling
  }.freeze

  SIZES = {
    xs: "ui-badge-xs",
    sm: "ui-badge-sm",
    lg: "ui-badge-lg"
  }.freeze

  def initialize(variant: :neutral, size: nil, **attributes)
    @variant = variant
    @size = size
    @attributes = attributes
  end

  def view_template(&block)
    classes = [ "ui-badge", VARIANTS[@variant] ]
    classes << SIZES[@size] if @size && SIZES[@size]

    span(class: classes, **@attributes) do
      yield if block
    end
  end
end
