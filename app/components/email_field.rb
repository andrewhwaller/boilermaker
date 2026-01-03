# frozen_string_literal: true

# EmailField - A specialized form group for email inputs
# Includes proper validation and autocomplete attributes
class Components::EmailField < Components::Base
  def initialize(label_text: "Email", name: "email", id: nil, required: true, **input_attrs)
    @label_text = label_text
    @name = name
    @id = id || generate_id_from_name(name)
    @required = required
    @input_attrs = input_attrs
  end

  def view_template
    render Components::FormField.new(
      label_text: @label_text,
      input_type: :email,
      name: @name,
      id: @id,
      required: @required,
      autocomplete: "email",
      **@input_attrs
    )
  end
end
