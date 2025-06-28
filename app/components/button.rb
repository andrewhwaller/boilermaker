# frozen_string_literal: true

class Components::Button < Components::Base
  VARIANTS = {
    primary: "bg-primary text-primary-foreground hover:bg-primary/90",
    secondary: "bg-secondary text-secondary-foreground hover:bg-secondary/90",
    destructive: "bg-destructive text-destructive-foreground hover:bg-destructive/90",
    outline: "border border-border bg-background hover:bg-accent hover:text-accent-foreground",
    ghost: "hover:bg-accent hover:text-accent-foreground",
    link: "text-primary underline-offset-4 hover:underline"
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
