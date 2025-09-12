# frozen_string_literal: true

class Components::Checkbox < Components::Base
  SIZES = {
    xs: "checkbox-xs",
    sm: "checkbox-sm",
    md: nil,
    lg: "checkbox-lg"
  }.freeze

  def initialize(name: nil, value: "1", checked: false, label: nil, required: false, error: nil, id: nil, size: :md, **attributes)
    @name = name
    @value = value
    @checked = checked
    @label = label
    @required = required
    @error = error
    @id = id
    @size = size
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
          **@attributes.except(:class)
        )
      end
      render_error_message if @error
    end
  end

  private

  def label_classes
    base_classes = [ "label-text" ]
    base_classes << "text-error" if @error
    base_classes.join(" ")
  end

  def checkbox_classes
    base_classes = [ "checkbox", SIZES[@size] ]
    base_classes << "checkbox-error" if @error
    custom_classes = @attributes[:class]

    [ base_classes, custom_classes ].flatten.compact.join(" ")
  end

  def render_error_message
    div(class: "label-text-alt text-error mt-1") { @error }
  end
end
