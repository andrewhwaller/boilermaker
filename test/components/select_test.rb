# frozen_string_literal: true

require "test_helper"
require_relative "component_test_case"

class SelectTest < ComponentTestCase
  test "renders basic select with minimal configuration" do
    component = Components::Select.new

    assert_renders_successfully component
    assert_produces_output component
    assert_has_tag component, "select"
    assert_has_css_class component, "select"
  end

  test "renders select with form control wrapper" do
    component = Components::Select.new

    assert_has_css_class component, "form-control"
    assert_has_css_class component, "w-full"
  end

  test "applies Daisy UI select classes correctly" do
    component = Components::Select.new

    assert_daisy_form_classes component, [ "select", "select-bordered", "w-full" ]
  end

  test "renders with name attribute" do
    component = Components::Select.new(name: "category")

    assert_has_attributes component, "select", { name: "category" }
  end

  test "generates id from name when id not provided" do
    component = Components::Select.new(name: "user[role]")

    assert_has_attributes component, "select", { id: "user_role" }
  end

  test "renders with custom id attribute" do
    component = Components::Select.new(id: "custom-select")

    assert_has_attributes component, "select", { id: "custom-select" }
  end

  test "renders with required attribute when required is true" do
    component = Components::Select.new(required: true)

    assert_has_attributes component, "select", { required: "required" }
  end

  test "renders array options as text and value pairs" do
    options = [ "Red", "Green", "Blue" ]
    component = Components::Select.new(options: options)

    doc = render_and_parse(component)
    option_elements = doc.css("option")

    assert_equal 3, option_elements.length
    assert_equal "Red", option_elements[0].text
    assert_equal "Red", option_elements[0]["value"]
    assert_equal "Green", option_elements[1].text
    assert_equal "Green", option_elements[1]["value"]
    assert_equal "Blue", option_elements[2].text
    assert_equal "Blue", option_elements[2]["value"]
  end

  test "renders nested array options with different text and values" do
    options = [ [ "Red Color", "red" ], [ "Green Color", "green" ], [ "Blue Color", "blue" ] ]
    component = Components::Select.new(options: options)

    doc = render_and_parse(component)
    option_elements = doc.css("option")

    assert_equal 3, option_elements.length
    assert_equal "Red Color", option_elements[0].text
    assert_equal "red", option_elements[0]["value"]
    assert_equal "Green Color", option_elements[1].text
    assert_equal "green", option_elements[1]["value"]
    assert_equal "Blue Color", option_elements[2].text
    assert_equal "blue", option_elements[2]["value"]
  end

  test "renders hash options with keys as text and values as values" do
    options = { "Small" => "sm", "Medium" => "md", "Large" => "lg" }
    component = Components::Select.new(options: options)

    doc = render_and_parse(component)
    option_elements = doc.css("option")

    assert_equal 3, option_elements.length
    # Hash iteration order may vary, so check that all options are present
    texts = option_elements.map(&:text)
    values = option_elements.map { |opt| opt["value"] }

    assert_includes texts, "Small"
    assert_includes texts, "Medium"
    assert_includes texts, "Large"
    assert_includes values, "sm"
    assert_includes values, "md"
    assert_includes values, "lg"
  end

  test "marks selected option correctly with string values" do
    options = [ "Red", "Green", "Blue" ]
    component = Components::Select.new(options: options, selected: "Green")

    doc = render_and_parse(component)
    option_elements = doc.css("option")

    assert_nil option_elements[0]["selected"]
    assert_equal "selected", option_elements[1]["selected"]
    assert_nil option_elements[2]["selected"]
  end

  test "marks selected option correctly with different value types" do
    options = [ [ "One", 1 ], [ "Two", 2 ], [ "Three", 3 ] ]
    component = Components::Select.new(options: options, selected: 2)

    doc = render_and_parse(component)
    option_elements = doc.css("option")

    assert_nil option_elements[0]["selected"]
    assert_equal "selected", option_elements[1]["selected"]
    assert_nil option_elements[2]["selected"]
  end

  test "renders prompt option when provided" do
    options = [ "Red", "Green", "Blue" ]
    component = Components::Select.new(options: options, prompt: "Choose a color")

    doc = render_and_parse(component)
    option_elements = doc.css("option")

    # Should have prompt + 3 options = 4 total
    assert_equal 4, option_elements.length

    prompt_option = option_elements.first
    assert_equal "Choose a color", prompt_option.text
    assert_equal "", prompt_option["value"]
    assert_equal "disabled", prompt_option["disabled"]
    assert_equal "selected", prompt_option["selected"]
  end

  test "prompt is not selected when value is selected" do
    options = [ "Red", "Green", "Blue" ]
    component = Components::Select.new(options: options, prompt: "Choose a color", selected: "Red")

    doc = render_and_parse(component)
    option_elements = doc.css("option")

    prompt_option = option_elements.first
    red_option = option_elements[1]

    assert_nil prompt_option["selected"]
    assert_equal "selected", red_option["selected"]
  end

  test "applies custom CSS classes alongside base classes" do
    component = Components::Select.new(class: "custom-select")

    doc = render_and_parse(component)
    select = doc.css("select").first
    classes = select["class"].split(" ")

    assert_includes classes, "select"
    assert_includes classes, "select-bordered"
    assert_includes classes, "w-full"
    assert_includes classes, "custom-select"
  end

  test "renders error state with error class" do
    component = Components::Select.new(error: "Please select an option")

    assert_has_css_class component, "select-error"
  end

  test "displays error message when error provided" do
    component = Components::Select.new(error: "Please select an option")

    assert_has_text component, "Please select an option"
  end

  test "does not render error message when no error" do
    component = Components::Select.new

    assert_no_css_class component, "text-error"
  end

  test "renders with custom HTML attributes" do
    component = Components::Select.new(data_controller: "select", multiple: true)

    assert_has_attributes component, "select", {
      "data-controller" => "select",
      "multiple" => "multiple"
    }
  end

  test "renders complete select with all features" do
    options = [ [ "Small Size", "sm" ], [ "Medium Size", "md" ], [ "Large Size", "lg" ] ]
    component = Components::Select.new(
      name: "product[size]",
      options: options,
      selected: "md",
      prompt: "Select size",
      required: true,
      id: "product-size",
      class: "size-select",
      data_controller: "size-selector"
    )

    assert_renders_successfully component

    # Check structure
    assert_has_css_class component, "form-control"

    # Check select attributes
    assert_has_attributes component, "select", {
      name: "product[size]",
      id: "product-size",
      required: "required",
      "data-controller" => "size-selector"
    }

    # Check classes
    doc = render_and_parse(component)
    select = doc.css("select").first
    classes = select["class"].split(" ")
    assert_includes classes, "size-select"
    assert_includes classes, "select"
    assert_includes classes, "select-bordered"

    # Check options
    option_elements = doc.css("option")
    assert_equal 4, option_elements.length  # prompt + 3 options

    # Check prompt
    prompt_option = option_elements.first
    assert_equal "Select size", prompt_option.text
    assert_equal "disabled", prompt_option["disabled"]

    # Check selected option
    selected_option = doc.css("option[selected]").first
    assert_equal "Medium Size", selected_option.text
    assert_equal "md", selected_option["value"]
  end

  test "handles empty options gracefully" do
    component = Components::Select.new(options: [])

    assert_renders_successfully component
    assert_has_tag component, "select"

    doc = render_and_parse(component)
    option_elements = doc.css("option")
    assert_equal 0, option_elements.length
  end

  test "Rails form integration patterns work correctly" do
    # Test typical Rails form patterns
    options = { "Admin" => "admin", "User" => "user", "Guest" => "guest" }
    component = Components::Select.new(
      name: "user[role]",
      options: options,
      selected: "user",
      prompt: "Select role",
      required: true
    )

    assert_has_attributes component, "select", {
      name: "user[role]",
      id: "user_role"
    }

    assert_has_attributes component, "select", { required: "required" }

    # Check that user role is selected
    doc = render_and_parse(component)
    selected_option = doc.css("option[selected]").last  # Last because prompt might also be selected initially
    assert_equal "User", selected_option.text
    assert_equal "user", selected_option["value"]
  end
end
