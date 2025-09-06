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
    default_classes = "input input-bordered w-full"

    input(
      type: @type,
      name: @name,
      id: @id,
      value: @value,
      placeholder: @placeholder,
      required: @required,
      class: [ default_classes, @attributes[:class] ].compact.join(" "),
      **@attributes.except(:class)
    )
  end
end
