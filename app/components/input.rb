# frozen_string_literal: true

class Components::Input < Components::Base
  def initialize(type: :text, name: nil, id: nil, value: nil, placeholder: nil, required: false, **attributes)
    @type = type
    @name = name
    @id = id
    @value = value
    @placeholder = placeholder
    @required = required
    @attributes = attributes
  end

  def view_template
    input(**input_attributes)
  end

  private

  def input_attributes
    attrs = {
      type: @type,
      name: @name,
      id: @id,
      value: @value,
      placeholder: @placeholder,
      required: @required
    }

    # Merge classes properly
    all_classes = [ "input", "input-bordered", "w-full" ]
    if @attributes[:class]
      all_classes += Array(@attributes[:class])
    end
    attrs[:class] = all_classes

    # Add other attributes
    attrs.merge!(@attributes.except(:class))
    attrs.compact
  end
end
