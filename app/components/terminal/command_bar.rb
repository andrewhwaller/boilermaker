# frozen_string_literal: true

module Components
  module Terminal
    class CommandBar < Components::Base
      def initialize(placeholder: "Type / to search or : for commands...")
        @placeholder = placeholder
      end

      def view_template
        div(
          class: "fixed bottom-0 left-0 right-0 z-50 border-t border-border-default bg-surface",
          data: {
            controller: "command-bar",
            action: "keydown@window->command-bar#handleGlobalKeydown"
          }
        ) do
          div(class: "flex items-center gap-2 px-4 py-2") do
            prompt_indicator
            command_input
            status_indicator
          end
        end
      end

      private

      def prompt_indicator
        span(
          class: "text-accent font-mono text-sm select-none",
          data: { "command-bar-target": "prompt" }
        ) { ">" }
      end

      def command_input
        input(
          type: "text",
          class: input_classes,
          placeholder: @placeholder,
          autocomplete: "off",
          spellcheck: "false",
          data: {
            "command-bar-target": "input",
            action: "keydown->command-bar#handleKeydown input->command-bar#handleInput"
          }
        )
      end

      def input_classes
        "flex-1 bg-transparent border-none text-body font-mono text-sm " \
          "placeholder:text-muted focus:outline-none focus:ring-0"
      end

      def status_indicator
        div(
          class: "flex items-center gap-3 text-muted text-xs font-mono",
          data: { "command-bar-target": "status" }
        ) do
          span { "/" }
          span(class: "text-muted") { "search" }
          span { "|" }
          span { ":" }
          span(class: "text-muted") { "cmd" }
        end
      end
    end
  end
end
