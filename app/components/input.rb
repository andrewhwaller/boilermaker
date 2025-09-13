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
    input(
      type: @type,
      name: @name,
      id: @id,
      value: @value,
      placeholder: @placeholder,
      required: @required,
      class: css_classes("input", "input-bordered", "w-full"),
      **filtered_attributes
    )
  end
end
