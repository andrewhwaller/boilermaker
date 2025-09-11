# frozen_string_literal: true

class Components::Toast < Components::Base
  VARIANTS = {
    success: "alert-success",
    error: "alert-error",
    warning: "alert-warning",
    info: "alert-info"
  }.freeze

  POSITIONS = {
    "top-start" => "toast-top toast-start",
    "top-center" => "toast-top toast-center", 
    "top-end" => "toast-top toast-end",
    "middle-start" => "toast-middle toast-start",
    "middle-center" => "toast-middle toast-center",
    "middle-end" => "toast-middle toast-end",
    "bottom-start" => "toast-bottom toast-start",
    "bottom-center" => "toast-bottom toast-center",
    "bottom-end" => "toast-bottom toast-end"
  }.freeze

  ICONS = {
    success: "✓",
    error: "✕", 
    warning: "⚠",
    info: "ℹ"
  }.freeze

  def initialize(message:, variant: :info, position: "top-end", duration: 5000, icon: true, **attributes)
    @message = message
    @variant = variant.to_sym
    @position = position.to_s
    @duration = duration
    @show_icon = icon
    @attributes = attributes
  end

  def view_template
    return if @message.blank?

    # Container for toast positioning
    toast_container_classes = [
      "toast",
      POSITIONS[@position] || POSITIONS["top-end"]
    ].compact.join(" ")

    # Individual toast alert classes
    alert_classes = [
      "alert",
      VARIANTS[@variant],
      "shadow-lg"
    ].compact.join(" ")

    # ARIA attributes for accessibility
    aria_attrs = {
      role: @variant == :error ? "alert" : "status",
      "aria-live": @variant == :error ? "assertive" : "polite",
      "aria-atomic": "true"
    }

    div(class: toast_container_classes) do
      div(
        class: alert_classes,
        **aria_attrs,
        **@attributes,
        **auto_dismiss_attributes
      ) do
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

          # Always include dismiss button for toasts
          button(
            type: "button",
            class: "btn btn-sm btn-circle btn-ghost ml-2 shrink-0",
            "aria-label": "Dismiss notification",
            "data-dismiss": "toast"
          ) do
            span("aria-hidden": "true") { "✕" }
          end
        end
      end
    end
  end

  private

  def auto_dismiss_attributes
    return {} if @duration <= 0

    {
      "data-controller": "toast",
      "data-toast-duration-value": @duration,
      "data-action": "toast:dismiss->toast#dismiss"
    }
  end
end