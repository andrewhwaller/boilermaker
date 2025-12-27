# frozen_string_literal: true

require_relative "component_test_case"
require_relative "test_helpers"

class FormFieldTest < ComponentTestCase
  include ComponentTestHelpers

  # Test basic form field rendering
  test "renders form field with required elements" do
    form_field = Components::FormField.new(
      label_text: "Email Address",
      name: "user[email]"
    )

    assert_renders_successfully(form_field)
    assert_produces_output(form_field)

    # Should have container div
    assert_has_css_class(form_field, "form-control")

    # Should have label and input elements
    assert_has_tag(form_field, "label")
    assert_has_tag(form_field, "input")
  end

  # Test form classes
  test "applies correct form styling" do
    form_field = Components::FormField.new(
      label_text: "Username",
      name: "user[username]"
    )

    assert_daisy_form_classes(form_field, [ "form-control" ])
  end

  # Test label generation and association
  test "generates label correctly associated with input" do
    form_field = Components::FormField.new(
      label_text: "Email Address",
      name: "user[email]"
    )

    doc = render_and_parse(form_field)
    label = doc.css("label").first
    input = doc.css("input").first

    assert label, "Should render label element"
    assert input, "Should render input element"

    # Label should have 'for' attribute matching input 'id'
    assert_equal label["for"], input["id"],
      "Label 'for' attribute should match input 'id'"

    # Should contain the label text
    assert_includes label.text, "Email Address"
  end

  # Test ID generation from form field names
  test "generates proper ID from Rails form field names" do
    test_cases = [
      { name: "user[email]", expected_id: "user_email" },
      { name: "account[settings][timezone]", expected_id: "account_settings_timezone" },
      { name: "post[tags][]", expected_id: "post_tags" },
      { name: "simple_field", expected_id: "simple_field" }
    ]

    test_cases.each do |test_case|
      form_field = Components::FormField.new(
        label_text: "Test Field",
        name: test_case[:name]
      )

      assert_has_attributes(form_field, "input", {
        id: test_case[:expected_id],
        name: test_case[:name]
      })
    end
  end

  # Test custom ID override
  test "accepts custom ID override" do
    form_field = Components::FormField.new(
      label_text: "Email",
      name: "user[email]",
      id: "custom-email-field"
    )

    assert_has_attributes(form_field, "input", { id: "custom-email-field" })
    assert_has_attributes(form_field, "label", { for: "custom-email-field" })
  end

  # Test different input types
  test "handles different input types" do
    input_types = [ :text, :email, :password, :tel, :url, :search, :number ]

    input_types.each do |input_type|
      form_field = Components::FormField.new(
        label_text: "Test Field",
        name: "test_field",
        input_type: input_type
      )

      assert_has_attributes(form_field, "input", {
        type: input_type.to_s,
        name: "test_field"
      })
    end
  end

  # Test required field handling
  test "handles required fields correctly" do
    # Test required: true
    required_field = Components::FormField.new(
      label_text: "Required Field",
      name: "required_field",
      required: true
    )

    doc = render_and_parse(required_field)
    input = doc.css("input").first

    assert input.has_attribute?("required"),
      "Required field should have required attribute"

    # Test required: false (default)
    optional_field = Components::FormField.new(
      label_text: "Optional Field",
      name: "optional_field",
      required: false
    )

    doc_optional = render_and_parse(optional_field)
    input_optional = doc_optional.css("input").first

    refute input_optional.has_attribute?("required"),
      "Optional field should not have required attribute"
  end

  # Test help text functionality
  test "renders help text when provided" do
    form_field = Components::FormField.new(
      label_text: "Password",
      name: "user[password]",
      help_text: "Must be at least 8 characters long"
    )

    assert_has_text(form_field, "Must be at least 8 characters long")

    # Should have proper help text styling
    assert_has_css_class(form_field, "label-text-alt")
  end

  test "does not render help text container when not provided" do
    form_field = Components::FormField.new(
      label_text: "Username",
      name: "user[username]"
    )

    # Should not have extra label elements for help text
    doc = render_and_parse(form_field)
    labels = doc.css("label")

    # Should have exactly one label (the main field label)
    # Help text would create a second label element
    assert_equal 1, labels.length, "Should have only one label when no help text"
  end

  # Test input attribute passing
  test "passes through custom input attributes" do
    form_field = Components::FormField.new(
      label_text: "Email",
      name: "user[email]",
      placeholder: "Enter your email address",
      class: "custom-input-class",
      data: { validate: "email" },
      maxlength: 100
    )

    assert_has_attributes(form_field, "input", {
      placeholder: "Enter your email address",
      maxlength: "100",
      "data-validate" => "email"
    })

    # Should include custom class
    doc = render_and_parse(form_field)
    input = doc.css("input").first
    assert_includes input["class"], "custom-input-class"
  end

  # Test Rails form integration scenarios
  test "integrates with Rails form helpers structure" do
    form_field = Components::FormField.new(
      label_text: "Account Name",
      name: "account[name]",
      input_type: :text,
      required: true,
      placeholder: "Enter account name"
    )

    doc = render_and_parse(form_field)

    # Structure should match Rails form expectations
    form_control = doc.css(".form-control").first
    assert form_control, "Should have form-control wrapper"

    label = form_control.css("label").first
    input = form_control.css("input").first

    assert label, "Should have label inside form-control"
    assert input, "Should have input inside form-control"

    # Should have proper Rails naming convention
    assert_equal "account[name]", input["name"]
    assert_equal "account_name", input["id"]
    assert_equal "account_name", label["for"]
  end

  # Test component composition with other components
  test "composes properly with Label and Input components" do
    form_field = Components::FormField.new(
      label_text: "Email",
      name: "user[email]",
      required: true
    )

    # Verify that it renders using the Label and Input components
    html = render_component(form_field)

    # Should contain structures that would come from Label component
    assert html.include?("label"), "Should use Label component"

    # Should contain structures that would come from Input component
    assert html.include?("input"), "Should use Input component"
    assert html.include?('type="text"'), "Should have default text input type"
  end

  # Test error handling and edge cases
  test "handles empty label text gracefully" do
    form_field = Components::FormField.new(
      label_text: "",
      name: "test_field"
    )

    assert_renders_successfully(form_field)

    doc = render_and_parse(form_field)
    label = doc.css("label").first

    # Label should still be present but may be empty
    assert label, "Should render label element even with empty text"
  end

  test "handles nil values gracefully" do
    form_field = Components::FormField.new(
      label_text: "Test Field",
      name: "test_field",
      help_text: nil,
      id: nil
    )

    assert_renders_successfully(form_field)

    # Should generate ID from name when id is nil
    assert_has_attributes(form_field, "input", { id: "test_field" })
  end

  # Test complex form field scenarios
  test "handles complex nested form field names" do
    form_field = Components::FormField.new(
      label_text: "Billing Address",
      name: "user[addresses_attributes][0][street]",
      input_type: :text,
      required: true,
      help_text: "Enter your full street address"
    )

    assert_renders_successfully(form_field)

    # Should generate clean ID from complex name
    expected_id = "user_addresses_attributes_0_street"
    assert_has_attributes(form_field, "input", {
      id: expected_id,
      name: "user[addresses_attributes][0][street]"
    })
    assert_has_attributes(form_field, "label", { for: expected_id })
  end

  # Test accessibility features
  test "maintains proper accessibility structure" do
    form_field = Components::FormField.new(
      label_text: "Email Address",
      name: "user[email]",
      input_type: :email,
      required: true,
      help_text: "We'll never share your email"
    )

    doc = render_and_parse(form_field)
    label = doc.css("label").first
    input = doc.css("input").first

    # Label-input association
    assert_equal input["id"], label["for"],
      "Label should be properly associated with input"

    # Required field indication
    assert input.has_attribute?("required"),
      "Required input should have required attribute"

    # Semantic input type
    assert_equal "email", input["type"],
      "Email field should have email input type"
  end

  # Test responsive design classes
  test "applies responsive width classes" do
    form_field = Components::FormField.new(
      label_text: "Full Name",
      name: "user[name]"
    )

    # Form control should be responsive (width is handled by CSS)
    assert_has_css_class(form_field, "form-control")
  end
end
