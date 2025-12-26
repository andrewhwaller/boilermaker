# frozen_string_literal: true

class Components::Button < Components::Base
  VARIANTS = {
    primary: "btn-primary",
    secondary: "btn-secondary",
    success: "btn-success",
    info: "btn-info",
    warning: "btn-warning",
    error: "btn-error",
    destructive: "btn-error",
    outline: "btn-outline",
    ghost: "btn-ghost",
    link: "btn-link"
  }.freeze

  SIZES = {
    lg: "btn-lg",
    md: "btn-md",
    sm: "btn-sm",
    xs: "btn-xs"
  }.freeze

  def initialize(variant: :primary, type: :button, uppercase: nil, size: :md, **attributes)
    @variant = variant
    @type = type
    @uppercase = uppercase
    @size = size
    @attributes = attributes
  end

  def view_template(&block)
    button(
      type: @type,
      class: css_classes(
        "btn",
        VARIANTS[@variant],
        SIZES[@size],
        button_casing_class
      ),
      **@attributes
    ) do
      yield if block
    end
  end

  private

  def button_casing_class
    return "uppercase" if @uppercase == true
    return "normal-case" if @uppercase == false

    nil
  end
end
