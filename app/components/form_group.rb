# frozen_string_literal: true

# FormGroup - A shared component for consistent form field grouping
# Combines label, input, and optional help text with consistent spacing
class Components::FormGroup < Components::Base
  def initialize(label_text:, name:, input_type: :text, id: nil, required: false, help_text: nil, **input_attrs)
    @label_text = label_text
    @input_type = input_type
    @name = name
    @id = id || generate_id_from_name(name)
    @required = required
    @help_text = help_text
    @input_attrs = input_attrs
  end

  def view_template
    div(class: "form-control w-full") do
      Label(for_id: @id, required: @required) { @label_text }

      Input(
        type: @input_type,
        name: @name,
        id: @id,
        required: @required,
        **@input_attrs
      )

      if @help_text.present?
        label(class: "label") do
          span(class: "label-text-alt") { @help_text }
        end
      end
    end
  end
end
