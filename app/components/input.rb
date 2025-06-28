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
    default_classes = "block border border-border bg-background px-3 py-1 text-foreground " \
                     "focus:border-primary focus:outline-none focus:ring-2 focus:ring-primary/20"

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
