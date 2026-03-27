# frozen_string_literal: true

# Example component demonstrating Phlex Kit usage
class Components::ExampleCard < Components::Card
  def initialize(title:)
    super(title: title)
  end

  def view_template(&block)
    super do
      div(class: "space-y-4") do
        render Components::Button.new(variant: :primary) { "Primary Action" }
        render Components::Button.new(variant: :secondary) { "Secondary Action" }
      end

      if block_given?
        div(class: "ui-divider")
        div do
          yield
        end
      end
    end
  end
end
