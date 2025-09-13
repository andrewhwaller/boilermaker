# frozen_string_literal: true

class Components::Checkbox < Components::Base
  include FormErrorHandling
  def initialize(name: nil, value: "1", checked: false, label: nil, required: false, error: nil, id: nil, **attributes)
    @name = name
    @value = value
    @checked = checked
    @label = label
    @required = required
    @error = error
    @id = id
    @attributes = attributes
  end

  def view_template
    div(class: "form-control") do
      label(class: "label cursor-pointer") do
        span(class: label_classes) { @label } if @label
        input(
          type: "checkbox",
          name: @name,
          id: @id || generate_id_from_name(@name),
          value: @value,
          checked: @checked,
          required: (@required ? "required" : nil),
          class: checkbox_classes,
          **filtered_attributes
        )
      end
      render_error_message if @error
    end
  end

  private

  def label_classes
    [ "label-text", (@error ? "text-error" : nil) ]
  end

  def checkbox_classes
    css_classes("checkbox", error_classes_for("checkbox"))
  end
end
