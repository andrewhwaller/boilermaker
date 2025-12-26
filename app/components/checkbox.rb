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
      label(class: "flex items-center gap-2") do
        input(**checkbox_attributes)
        span(class: label_classes) { @label } if @label
      end
      render_error_message if @error
    end
  end

  private

  def checkbox_attributes
    attrs = {
      type: "checkbox",
      name: @name,
      id: @id || generate_id_from_name(@name),
      value: @value,
      checked: @checked,
      required: (@required ? "required" : nil)
    }

    # Merge classes properly
    all_classes = checkbox_classes
    if @attributes[:class]
      all_classes += Array(@attributes[:class])
    end
    attrs[:class] = all_classes

    # Add other attributes
    attrs.merge!(@attributes.except(:class))
    attrs.compact
  end

  private

  def label_classes
    css_classes("label-text", @error ? "text-destructive" : nil)
  end

  def checkbox_classes
    css_classes("checkbox", error_classes_for("checkbox"))
  end
end
