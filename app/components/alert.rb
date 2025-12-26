# frozen_string_literal: true

class Components::Alert < Components::Base
  VARIANTS = {
    success: "alert-success",
    error: "alert-destructive",
    warning: "alert-warning",
    info: "alert-info"
  }.freeze

  def initialize(message:, variant: :info, dismissible: false, icon: nil, **attributes)
    @message = message
    @variant = variant.to_sym
    @dismissible = dismissible
    @attributes = attributes
  end

  def view_template
    return if @message.blank?

    aria_attrs = {
      role: @variant == :error ? "alert" : "status",
      "aria-live": @variant == :error ? "assertive" : "polite"
    }

    div(class: css_classes("alert", VARIANTS[@variant]), **aria_attrs, **filtered_attributes) do
      div(class: "flex items-center justify-between w-full") do
        div(class: "flex items-center gap-2") do
          div(class: "flex-1") do
            if @message.is_a?(String)
              span { @message }
            else
              @message
            end
          end
        end
      end

      if @dismissible
        button(
          type: "button",
          class: "btn btn-ghost ml-auto shrink-0",
          "aria-label": "Dismiss alert",
          "data-dismiss": "alert"
        ) do
          span { "Dismiss" }
        end
      end
    end
  end
end
