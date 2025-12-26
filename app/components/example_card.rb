# frozen_string_literal: true

# Example component demonstrating Phlex Kit usage
class Components::ExampleCard < Components::Card
  def initialize(title:)
    super(title: title, header_color: :primary)
  end

  def view_template(&block)
    super do
      div(class: "space-y-4") do
        render Components::Button.new(variant: :primary) { "Primary Action" }
        render Components::Button.new(variant: :secondary) { "Secondary Action" }

        # TODO: Refactor FormGroup and uncomment this section
        # div(class: "form-group") do
        #   label(class: "label") { "Example Input" }
        #   input(type: "text", name: "example", placeholder: "Enter something...", class: "input input-bordered w-full")
        # end
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
