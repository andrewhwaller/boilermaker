# frozen_string_literal: true

require_relative "component_test_case"

class FormGroupTest < ComponentTestCase
  test "uses provided id when given" do
    form_group = Components::FormGroup.new(
      label_text: "Email",
      name: :email,
      id: "custom-email-field"
    )

    assert_equal "custom-email-field", form_group.instance_variable_get(:@id)
  end

  test "generates id from name when not provided" do
    form_group = Components::FormGroup.new(
      label_text: "Email",
      name: :user_email
    )

    # Should use generate_id_from_name
    assert_equal "user_email", form_group.instance_variable_get(:@id)
  end

  test "generates id from complex name with brackets" do
    form_group = Components::FormGroup.new(
      label_text: "Email",
      name: "user[profile][email]"
    )

    # Should clean up brackets to underscores
    assert_equal "user_profile_email", form_group.instance_variable_get(:@id)
  end

  test "stores all initialization parameters correctly" do
    form_group = Components::FormGroup.new(
      label_text: "Password",
      name: :password,
      input_type: :password,
      required: true,
      help_text: "Must be 8+ characters",
      placeholder: "Enter password"
    )

    assert_equal "Password", form_group.instance_variable_get(:@label_text)
    assert_equal :password, form_group.instance_variable_get(:@name)
    assert_equal :password, form_group.instance_variable_get(:@input_type)
    assert form_group.instance_variable_get(:@required)
    assert_equal "Must be 8+ characters", form_group.instance_variable_get(:@help_text)
    assert_equal({ placeholder: "Enter password" }, form_group.instance_variable_get(:@input_attrs))
  end

  test "defaults to text input type when not specified" do
    form_group = Components::FormGroup.new(
      label_text: "Name",
      name: :name
    )

    assert_equal :text, form_group.instance_variable_get(:@input_type)
  end

  test "defaults required to false when not specified" do
    form_group = Components::FormGroup.new(
      label_text: "Name",
      name: :name
    )

    refute form_group.instance_variable_get(:@required)
  end
end
