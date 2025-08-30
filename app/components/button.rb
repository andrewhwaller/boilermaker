# frozen_string_literal: true

class Components::Button < Components::Base
  VARIANTS = {
    primary: "bg-button text-button-text hover:bg-button-hover",
    secondary: "bg-button-secondary text-button-secondary-text hover:bg-button-secondary-hover",
    destructive: "bg-error text-error-text hover:bg-error/90",
    outline: "border border-border bg-background hover:bg-surface hover:text-foreground",
    ghost: "hover:bg-surface hover:text-foreground",
    link: "text-accent underline-offset-4 hover:underline hover:text-accent-hover"
  }.freeze

  def initialize(variant: :primary, type: :button, **attributes)
    @variant = variant
    @type = type
    @attributes = attributes
  end

  def view_template(&block)
    button_classes = [
      "disabled:opacity-50",
      VARIANTS[@variant]
    ].join(" ")

    button(type: @type, class: button_classes, **@attributes) do
      yield if block
    end
  end
end
