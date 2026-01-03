# frozen_string_literal: true

require "test_helper"
require_relative "component_test_case"

class CheckboxTest < ComponentTestCase
  test "renders basic checkbox with minimal configuration" do
    component = Components::Checkbox.new

    assert_renders_successfully component
    assert_produces_output component
    assert_has_tag component, "input"
    assert_has_css_class component, "ui-checkbox"
  end

  test "renders checkbox with form control wrapper" do
    component = Components::Checkbox.new

    assert_has_css_class component, "form-control"
  end

  test "renders checkbox inside label for accessibility" do
    component = Components::Checkbox.new

    doc = render_and_parse(component)
    label = doc.css("label").first
    checkbox = label.css("input[type='checkbox']").first

    assert label, "Checkbox should be wrapped in a label"
    assert checkbox, "Checkbox input should be inside the label"
  end

  test "applies checkbox classes correctly" do
    component = Components::Checkbox.new

    assert_has_css_class component, "ui-checkbox"
  end

  test "renders with name attribute" do
    component = Components::Checkbox.new(name: "agree_terms")

    assert_has_attributes component, "input[type='checkbox']", { name: "agree_terms" }
  end

  test "renders with default value of '1'" do
    component = Components::Checkbox.new

    assert_has_attributes component, "input[type='checkbox']", { value: "1" }
  end

  test "renders with custom value" do
    component = Components::Checkbox.new(value: "yes")

    assert_has_attributes component, "input[type='checkbox']", { value: "yes" }
  end

  test "renders unchecked by default" do
    component = Components::Checkbox.new

    doc = render_and_parse(component)
    checkbox = doc.css("input[type='checkbox']").first
    assert_nil checkbox["checked"]
  end

  test "renders checked when checked is true" do
    component = Components::Checkbox.new(checked: true)

    assert_has_attributes component, "input[type='checkbox']", { checked: "checked" }
  end

  test "renders with label text" do
    component = Components::Checkbox.new(label: "I agree to the terms")

    assert_has_text component, "I agree to the terms"
    assert_has_css_class component, "label-text"
  end

  test "renders without label span when no label provided" do
    component = Components::Checkbox.new

    doc = render_and_parse(component)
    label_text = doc.css(".label-text")
    assert_equal 0, label_text.length
  end

  test "generates id from name when id not provided" do
    component = Components::Checkbox.new(name: "user[active]")

    assert_has_attributes component, "input[type='checkbox']", { id: "user_active" }
  end

  test "renders with custom id attribute" do
    component = Components::Checkbox.new(id: "custom-checkbox")

    assert_has_attributes component, "input[type='checkbox']", { id: "custom-checkbox" }
  end

  test "renders with required attribute when required is true" do
    component = Components::Checkbox.new(required: true)

    assert_has_attributes component, "input[type='checkbox']", { required: "required" }
  end

  test "does not render required attribute when required is false" do
    component = Components::Checkbox.new(required: false)

    doc = render_and_parse(component)
    checkbox = doc.css("input[type='checkbox']").first
    assert_nil checkbox["required"]
  end

  test "applies custom CSS classes alongside base classes" do
    component = Components::Checkbox.new(class: "custom-checkbox")

    doc = render_and_parse(component)
    checkbox = doc.css("input[type='checkbox']").first
    classes = checkbox["class"].split(" ")

    assert_includes classes, "ui-checkbox"
    assert_includes classes, "custom-checkbox"
  end

  test "renders error state with error class" do
    component = Components::Checkbox.new(error: "This field is required")

    assert_has_css_class component, "ui-checkbox-error"
  end

  test "displays error message when error provided" do
    component = Components::Checkbox.new(error: "This field is required")

    assert_has_text component, "This field is required"
  end

  test "does not render error message when no error" do
    component = Components::Checkbox.new

    assert_no_css_class component, "text-error"
  end

  test "renders with custom HTML attributes" do
    component = Components::Checkbox.new(
      data_controller: "checkbox",
      data_action: "click->checkbox#toggle"
    )

    assert_has_attributes component, "input[type='checkbox']", {
      "data-controller" => "checkbox",
      "data-action" => "click->checkbox#toggle"
    }
  end

  test "renders complete checkbox with all features" do
    component = Components::Checkbox.new(
      name: "user[newsletter]",
      value: "subscribe",
      checked: true,
      label: "Subscribe to newsletter",
      required: true,
      id: "newsletter-checkbox",
      class: "newsletter-cb",
      data_controller: "newsletter"
    )

    assert_renders_successfully component

    # Check structure
    assert_has_css_class component, "form-control"

    # Check checkbox attributes
    assert_has_attributes component, "input[type='checkbox']", {
      name: "user[newsletter]",
      id: "newsletter-checkbox",
      value: "subscribe",
      checked: "checked",
      required: "required",
      "data-controller" => "newsletter"
    }

    # Check label
    assert_has_text component, "Subscribe to newsletter"

    # Check classes
    doc = render_and_parse(component)
    checkbox = doc.css("input[type='checkbox']").first
    classes = checkbox["class"].split(" ")
    assert_includes classes, "ui-checkbox"
    assert_includes classes, "newsletter-cb"
  end

  test "accessibility: label and input are properly associated" do
    component = Components::Checkbox.new(
      name: "terms",
      label: "I agree to the terms",
      id: "terms-checkbox"
    )

    doc = render_and_parse(component)
    label = doc.css("label").first
    checkbox = doc.css("input[type='checkbox']").first

    # Check that checkbox is inside label (implicit association)
    label_checkbox = label.css("input[type='checkbox']").first
    assert label_checkbox, "Checkbox should be inside label for accessibility"
    assert_equal "terms-checkbox", label_checkbox["id"]
  end

  test "handles boolean checked values correctly" do
    checked_component = Components::Checkbox.new(checked: true)
    unchecked_component = Components::Checkbox.new(checked: false)

    # Checked should have checked attribute
    doc_checked = render_and_parse(checked_component)
    checked_checkbox = doc_checked.css("input[type='checkbox']").first
    assert_equal "checked", checked_checkbox["checked"]

    # Unchecked should not have checked attribute
    doc_unchecked = render_and_parse(unchecked_component)
    unchecked_checkbox = doc_unchecked.css("input[type='checkbox']").first
    assert_nil unchecked_checkbox["checked"]
  end

  test "Rails form integration patterns work correctly" do
    # Test typical Rails form patterns
    component = Components::Checkbox.new(
      name: "user[active]",
      value: "1",
      checked: false,
      label: "Account is active",
      required: true
    )

    assert_has_attributes component, "input[type='checkbox']", {
      name: "user[active]",
      id: "user_active",
      value: "1"
    }

    assert_has_text component, "Account is active"
    assert_has_attributes component, "input[type='checkbox']", { required: "required" }

    # Should not be checked
    doc = render_and_parse(component)
    checkbox = doc.css("input[type='checkbox']").first
    assert_nil checkbox["checked"]
  end

  test "handles edge cases gracefully" do
    # Empty name
    empty_name_component = Components::Checkbox.new(name: "")
    assert_renders_successfully empty_name_component

    # Nil label
    nil_label_component = Components::Checkbox.new(label: nil)
    assert_renders_successfully nil_label_component

    # Empty label
    empty_label_component = Components::Checkbox.new(label: "")
    assert_renders_successfully empty_label_component
    assert_has_text empty_label_component, ""
  end
end
