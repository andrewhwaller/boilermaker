# frozen_string_literal: true

class Components::Button < Components::Base
  VARIANTS = {
    primary: "ui-button-primary",
    secondary: "ui-button-secondary",
    success: "ui-button-success",
    info: "ui-button-info",
    warning: "ui-button-warning",
    error: "ui-button-error",
    destructive: "ui-button-error",
    outline: "ui-button-outline",
    ghost: "ui-button-ghost",
    link: "ui-button-link"
  }.freeze

  SIZES = {
    lg: "ui-button-lg",
    md: "ui-button-md",
    sm: "ui-button-sm",
    xs: "ui-button-xs"
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
        "ui-button",
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
