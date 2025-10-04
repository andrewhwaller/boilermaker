# frozen_string_literal: true

require "test_helper"
require_relative "component_test_case"

class RadioTest < ComponentTestCase
  test "renders basic radio group with minimal configuration" do
    component = Components::Radio.new

    assert_renders_successfully component
    assert_produces_output component
    assert_has_css_class component, "form-control"
  end

  test "renders radio group with form control wrapper" do
    component = Components::Radio.new

    assert_has_css_class component, "form-control"
  end

  test "renders no radio buttons when no options provided" do
    component = Components::Radio.new(options: [])

    doc = render_and_parse(component)
    radio_inputs = doc.css("input[type='radio']")
    assert_equal 0, radio_inputs.length
  end

  test "renders radio buttons for array of options" do
    options = [ [ "Red", "red" ], [ "Green", "green" ], [ "Blue", "blue" ] ]
    component = Components::Radio.new(options: options)

    doc = render_and_parse(component)
    radio_inputs = doc.css("input[type='radio']")
    assert_equal 3, radio_inputs.length
  end

  test "applies Daisy UI radio classes correctly" do
    options = [ [ "Red", "red" ], [ "Green", "green" ] ]
    component = Components::Radio.new(options: options)

    assert_has_css_class component, "radio"
  end

  test "renders radio buttons inside labels for accessibility" do
    options = [ [ "Red", "red" ], [ "Green", "green" ] ]
    component = Components::Radio.new(options: options)

    doc = render_and_parse(component)
    labels = doc.css("label")
    radio_inputs = doc.css("input[type='radio']")

    assert_equal 2, labels.length
    assert_equal 2, radio_inputs.length

    # Each radio should be inside a label
    labels.each do |label|
      radio_in_label = label.css("input[type='radio']")
      assert_equal 1, radio_in_label.length
    end
  end

  test "renders with name attribute for all radio buttons" do
    options = [ [ "Red", "red" ], [ "Green", "green" ], [ "Blue", "blue" ] ]
    component = Components::Radio.new(name: "color", options: options)

    doc = render_and_parse(component)
    radio_inputs = doc.css("input[type='radio']")

    radio_inputs.each do |radio|
      assert_equal "color", radio["name"]
    end
  end

  test "generates unique ids for each radio button" do
    options = [ [ "Red", "red" ], [ "Green", "green" ], [ "Blue", "blue" ] ]
    component = Components::Radio.new(name: "user[color]", options: options)

    doc = render_and_parse(component)
    radio_inputs = doc.css("input[type='radio']")

    assert_equal "user_color_0", radio_inputs[0]["id"]
    assert_equal "user_color_1", radio_inputs[1]["id"]
    assert_equal "user_color_2", radio_inputs[2]["id"]
  end

  test "renders correct values for radio buttons" do
    options = [ [ "Red Color", "red" ], [ "Green Color", "green" ], [ "Blue Color", "blue" ] ]
    component = Components::Radio.new(options: options)

    doc = render_and_parse(component)
    radio_inputs = doc.css("input[type='radio']")

    assert_equal "red", radio_inputs[0]["value"]
    assert_equal "green", radio_inputs[1]["value"]
    assert_equal "blue", radio_inputs[2]["value"]
  end

  test "renders correct labels for radio buttons" do
    options = [ [ "Red Color", "red" ], [ "Green Color", "green" ], [ "Blue Color", "blue" ] ]
    component = Components::Radio.new(options: options)

    doc = render_and_parse(component)
    label_texts = doc.css(".label-text")

    assert_equal 3, label_texts.length
    assert_equal "Red Color", label_texts[0].text
    assert_equal "Green Color", label_texts[1].text
    assert_equal "Blue Color", label_texts[2].text
  end

  test "marks selected radio button correctly" do
    options = [ [ "Red", "red" ], [ "Green", "green" ], [ "Blue", "blue" ] ]
    component = Components::Radio.new(options: options, selected: "green")

    doc = render_and_parse(component)
    radio_inputs = doc.css("input[type='radio']")

    assert_nil radio_inputs[0]["checked"]
    assert_equal "checked", radio_inputs[1]["checked"]
    assert_nil radio_inputs[2]["checked"]
  end

  test "handles string and numeric values for selection" do
    options = [ [ "One", 1 ], [ "Two", 2 ], [ "Three", 3 ] ]
    component = Components::Radio.new(options: options, selected: 2)

    doc = render_and_parse(component)
    radio_inputs = doc.css("input[type='radio']")

    assert_nil radio_inputs[0]["checked"]
    assert_equal "checked", radio_inputs[1]["checked"]
    assert_nil radio_inputs[2]["checked"]
  end

  test "applies required attribute to first radio button only" do
    options = [ [ "Red", "red" ], [ "Green", "green" ], [ "Blue", "blue" ] ]
    component = Components::Radio.new(options: options, required: true)

    doc = render_and_parse(component)
    radio_inputs = doc.css("input[type='radio']")

    assert_equal "required", radio_inputs[0]["required"]
    assert_nil radio_inputs[1]["required"]
    assert_nil radio_inputs[2]["required"]
  end

  test "does not apply required when required is false" do
    options = [ [ "Red", "red" ], [ "Green", "green" ] ]
    component = Components::Radio.new(options: options, required: false)

    doc = render_and_parse(component)
    radio_inputs = doc.css("input[type='radio']")

    radio_inputs.each do |radio|
      assert_nil radio["required"]
    end
  end

  test "applies custom CSS classes alongside base classes" do
    options = [ [ "Red", "red" ], [ "Green", "green" ] ]
    component = Components::Radio.new(options: options, class: "custom-radio")

    doc = render_and_parse(component)
    radio_inputs = doc.css("input[type='radio']")

    radio_inputs.each do |radio|
      classes = radio["class"].split(" ")
      assert_includes classes, "radio"
      assert_includes classes, "custom-radio"
    end
  end

  test "renders error state with error class" do
    options = [ [ "Red", "red" ], [ "Green", "green" ] ]
    component = Components::Radio.new(options: options, error: "Please select an option")

    assert_has_css_class component, "radio-error"
  end

  test "displays error message when error provided" do
    options = [ [ "Red", "red" ], [ "Green", "green" ] ]
    component = Components::Radio.new(options: options, error: "Please select an option")

    assert_has_text component, "Please select an option"
  end

  test "does not render error message when no error" do
    options = [ [ "Red", "red" ], [ "Green", "green" ] ]
    component = Components::Radio.new(options: options)

    assert_no_css_class component, "text-error"
  end

  test "renders with custom HTML attributes" do
    options = [ [ "Red", "red" ], [ "Green", "green" ] ]
    component = Components::Radio.new(
      options: options,
      data_controller: "radio",
      data_action: "change->radio#update"
    )

    doc = render_and_parse(component)
    radio_inputs = doc.css("input[type='radio']")

    radio_inputs.each do |radio|
      assert_equal "radio", radio["data-controller"]
      assert_equal "change->radio#update", radio["data-action"]
    end
  end

  test "renders complete radio group with all features" do
    options = [ [ "Small Size", "sm" ], [ "Medium Size", "md" ], [ "Large Size", "lg" ] ]
    component = Components::Radio.new(
      name: "product[size]",
      options: options,
      selected: "md",
      required: true,
      class: "size-radio",
      data_controller: "size-selector"
    )

    assert_renders_successfully component

    # Check structure
    assert_has_css_class component, "form-control"

    doc = render_and_parse(component)
    radio_inputs = doc.css("input[type='radio']")

    # Check all radios have correct name
    radio_inputs.each do |radio|
      assert_equal "product[size]", radio["name"]
    end

    # Check IDs
    assert_equal "product_size_0", radio_inputs[0]["id"]
    assert_equal "product_size_1", radio_inputs[1]["id"]
    assert_equal "product_size_2", radio_inputs[2]["id"]

    # Check values
    assert_equal "sm", radio_inputs[0]["value"]
    assert_equal "md", radio_inputs[1]["value"]
    assert_equal "lg", radio_inputs[2]["value"]

    # Check selection (md should be selected)
    assert_nil radio_inputs[0]["checked"]
    assert_equal "checked", radio_inputs[1]["checked"]
    assert_nil radio_inputs[2]["checked"]

    # Check required (only first should have required)
    assert_equal "required", radio_inputs[0]["required"]
    assert_nil radio_inputs[1]["required"]
    assert_nil radio_inputs[2]["required"]

    # Check custom classes and attributes
    radio_inputs.each do |radio|
      classes = radio["class"].split(" ")
      assert_includes classes, "radio"
      assert_includes classes, "size-radio"
      assert_equal "size-selector", radio["data-controller"]
    end

    # Check labels
    label_texts = doc.css(".label-text")
    assert_equal "Small Size", label_texts[0].text
    assert_equal "Medium Size", label_texts[1].text
    assert_equal "Large Size", label_texts[2].text
  end

  test "handles empty options gracefully" do
    component = Components::Radio.new(options: [])

    assert_renders_successfully component
    assert_has_css_class component, "form-control"

    doc = render_and_parse(component)
    radio_inputs = doc.css("input[type='radio']")
    assert_equal 0, radio_inputs.length
  end

  test "Rails form integration patterns work correctly" do
    # Test typical Rails form patterns
    options = [ [ "Admin", "admin" ], [ "User", "user" ], [ "Guest", "guest" ] ]
    component = Components::Radio.new(
      name: "user[role]",
      options: options,
      selected: "user",
      required: true
    )

    doc = render_and_parse(component)
    radio_inputs = doc.css("input[type='radio']")

    # Check all have correct name
    radio_inputs.each do |radio|
      assert_equal "user[role]", radio["name"]
    end

    # Check IDs follow Rails pattern
    assert_equal "user_role_0", radio_inputs[0]["id"]
    assert_equal "user_role_1", radio_inputs[1]["id"]
    assert_equal "user_role_2", radio_inputs[2]["id"]

    # Check selection (user should be selected)
    assert_nil radio_inputs[0]["checked"]
    assert_equal "checked", radio_inputs[1]["checked"]
    assert_nil radio_inputs[2]["checked"]

    # Check required only on first
    assert_equal "required", radio_inputs[0]["required"]
    assert_nil radio_inputs[1]["required"]
    assert_nil radio_inputs[2]["required"]
  end

  test "accessibility: labels and inputs are properly associated" do
    options = [ [ "Red", "red" ], [ "Green", "green" ] ]
    component = Components::Radio.new(name: "color", options: options)

    doc = render_and_parse(component)
    labels = doc.css("label")

    # Each label should contain exactly one radio input
    labels.each do |label|
      radio_in_label = label.css("input[type='radio']")
      assert_equal 1, radio_in_label.length, "Each label should contain exactly one radio input"
    end
  end
end
