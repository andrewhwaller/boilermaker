# frozen_string_literal: true

module Components
  module Brutalist
    class KeyboardHint < Components::Base
      def initialize(keys:, action:, inline: true)
        @keys = Array(keys)
        @action = action
        @inline = inline
      end

      def view_template
        span(
          class: container_classes,
          data: {
            controller: "keyboard-hint",
            "keyboard-hint-keys-value": @keys.join("+"),
            "keyboard-hint-action-value": @action
          }
        ) do
          render_keys
          render_action if @inline
        end
      end

      private

      def container_classes
        base = "inline-flex items-center gap-1 font-mono"
        @inline ? "#{base} text-xs" : "#{base} text-sm"
      end

      def render_keys
        @keys.each_with_index do |key, index|
          key_badge(key)
          plus_separator if index < @keys.length - 1
        end
      end

      def key_badge(key)
        kbd(class: key_classes) { format_key(key) }
      end

      def key_classes
        "inline-flex items-center justify-center min-w-[1.5rem] h-5 px-1 " \
          "border border-border-default bg-surface-alt text-body " \
          "text-[10px] font-mono font-medium uppercase tracking-wide"
      end

      def plus_separator
        span(class: "text-muted text-[10px]") { "+" }
      end

      def render_action
        span(class: "text-muted ml-1") { @action }
      end

      def format_key(key)
        key_map = {
          "meta" => "",
          "cmd" => "",
          "command" => "",
          "ctrl" => "^",
          "control" => "^",
          "alt" => "",
          "option" => "",
          "shift" => "",
          "enter" => "",
          "return" => "",
          "esc" => "esc",
          "escape" => "esc",
          "tab" => "",
          "space" => "spc",
          "backspace" => "",
          "delete" => "del"
        }

        key_map[key.downcase] || key.upcase
      end
    end
  end
end
