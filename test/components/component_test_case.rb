# frozen_string_literal: true

require "test_helper"
require "nokogiri"

class ComponentTestCase < ActiveSupport::TestCase
  # Base test class for Phlex component testing
  # Provides HTML parsing, assertion helpers, and Daisy UI validation methods

  protected

  # Render a component to HTML string
  # @param component [Phlex::HTML] The component instance to render
  # @return [String] The rendered HTML output
  def render(...)
    view_context.render(...)
  end

  def view_context
    controller.view_context
  end

  def controller
    @controller ||= ActionView::TestCase::TestController.new
  end

  def render_component(component, &block)
    # When a block is provided, render fresh without caching to
    # allow different content blocks.
    if block_given?
      return render(component, &block)
    end

    @__render_cache ||= {}
    key = component.object_id
    return @__render_cache[key] if @__render_cache.key?(key)

    html = render(component)
    @__render_cache[key] = html
    html
  end

  # Parse rendered HTML into a Nokogiri document for inspection
  # @param html [String] The HTML string to parse
  # @return [Nokogiri::HTML::DocumentFragment] Parsed HTML fragment
  def parse_html(html)
    Nokogiri::HTML::DocumentFragment.parse(html)
  end

  # Render component and return parsed HTML document
  # @param component [Phlex::HTML] The component instance to render
  # @return [Nokogiri::HTML::DocumentFragment] Parsed HTML fragment
  def render_and_parse(component)
    html = render_component(component)
    parse_html(html)
  end

  # Assert that rendered HTML contains a specific tag
  # @param component [Phlex::HTML] The component to test
  # @param tag_name [String] The HTML tag name to search for
  # @param message [String] Optional custom assertion message
  def assert_has_tag(component, tag_name, message = nil)
    doc = render_and_parse(component)
    elements = doc.css(tag_name)
    message ||= "Expected component to contain <#{tag_name}> element"
    assert elements.any?, message
  end

  # Assert that rendered HTML contains an element with specific CSS classes
  # @param component [Phlex::HTML] The component to test
  # @param css_classes [String, Array<String>] CSS class(es) to verify
  # @param message [String] Optional custom assertion message
  def assert_has_css_class(component, css_classes, message = nil)
    doc = render_and_parse(component)
    classes = Array(css_classes)

    classes.each do |css_class|
      elements = doc.css(".#{css_class}")
      message ||= "Expected component to contain element with CSS class '#{css_class}'"
      assert elements.any?, message
    end
  end

  # Assert that rendered HTML does not contain an element with specific CSS classes
  # @param component [Phlex::HTML] The component to test
  # @param css_classes [String, Array<String>] CSS class(es) to verify absence of
  # @param message [String] Optional custom assertion message
  def assert_no_css_class(component, css_classes, message = nil)
    html = render_component(component)
    doc = parse_html(html)
    classes = Array(css_classes)

    classes.each do |css_class|
      elements = doc.css(".#{css_class}")
      message ||= "Expected component to NOT contain element with CSS class '#{css_class}'"
      assert elements.empty?, message
    end
  end

  # Assert that rendered HTML contains specific text content
  # @param component [Phlex::HTML] The component to test
  # @param text [String] The text content to search for
  # @param message [String] Optional custom assertion message
  def assert_has_text(component, text, message = nil)
    html = render_component(component)
    message ||= "Expected component to contain text '#{text}'"
    assert html.include?(text), message
  end

  # Assert that rendered HTML contains an element with specific attributes
  # @param component [Phlex::HTML] The component to test
  # @param selector [String] CSS selector to find the element
  # @param attributes [Hash] Hash of attribute name/value pairs to verify
  # @param message [String] Optional custom assertion message
  def assert_has_attributes(component, selector, attributes, message = nil)
    html = render_component(component)
    doc = parse_html(html)
    element = doc.css(selector).first

    message ||= "Expected to find element matching '#{selector}'"
    assert element, message

    attributes.each do |attr_name, expected_value|
      actual_value = element[attr_name.to_s]
      attr_message = message || "Expected element '#{selector}' to have #{attr_name}='#{expected_value}'"
      assert_equal expected_value, actual_value, attr_message
    end
  end

  # Verify Daisy UI button classes are correctly applied
  # @param component [Phlex::HTML] The component to test
  # @param expected_classes [Array<String>] Expected Daisy UI classes
  # @param message [String] Optional custom assertion message
  def assert_daisy_button_classes(component, expected_classes, message = nil)
    html = render_component(component)
    doc = parse_html(html)
    button = doc.css("button").first

    message ||= "Expected to find a button element"
    assert button, message

    actual_classes = button["class"]&.split(" ") || []

    # Always expect base btn class for Daisy UI buttons
    assert_includes actual_classes, "btn", "Expected button to have base 'btn' class"

    expected_classes.each do |expected_class|
      class_message = message || "Expected button to have Daisy UI class '#{expected_class}'"
      assert_includes actual_classes, expected_class, class_message
    end
  end

  # Verify Daisy UI form control classes are correctly applied
  # @param component [Phlex::HTML] The component to test
  # @param expected_classes [Array<String>] Expected Daisy UI form classes
  # @param message [String] Optional custom assertion message
  def assert_daisy_form_classes(component, expected_classes, message = nil)
    html = render_component(component)
    doc = parse_html(html)

    expected_classes.each do |expected_class|
      elements = doc.css(".#{expected_class}")
      class_message = message || "Expected component to have Daisy UI form class '#{expected_class}'"
      assert elements.any?, class_message
    end
  end

  # Extract all CSS classes from the rendered component
  # Useful for debugging and verification
  # @param component [Phlex::HTML] The component to analyze
  # @return [Array<String>] All CSS classes found in the component
  def extract_css_classes(component)
    html = render_component(component)
    doc = parse_html(html)
    classes = []

    doc.css("*").each do |element|
      element_classes = element["class"]&.split(" ") || []
      classes.concat(element_classes)
    end

    classes.uniq.sort
  end

  # Get the outermost HTML element from the rendered component
  # @param component [Phlex::HTML] The component to inspect
  # @return [Nokogiri::XML::Element, nil] The root element or nil if not found
  def get_root_element(component)
    html = render_component(component)
    doc = parse_html(html)
    # For DocumentFragment, get the first element child
    doc.children.find { |child| child.is_a?(Nokogiri::XML::Element) }
  end

  # Assert that component renders without errors
  # @param component [Phlex::HTML] The component to test
  # @param message [String] Optional custom assertion message
  def assert_renders_successfully(component, message = nil)
    message ||= "Expected component to render without errors"

    begin
      render_component(component)
      assert true, message
    rescue => e
      flunk "#{message}: #{e.message}"
    end
  end

  # Assert that component produces non-empty HTML output
  # @param component [Phlex::HTML] The component to test
  # @param message [String] Optional custom assertion message
  def assert_produces_output(component, message = nil)
    html = render_component(component)
    message ||= "Expected component to produce non-empty HTML output"
    assert html.present?, message
  end
end
