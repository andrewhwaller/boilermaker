# frozen_string_literal: true

# Example component demonstrating Phlex Kit usage
class Components::ExampleCard < Components::Base
  def initialize(title:)
    @title = title
  end

  def view_template(&block)
    div(class: "card bg-base-100 border border-base-300 shadow-sm") do
      div(class: "card-body") do
        h3(class: "card-title") { @title }

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
          div(class: "divider")
          div do
            yield
          end
        end
      end
    end
  end
end
