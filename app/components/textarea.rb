# frozen_string_literal: true

class Components::Textarea < Components::Base
  SIZES = {
    xs: "textarea-xs",
    sm: "textarea-sm",
    md: nil,
    lg: "textarea-lg"
  }.freeze

  def initialize(name: nil, value: nil, placeholder: nil, rows: 3, required: false, error: nil, id: nil, size: :md, **attributes)
    @name = name
    @value = value
    @placeholder = placeholder
    @rows = rows
    @required = required
    @error = error
    @id = id
    @size = size
    @attributes = attributes
  end

  def view_template
    div(class: "form-control w-full") do
      textarea(
        **textarea_attributes
      ) { @value }
      render_error_message if @error
    end
  end

  private

  def textarea_attributes
    attrs = {
      name: @name,
      id: @id || generate_id_from_name(@name),
      class: textarea_classes,
      placeholder: @placeholder,
      rows: @rows
    }

    attrs[:required] = "required" if @required
    attrs.merge!(@attributes.except(:class))
    attrs.compact
  end

  def textarea_classes
    base_classes = [ "textarea", "textarea-bordered", "w-full", SIZES[@size] ]
    base_classes << "textarea-error" if @error
    custom_classes = @attributes[:class]

    [ base_classes, custom_classes ].flatten.compact.join(" ")
  end

  def render_error_message
    div(class: "label-text-alt text-error mt-1") { @error }
  end
end
