# frozen_string_literal: true

# PasswordField - A specialized form group for password inputs
# Includes proper autocomplete attributes and security best practices
class Components::PasswordField < Components::Base
  def initialize(label_text:, name:, id: nil, required: false, autocomplete: nil, help_text: nil, **input_attrs)
    @label_text = label_text
    @name = name
    @id = id || generate_id_from_name(name)
    @required = required
    @autocomplete = autocomplete || determine_autocomplete(name)
    @help_text = help_text
    @input_attrs = input_attrs
  end

  def view_template
    FormGroup(
      label_text: @label_text,
      input_type: :password,
      name: @name,
      id: @id,
      required: @required,
      autocomplete: @autocomplete,
      help_text: @help_text,
      **@input_attrs
    )
  end

  private

  def determine_autocomplete(name)
    case name.to_s
    when /current.*password|password_challenge/
      "current-password"
    when /new.*password|password(?!.*confirmation)/
      "new-password"
    when /password.*confirmation|confirm.*password/
      "new-password"
    else
      "current-password"
    end
  end
end
