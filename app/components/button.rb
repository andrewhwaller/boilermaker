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

  def initialize(variant: :primary, type: :button, uppercase: false, **attributes)
    @variant = variant
    @type = type
    @uppercase = uppercase
    @attributes = attributes
  end

  def view_template(&block)
    button(
      type: @type,
      class: css_classes("btn", "disabled:opacity-50", VARIANTS[@variant], (@uppercase ? "uppercase" : nil)),
      **filtered_attributes(:size)
    ) do
      yield if block
    end
  end
end
