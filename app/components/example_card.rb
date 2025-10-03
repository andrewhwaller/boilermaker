# frozen_string_literal: true

# Example component demonstrating Phlex Kit usage
class Components::ExampleCard < Components::Base
  def initialize(title:)
    @title = title
  end

  def view_template(&block)
    div(class: "bg-base-200 border border-base-300") do
      div(class: "bg-primary/20 border-b border-primary/30 px-3 py-1") do
        h3(class: "text-xs font-bold text-primary uppercase tracking-wide") { @title }
      end

      div(class: "p-6") do
        div(class: "space-y-4") do
          Button(variant: :primary) { "Primary Action" }
          Button(variant: :secondary) { "Secondary Action" }

          FormGroup(
            label_text: "Example Input",
            input_type: :text,
            name: "example",
            placeholder: "Enter something..."
          )
        end

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
