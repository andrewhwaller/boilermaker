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
    default_classes = "block border border-input-border bg-input px-3 py-1 text-foreground " \
                     "focus:border-accent focus:outline-none focus:ring-2 focus:ring-accent/20 " \
                     "placeholder:text-foreground-subtle transition-colors duration-200"

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
