# frozen_string_literal: true

class Components::ImpersonationBanner < Components::Base
  include Phlex::Rails::Helpers::ButtonTo

  def view_template
    return unless impersonating?

    div(class: banner_classes) do
      div(class: "flex items-center justify-between max-w-7xl mx-auto px-4") do
        div(class: "flex items-center gap-3") do
          warning_icon
          span(class: "text-sm font-medium") do
            plain "You are impersonating "
            strong { Current.user.email }
          end
        end

        button_to stop_masquerade_path,
                  method: :delete,
                  class: exit_button_classes do
          "Exit Impersonation"
        end
      end
    end
  end

  private

  def impersonating?
    Current.session&.impersonator.present?
  end

  def banner_classes
    "fixed top-0 left-0 right-0 z-50 bg-warning text-warning-content py-2"
  end

  def exit_button_classes
    [
      "ui-button ui-button-sm",
      "bg-warning-content text-warning",
      "hover:bg-warning-content/90",
      "border-0"
    ].join(" ")
  end

  def warning_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      class: "h-5 w-5",
      viewBox: "0 0 20 20",
      fill: "currentColor"
    ) do |s|
      s.path(
        fill_rule: "evenodd",
        d: "M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z",
        clip_rule: "evenodd"
      )
    end
  end
end
