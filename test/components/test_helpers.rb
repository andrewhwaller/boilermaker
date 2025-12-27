# frozen_string_literal: true

require "ostruct"

# Additional test helpers for component testing
module ComponentTestHelpers
  # Common button variant class sets for verification
  BUTTON_VARIANTS = {
    primary: [ "ui-button", "ui-button-primary" ],
    secondary: [ "ui-button", "ui-button-secondary" ],
    destructive: [ "ui-button", "ui-button-error" ],
    outline: [ "ui-button", "ui-button-outline" ],
    ghost: [ "ui-button", "ui-button-ghost" ],
    link: [ "ui-button", "ui-button-link" ]
  }.freeze

  FORM_CLASSES = [
    "form-control",
    "label",
    "ui-input",
    "ui-textarea",
    "ui-select",
    "ui-checkbox",
    "ui-radio",
    "label-text",
    "label-text-alt"
  ].freeze

  LAYOUT_CLASSES = [
    "navbar",
    "navbar-start",
    "navbar-center",
    "navbar-end",
    "drawer",
    "drawer-content",
    "drawer-side",
    "hero",
    "ui-card",
    "ui-card-content"
  ].freeze

  # Assert component renders with expected variant classes
  # @param component [Phlex::HTML] The component to test
  # @param variant [Symbol] The variant key (e.g., :primary, :secondary)
  # @param component_type [Symbol] The component type (:button, :form, :layout)
  def assert_variant(component, variant, component_type = :button)
    case component_type
    when :button
      expected_classes = BUTTON_VARIANTS[variant]
      assert expected_classes, "Unknown button variant: #{variant}"
      assert_button_classes(component, expected_classes)
    else
      raise ArgumentError, "Unsupported component type: #{component_type}"
    end
  end

  # Alias for backwards compatibility
  alias_method :assert_daisy_variant, :assert_variant

  # Verify component has proper accessibility attributes
  # @param component [Phlex::HTML] The component to test
  # @param selector [String] CSS selector for the element to check
  # @param expected_attrs [Hash] Expected accessibility attributes
  def assert_accessibility_attributes(component, selector, expected_attrs)
    html = render_component(component)
    doc = parse_html(html)
    element = doc.css(selector).first

    assert element, "Expected to find element matching '#{selector}'"

    expected_attrs.each do |attr_name, expected_value|
      actual_value = element[attr_name.to_s]
      assert_equal expected_value, actual_value,
        "Expected #{selector} to have #{attr_name}='#{expected_value}', got '#{actual_value}'"
    end
  end

  # Test component with various attribute combinations
  # @param component_class [Class] The component class to instantiate
  # @param attribute_sets [Array<Hash>] Array of attribute hashes to test
  # @param block [Proc] Block to run additional assertions on each instance
  def assert_attribute_combinations(component_class, attribute_sets, &block)
    attribute_sets.each do |attrs|
      component = component_class.new(**attrs)

      # Basic rendering test
      assert_renders_successfully(component)

      # Run custom assertions if block provided
      block.call(component, attrs) if block
    end
  end

  # Create a minimal Rails request context for testing components that need it
  # @return [Hash] Mock request context
  def mock_rails_context
    {
      request: OpenStruct.new(
        path: "/test",
        fullpath: "/test",
        original_url: "http://test.example.com/test"
      ),
      controller: OpenStruct.new(
        controller_name: "test",
        action_name: "index"
      )
    }
  end

  # Simulate current user for components that depend on Current.user
  # Uses Current.session.user, since Current has no writer
  # @param user [User, nil] Logged-in user to simulate (nil clears user)
  # @param account [Account, nil] Optional account to mark as current (defaults to user's first account)
  def with_current_user(user, account: nil)
    original_session = Current.session
    original_account = Current.account

    if user.nil?
      Current.session = nil
      Current.account = nil
    else
      account ||= user.accounts.first
      Current.session = OpenStruct.new(user: user, account: account)
      Current.account = account
    end

    yield
  ensure
    Current.session = original_session
    Current.account = original_account
  end

  # Test component behavior with different screen sizes/responsive classes
  # @param component [Phlex::HTML] The component to test
  # @param breakpoints [Array<String>] Breakpoint prefixes to verify (sm:, md:, lg:, xl:)
  def assert_responsive_classes(component, breakpoints = [])
    all_classes = extract_css_classes(component)

    breakpoints.each do |breakpoint|
      responsive_classes = all_classes.select { |cls| cls.start_with?("#{breakpoint}:") }
      assert responsive_classes.any?,
        "Expected component to have responsive classes for breakpoint '#{breakpoint}:'"
    end
  end

  # Verify component correctly handles boolean attributes
  # @param component_class [Class] The component class
  # @param boolean_attr [Symbol] The boolean attribute to test
  # @param selector [String] CSS selector to check for attribute presence
  # @param html_attr [String] The HTML attribute that should be present/absent
  def assert_boolean_attribute_handling(component_class, boolean_attr, selector, html_attr)
    # Test with boolean_attr: true
    component_true = component_class.new(boolean_attr => true)
    html_true = render_component(component_true)
    doc_true = parse_html(html_true)
    element_true = doc_true.css(selector).first
    assert element_true, "Expected to find element matching '#{selector}'"
    assert element_true.has_attribute?(html_attr),
      "Expected element to have '#{html_attr}' attribute when #{boolean_attr}: true"

    # Test with boolean_attr: false
    component_false = component_class.new(boolean_attr => false)
    html_false = render_component(component_false)
    doc_false = parse_html(html_false)
    element_false = doc_false.css(selector).first
    assert element_false, "Expected to find element matching '#{selector}'"
    assert !element_false.has_attribute?(html_attr),
      "Expected element to NOT have '#{html_attr}' attribute when #{boolean_attr}: false"
  end

  # Extract and return all data-* attributes from the component
  # @param component [Phlex::HTML] The component to analyze
  # @param selector [String] Optional CSS selector to narrow search
  # @return [Hash] Hash of data attributes found
  def extract_data_attributes(component, selector = "*")
    html = render_component(component)
    doc = parse_html(html)
    data_attrs = {}

    doc.css(selector).each do |element|
      element.attributes.each do |name, attr|
        if name.start_with?("data-")
          data_attrs[name] = attr.value
        end
      end
    end

    data_attrs
  end
end
