# frozen_string_literal: true

# Example component demonstrating Phlex Kit usage
class Components::ExampleCard < Components::Base
  def initialize(title:)
    @title = title
  end

  def view_template(&block)
    div(class: "bg-surface border border-border rounded-lg p-6 shadow-sm") do
      h3(class: "text-lg font-semibold text-foreground mb-4") { @title }

      # Using Phlex Kit syntax - no need for `render` or `.new`
      div(class: "space-y-4") do
        # Clean component rendering with Kit
        Button(variant: :primary) { "Primary Action" }
        Button(variant: :secondary) { "Secondary Action" }

        # Form field example
        FormGroup(
          label_text: "Example Input",
          input_type: :text,
          name: "example",
          placeholder: "Enter something..."
        )
      end

      # Custom content block
      if block_given?
        div(class: "mt-4 pt-4 border-t border-border") do
          yield
        end
      end
    end
  end
end
