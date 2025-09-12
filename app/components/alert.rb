# frozen_string_literal: true

class Components::Alert < Components::Base
  VARIANTS = {
    success: "alert-success",
    error: "alert-error",
    warning: "alert-warning",
    info: "alert-info"
  }.freeze

  ICONS = {
    success: "✓",
    error: "✕",
    warning: "⚠",
    info: "ℹ"
  }.freeze

  def initialize(message:, variant: :info, dismissible: false, icon: true, **attributes)
    @message = message
    @variant = variant.to_sym
    @dismissible = dismissible
    @show_icon = icon
    @attributes = attributes
  end

  def view_template
    return if @message.blank?

    alert_classes = [
      "alert",
      VARIANTS[@variant]
    ].compact.join(" ")

    # ARIA attributes for accessibility
    aria_attrs = {
      role: @variant == :error ? "alert" : "status",
      "aria-live": @variant == :error ? "assertive" : "polite"
    }

    div(class: alert_classes, **aria_attrs, **@attributes) do
      div(class: "flex items-center justify-between w-full") do
        div(class: "flex items-center gap-2") do
          if @show_icon && ICONS[@variant]
            span(class: "text-lg shrink-0", "aria-hidden": "true") { ICONS[@variant] }
          end
          
          div(class: "flex-1") do
            if @message.is_a?(String)
              span { @message }
            else
              # Support for HTML content or multiple messages
              @message
            end
          end
        end

        if @dismissible
          button(
            type: "button",
            class: "btn btn-circle btn-ghost ml-2 shrink-0",
            "aria-label": "Dismiss alert",
            "data-dismiss": "alert"
          ) do
            span("aria-hidden": "true") { "✕" }
          end
        end
      end
    end
  end
end
