# frozen_string_literal: true

class Components::Textarea < Components::Base
  include FormErrorHandling
  def initialize(name: nil, value: nil, placeholder: nil, rows: 3, required: false, error: nil, id: nil, **attributes)
    @name = name
    @value = value
    @placeholder = placeholder
    @rows = rows
    @required = required
    @error = error
    @id = id
    @attributes = attributes
  end

  def view_template
    div(class: "form-control") do
      textarea(**textarea_attributes) { @value }
      render_error_message if @error
    end
  end

  private

  def textarea_attributes
    attrs = {
      name: @name,
      id: @id || generate_id_from_name(@name),
      placeholder: @placeholder,
      rows: @rows
    }

    attrs[:required] = "required" if @required

    # Merge classes properly
    all_classes = textarea_classes
    if @attributes[:class]
      all_classes += Array(@attributes[:class])
    end
    attrs[:class] = all_classes

    # Add other attributes
    attrs.merge!(@attributes.except(:class))
    attrs.compact
  end

  def textarea_classes
    css_classes("textarea", "textarea-bordered", "w-full", error_classes_for("textarea"))
  end
end
