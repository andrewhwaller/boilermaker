# frozen_string_literal: true

# Command line input with prompt
# Renders an input field with a command-line style prompt prefix
class Components::Boilermaker::CommandInput < Components::Boilermaker::Base
  def initialize(prompt: ">", placeholder: "type command...", name: "command", **attributes)
    @prompt = prompt
    @placeholder = placeholder
    @name = name
    @attributes = attributes
  end

  def view_template
    div(**@attributes, class: css_classes("flex items-center gap-2 bg-body text-surface p-3 font-mono")) {
      span(class: "text-muted flex-shrink-0") { @prompt }
      input(
        type: "text",
        name: @name,
        placeholder: @placeholder,
        class: "flex-1 bg-transparent border-none outline-none text-surface placeholder:text-muted/50"
      )
    }
  end
end
