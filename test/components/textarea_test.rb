# frozen_string_literal: true

require "test_helper"
require_relative "component_test_case"

class TextareaTest < ComponentTestCase
  test "renders basic textarea with minimal configuration" do
    component = Components::Textarea.new

    assert_renders_successfully component
    assert_produces_output Components::Textarea.new
    assert_has_tag Components::Textarea.new, "textarea"
    assert_has_css_class Components::Textarea.new, "textarea"
  end

  test "renders textarea with form control wrapper" do
    component = Components::Textarea.new

    assert_has_css_class component, "form-control"
    assert_has_css_class Components::Textarea.new, "w-full"
  end

  test "applies Daisy UI textarea classes correctly" do
    component = Components::Textarea.new

    assert_daisy_form_classes component, [ "textarea", "textarea-bordered", "w-full" ]
  end

  test "renders with name attribute" do
    component = Components::Textarea.new(name: "comment")

    assert_has_attributes component, "textarea", { name: "comment" }
  end

  test "renders with value content" do
    component = Components::Textarea.new(value: "Hello World")

    assert_has_text component, "Hello World"
  end

  test "renders with placeholder attribute" do
    component = Components::Textarea.new(placeholder: "Enter your comment...")

    assert_has_attributes component, "textarea", { placeholder: "Enter your comment..." }
  end

  test "renders with custom rows attribute" do
    component = Components::Textarea.new(rows: 5)

    assert_has_attributes component, "textarea", { rows: "5" }
  end

  test "defaults to 3 rows when not specified" do
    component = Components::Textarea.new

    assert_has_attributes component, "textarea", { rows: "3" }
  end

  test "renders with required attribute when required is true" do
    component = Components::Textarea.new(required: true)

    assert_has_attributes component, "textarea", { required: "required" }
  end

  test "does not render required attribute when required is false" do
    component = Components::Textarea.new(required: false)

    doc = render_and_parse(component)
    textarea = doc.css("textarea").first
    assert_nil textarea["required"]
  end

  test "renders with custom id attribute" do
    component = Components::Textarea.new(id: "custom-textarea")

    assert_has_attributes component, "textarea", { id: "custom-textarea" }
  end

  test "generates id from name when id not provided" do
    component = Components::Textarea.new(name: "user[comment]")

    assert_has_attributes component, "textarea", { id: "user_comment" }
  end

  test "renders with custom HTML attributes" do
    component = Components::Textarea.new(data_controller: "textarea", maxlength: 500)

    assert_has_attributes component, "textarea", {
      "data-controller" => "textarea",
      "maxlength" => "500"
    }
  end

  test "applies custom CSS classes alongside base classes" do
    component = Components::Textarea.new(class: "custom-class")

    doc = render_and_parse(component)
    textarea = doc.css("textarea").first
    classes = textarea["class"].split(" ")

    assert_includes classes, "textarea"
    assert_includes classes, "textarea-bordered"
    assert_includes classes, "w-full"
    assert_includes classes, "custom-class"
  end

  test "renders error state with error class" do
    component = Components::Textarea.new(error: "This field is required")

    assert_has_css_class component, "textarea-error"
  end

  test "displays error message when error provided" do
    component = Components::Textarea.new(error: "This field is required")

    assert_has_text component, "This field is required"
    assert_has_css_class Components::Textarea.new(error: "This field is required"), "text-error"
  end

  test "does not render error message when no error" do
    component = Components::Textarea.new

    assert_no_css_class component, "text-error"
  end

  test "error message has proper Daisy UI styling" do
    component = Components::Textarea.new(error: "Error message")

    doc = render_and_parse(component)
    error_element = doc.css(".text-error").first
    classes = error_element["class"].split(" ")

    assert_includes classes, "label-text-alt"
    assert_includes classes, "text-error"
    assert_includes classes, "mt-1"
  end

  test "renders complete textarea with all features" do
    component = Components::Textarea.new(
      name: "user[bio]",
      value: "Existing bio content",
      placeholder: "Tell us about yourself...",
      rows: 6,
      required: true,
      id: "user-bio",
      class: "bio-textarea",
      data_controller: "character-counter",
      maxlength: 1000
    )

    assert_renders_successfully component

    # Check structure
    assert_has_css_class Components::Textarea.new(
      name: "user[bio]",
      value: "Existing bio content",
      placeholder: "Tell us about yourself...",
      rows: 6,
      required: true,
      id: "user-bio",
      class: "bio-textarea",
      data_controller: "character-counter",
      maxlength: 1000
    ), "form-control"

    # Check textarea attributes
    component2 = Components::Textarea.new(
      name: "user[bio]",
      value: "Existing bio content",
      placeholder: "Tell us about yourself...",
      rows: 6,
      required: true,
      id: "user-bio",
      class: "bio-textarea",
      data_controller: "character-counter",
      maxlength: 1000
    )

    assert_has_attributes component2, "textarea", {
      name: "user[bio]",
      id: "user-bio",
      placeholder: "Tell us about yourself...",
      rows: "6",
      required: "required",
      "data-controller" => "character-counter",
      maxlength: "1000"
    }

    # Check content and classes
    component3 = Components::Textarea.new(
      name: "user[bio]",
      value: "Existing bio content",
      placeholder: "Tell us about yourself...",
      rows: 6,
      required: true,
      id: "user-bio",
      class: "bio-textarea",
      data_controller: "character-counter",
      maxlength: 1000
    )

    assert_has_text component3, "Existing bio content"

    component4 = Components::Textarea.new(
      name: "user[bio]",
      value: "Existing bio content",
      placeholder: "Tell us about yourself...",
      rows: 6,
      required: true,
      id: "user-bio",
      class: "bio-textarea",
      data_controller: "character-counter",
      maxlength: 1000
    )

    doc = render_and_parse(component4)
    textarea = doc.css("textarea").first
    classes = textarea["class"].split(" ")
    assert_includes classes, "bio-textarea"
    assert_includes classes, "textarea"
    assert_includes classes, "textarea-bordered"
  end

  test "handles empty and nil values gracefully" do
    empty_component = Components::Textarea.new(value: "")
    nil_component = Components::Textarea.new(value: nil)

    assert_renders_successfully empty_component
    assert_renders_successfully nil_component

    # Both should render textarea element
    assert_has_tag Components::Textarea.new(value: ""), "textarea"
    assert_has_tag Components::Textarea.new(value: nil), "textarea"
  end

  test "Rails form integration patterns work correctly" do
    # Test typical Rails form patterns
    component = Components::Textarea.new(
      name: "post[content]",
      value: "Draft content",
      required: true
    )

    assert_has_attributes component, "textarea", {
      name: "post[content]",
      id: "post_content"
    }

    assert_has_text Components::Textarea.new(name: "post[content]", value: "Draft content", required: true), "Draft content"
    assert_has_attributes Components::Textarea.new(name: "post[content]", value: "Draft content", required: true), "textarea", { required: "required" }
  end
end
