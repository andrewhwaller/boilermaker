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
    input_classes = "block w-full border border-border bg-background px-4 py-2 text-foreground " \
                   "focus:border-primary focus:outline-none focus:ring-2 focus:ring-primary/20"

    input(
      type: @type,
      name: @name,
      id: @id,
      value: @value,
      placeholder: @placeholder,
      required: @required,
      class: input_classes,
      **@attributes
    )
  end
end
