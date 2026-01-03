# frozen_string_literal: true

module Components
  module Dos
    class FnBar < Components::Base
      FUNCTION_KEYS = [
        { key: "F1", label: "Help", action: "help" },
        { key: "F2", label: "New", action: "new" },
        { key: "F3", label: "Edit", action: "edit" },
        { key: "F5", label: "Refresh", action: "refresh" },
        { key: "F10", label: "Quit", action: "logout" }
      ].freeze

      def view_template
        div(
          class: "fixed bottom-0 left-0 right-0 z-50 border-t border-border-default bg-surface",
          data: {
            controller: "fn-bar",
            action: "keydown@window->fn-bar#handleKeydown"
          }
        ) do
          div(class: "flex items-center justify-center gap-0 px-2 py-1") do
            FUNCTION_KEYS.each do |fn|
              function_key_button(fn)
            end
          end
        end
      end

      private

      def function_key_button(fn)
        button(
          type: "button",
          class: button_classes,
          data: {
            action: "click->fn-bar#execute",
            "fn-bar-action-param": fn[:action]
          }
        ) do
          span(class: "text-inverse bg-accent px-1 font-mono text-xs") { fn[:key] }
          span(class: "text-body font-mono text-xs px-2") { fn[:label] }
        end
      end

      def button_classes
        "flex items-center border-r border-border-light last:border-r-0 " \
          "hover:bg-surface-alt focus:outline-none focus:bg-surface-alt " \
          "transition-colors cursor-pointer select-none"
      end
    end
  end
end
