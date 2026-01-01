# frozen_string_literal: true

# Header with $ prompt prefix (terminal-style)
# Renders: $ command_text
class Components::Boilermaker::PromptHeader < Components::Boilermaker::Base
  def initialize(text:, **attributes)
    @text = text
    @attributes = attributes
  end

  def view_template
    div(**@attributes, class: css_classes("text-sm")) {
      span(class: "text-accent") { "$ " }
      span(class: "text-muted") { @text }
    }
  end
end
