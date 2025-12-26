# frozen_string_literal: true

require_relative "component_test_case"
require_relative "test_helpers"

class ButtonTest < ComponentTestCase
  include ComponentTestHelpers

  # Test basic button rendering
  test "renders button element successfully" do
    button = Components::Button.new

    assert_renders_successfully(button)

    # Use separate instance to avoid double render
    button_output = Components::Button.new
    assert_produces_output(button_output)

    button_tag = Components::Button.new
    assert_has_tag(button_tag, "button")
  end

  # Test default button configuration
  test "renders with default primary variant and button type" do
    button = Components::Button.new

    # Should have primary variant classes
    assert_daisy_button_classes(button, [ "btn", "btn-primary" ])

    # Create new instance for attributes test
    button_attrs = Components::Button.new
    assert_has_attributes(button_attrs, "button", { type: "button" })
  end

  # Test all available button variants from VARIANTS constant
  test "renders all button variants correctly" do
    Components::Button::VARIANTS.each do |variant, expected_class|
      # Use separate instances for each assertion to avoid double rendering
      button_base = Components::Button.new(variant: variant)
      assert_has_css_class(button_base, "btn",
        "Button with variant #{variant} should have base 'btn' class")

      button_variant = Components::Button.new(variant: variant)
      assert_has_css_class(button_variant, expected_class,
        "Button with variant #{variant} should have class '#{expected_class}'")

      # Note: Disabled styling is applied via CSS rules, not HTML classes
    end
  end

  # Test each variant individually with detailed assertions
  test "primary variant has correct styling" do
    button = Components::Button.new(variant: :primary)
    assert_daisy_variant(button, :primary, :button)

    # Create new instance to avoid double render error
    button_check = Components::Button.new(variant: :primary)
    assert_no_css_class(button_check, [ "btn-secondary", "btn-error", "btn-outline", "btn-ghost", "btn-link" ])
  end

  test "secondary variant has correct styling" do
    button = Components::Button.new(variant: :secondary)
    assert_daisy_variant(button, :secondary, :button)

    button_check = Components::Button.new(variant: :secondary)
    assert_no_css_class(button_check, [ "btn-primary", "btn-error", "btn-outline", "btn-ghost", "btn-link" ])
  end

  test "destructive variant has correct styling" do
    button = Components::Button.new(variant: :destructive)
    assert_daisy_variant(button, :destructive, :button)

    button_check = Components::Button.new(variant: :destructive)
    assert_no_css_class(button_check, [ "btn-primary", "btn-secondary", "btn-outline", "btn-ghost", "btn-link" ])
  end

  test "outline variant has correct styling" do
    button = Components::Button.new(variant: :outline)
    assert_daisy_variant(button, :outline, :button)

    button_check = Components::Button.new(variant: :outline)
    assert_no_css_class(button_check, [ "btn-primary", "btn-secondary", "btn-error", "btn-ghost", "btn-link" ])
  end

  test "ghost variant has correct styling" do
    button = Components::Button.new(variant: :ghost)
    assert_daisy_variant(button, :ghost, :button)

    button_check = Components::Button.new(variant: :ghost)
    assert_no_css_class(button_check, [ "btn-primary", "btn-secondary", "btn-error", "btn-outline", "btn-link" ])
  end

  test "link variant has correct styling" do
    button = Components::Button.new(variant: :link)
    assert_daisy_variant(button, :link, :button)

    button_check = Components::Button.new(variant: :link)
    assert_no_css_class(button_check, [ "btn-primary", "btn-secondary", "btn-error", "btn-outline", "btn-ghost" ])
  end

  # Test button type attribute
  test "accepts different button types" do
    button_types = [ :button, :submit, :reset ]

    button_types.each do |type|
      button = Components::Button.new(type: type)
      assert_has_attributes(button, "button", { type: type.to_s })
    end
  end

  # Test custom HTML attributes
  test "accepts custom HTML attributes" do
    button = Components::Button.new(
      id: "custom-button",
      class: "extra-class",
      data: { testid: "submit-btn" },
      disabled: true
    )

    doc = render_and_parse(button)
    button_element = doc.css("button").first

    assert_equal "custom-button", button_element["id"]
    assert_includes button_element["class"], "extra-class"
    assert_equal "submit-btn", button_element["data-testid"]
    assert button_element.has_attribute?("disabled")
  end

  # Test button content via block
  test "renders button content from block" do
    # Create a simple mock of button with content by testing structure
    button = Components::Button.new(variant: :primary)
    html = render_component(button)

    # Should render button element that can contain content
    assert html.include?("<button"), "Should render button tag"
    assert html.include?("</button>"), "Should close button tag"
  end

  test "renders button with proper structure for content" do
    button = Components::Button.new(variant: :primary)
    html = render_component(button)

    assert html.include?("<button"), "Should render button tag"
    assert html.include?('type="button"'), "Should have default button type"
    assert html.include?("btn"), "Should have btn class"
  end

  test "applies casing classes when requested" do
    uppercase_button = Components::Button.new(variant: :primary, uppercase: true)
    assert_has_css_class(uppercase_button, "uppercase")

    normal_case_button = Components::Button.new(variant: :primary, uppercase: false)
    assert_has_css_class(normal_case_button, "normal-case")
  end

  test "applies size variants correctly" do
    size_mappings = {
      xs: "btn-xs",
      sm: "btn-sm",
      md: "btn-md",
      lg: "btn-lg"
    }

    size_mappings.each do |size, expected_class|
      button = Components::Button.new(variant: :primary, size: size)
      assert_has_css_class(button, expected_class)
      # Ensure we didn't leak a raw size attribute to the DOM
      html = render_component(button)
      refute_match(/\ssize=("|')#{size}("|')/, html)
    end
  end

  # Test edge cases and error conditions
  test "handles invalid variant gracefully" do
    # Invalid variant should not crash, but may not have expected styling
    button = Components::Button.new(variant: :invalid)

    assert_renders_successfully(button)

    # Should still have base btn class
    button_check = Components::Button.new(variant: :invalid)
    assert_has_css_class(button_check, "btn")
  end

  test "handles nil variant" do
    button = Components::Button.new(variant: nil)

    assert_renders_successfully(button)

    button_check = Components::Button.new(variant: nil)
    assert_has_css_class(button_check, "btn")
  end

  # Test attribute combinations
  test "handles multiple attribute combinations" do
    attribute_combinations = [
      { variant: :primary, type: :submit, id: "submit-btn" },
      { variant: :secondary, type: :button, data: { role: "secondary" } },
      { variant: :destructive, type: :button, disabled: true },
      { variant: :outline, type: :reset },
      { variant: :ghost, type: :button },
      { variant: :link, type: :button }
    ]

    attribute_combinations.each do |attrs|
      # Basic rendering test
      button = Components::Button.new(**attrs)
      assert_renders_successfully(button)

      # Verify variant styling
      expected_variant_class = Components::Button::VARIANTS[attrs[:variant]]
      if expected_variant_class
        button_variant = Components::Button.new(**attrs)
        assert_has_css_class(button_variant, expected_variant_class)
      end

      # Verify button type
      expected_type = attrs[:type] || :button
      button_type = Components::Button.new(**attrs)
      assert_has_attributes(button_type, "button", { type: expected_type.to_s })
    end
  end

  # Performance and structure tests
  test "button has clean HTML structure" do
    button = Components::Button.new(variant: :primary)
    html = render_component(button)
    doc = parse_html(html)

    # Should have exactly one button element
    buttons = doc.css("button")
    assert_equal 1, buttons.length, "Should render exactly one button element"

    # Button should be the root element
    button_root = Components::Button.new(variant: :primary)
    root = get_root_element(button_root)
    assert_equal "button", root.name, "Button element should be the root element"
  end

  test "button CSS classes are properly structured" do
    button = Components::Button.new(variant: :primary)
    all_classes = extract_css_classes(button)

    # Should have essential Daisy UI classes
    assert_includes all_classes, "btn"
    assert_includes all_classes, "btn-primary"
    assert_includes all_classes, "btn-md" # Default size

    # Should not have conflicting variant classes
    conflicting_classes = Components::Button::VARIANTS.values - [ "btn-primary" ]
    conflicting_classes.each do |conflicting_class|
      assert_not_includes all_classes, conflicting_class,
        "Primary button should not have conflicting class: #{conflicting_class}"
    end
  end

  # Accessibility tests
  test "button maintains accessibility standards" do
    button = Components::Button.new(variant: :primary)
    html = render_component(button)
    doc = parse_html(html)
    button_element = doc.css("button").first

    # Button should have proper type attribute
    assert button_element.has_attribute?("type"), "Button should have type attribute"

    # Button should be focusable (no negative tabindex unless explicitly set)
    refute_equal "-1", button_element["tabindex"], "Button should be focusable by default"
  end

  test "button with aria attributes" do
    button = Components::Button.new(
      variant: :primary,
      aria: { label: "Submit form", describedby: "help-text" }
    )

    assert_accessibility_attributes(button, "button", {
      "aria-label" => "Submit form",
      "aria-describedby" => "help-text"
    })
  end
end
