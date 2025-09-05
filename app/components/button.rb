# frozen_string_literal: true

class Components::Button < Components::Base
  VARIANTS = {
    primary: "btn-primary",
    secondary: "btn-secondary",
    destructive: "btn-error",
    outline: "btn-outline",
    ghost: "btn-ghost",
    link: "btn-link"
  }.freeze

  def initialize(variant: :primary, type: :button, **attributes)
    @variant = variant
    @type = type
    @attributes = attributes
  end

  def view_template(&block)
    button_classes = [
      "btn",
      "disabled:opacity-50",
      VARIANTS[@variant]
    ].join(" ")

    button(type: @type, class: button_classes, **@attributes) do
      yield if block
    end
  end
end
