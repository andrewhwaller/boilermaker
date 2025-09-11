# frozen_string_literal: true

require_relative "component_test_case"
require_relative "test_helpers"

class LoadingTest < ComponentTestCase
  include ComponentTestHelpers

  # Test basic loading component rendering
  test "renders loading element successfully" do
    loading = Components::Loading.new
    
    assert_renders_successfully(loading)
    
    # Use separate instance to avoid double render
    loading_output = Components::Loading.new
    assert_produces_output(loading_output)
    
    # Check that it renders with div container and span loading element
    loading_div = Components::Loading.new
    assert_has_tag(loading_div, "div")
    
    loading_span = Components::Loading.new
    assert_has_tag(loading_span, "span")
  end

  # Test default loading configuration
  test "renders with default spinner type and medium size" do
    loading = Components::Loading.new
    
    # Should have base loading classes
    assert_has_css_class(loading, ["loading", "loading-spinner", "loading-md"])
    
    # Should have flex container classes using separate instance
    loading_flex = Components::Loading.new
    assert_has_css_class(loading_flex, ["flex", "items-center"])
    
    # Should be centered when no text is provided using separate instance
    loading_centered = Components::Loading.new
    assert_has_css_class(loading_centered, "justify-center")
  end

  # Test all available loading types
  test "renders all loading types correctly" do
    Components::Loading::TYPES.each do |type, expected_class|
      loading_base = Components::Loading.new(type: type)
      
      # Should have base loading class
      assert_has_css_class(loading_base, "loading",
        "Loading with type #{type} should have base 'loading' class")
      
      # Should have specific type class using separate instance
      loading_type = Components::Loading.new(type: type)
      assert_has_css_class(loading_type, expected_class,
        "Loading with type #{type} should have class '#{expected_class}'")
    end
  end

  # Test all available loading sizes
  test "renders all loading sizes correctly" do
    Components::Loading::SIZES.each do |size, expected_class|
      loading = Components::Loading.new(size: size)
      
      assert_has_css_class(loading, expected_class,
        "Loading with size #{size} should have class '#{expected_class}'")
    end
  end

  # Test all available loading colors
  test "renders all loading colors correctly" do
    Components::Loading::COLORS.each do |color, expected_class|
      loading = Components::Loading.new(color: color)
      
      assert_has_css_class(loading, expected_class,
        "Loading with color #{color} should have class '#{expected_class}'")
    end
  end

  # Test loading without color (should not have color class)
  test "renders without color class when no color specified" do
    loading = Components::Loading.new
    
    html = render_component(loading)
    Components::Loading::COLORS.values.each do |color_class|
      refute html.include?(color_class), "Should not have color class '#{color_class}' when no color specified"
    end
  end

  # Test loading with text
  test "renders loading with text correctly" do
    loading_with_text = Components::Loading.new(text: "Loading data...")
    
    # Should contain the text
    assert_has_text(loading_with_text, "Loading data...")
    
    # Should have margin class for spacing using separate instance
    loading_margin = Components::Loading.new(text: "Loading data...")
    html = render_component(loading_margin)
    assert html.include?("ml-2"), "Loading text should have left margin"
    assert html.include?("text-sm"), "Loading text should have small text size"
    
    # Should NOT be centered when text is present using separate instance
    loading_not_centered = Components::Loading.new(text: "Loading data...")
    html = render_component(loading_not_centered)
    refute html.include?("justify-center"), "Should not be centered when text is provided"
  end

  # Test loading without text
  test "renders loading without text correctly" do
    loading_no_text = Components::Loading.new
    
    # Should be centered
    assert_has_css_class(loading_no_text, "justify-center")
    
    # Should not have text span using separate instance
    loading_no_text_check = Components::Loading.new
    html = render_component(loading_no_text_check)
    refute html.match?(/<span[^>]*ml-2/), "Should not have text span when no text provided"
  end

  # Test loading with custom attributes
  test "renders loading with custom attributes" do
    loading = Components::Loading.new(
      id: "custom-loading",
      "data-testid": "loading-component",
      "aria-label": "Loading content"
    )
    
    # Custom attributes should be on the container div
    assert_has_attributes(loading, "div", {
      id: "custom-loading",
      "data-testid": "loading-component",
      "aria-label": "Loading content"
    })
  end

  # Test loading combinations
  test "renders loading with multiple option combinations correctly" do
    # Large success dots with text
    large_success_dots = Components::Loading.new(
      type: :dots,
      size: :lg,
      color: :success,
      text: "Processing..."
    )
    
    assert_has_css_class(large_success_dots, ["loading", "loading-dots", "loading-lg", "text-success"])
    
    # Check text using separate instance
    large_success_dots_text = Components::Loading.new(
      type: :dots,
      size: :lg,
      color: :success,
      text: "Processing..."
    )
    assert_has_text(large_success_dots_text, "Processing...")
    
    # Small primary ring without text
    small_primary_ring = Components::Loading.new(
      type: :ring,
      size: :sm,
      color: :primary
    )
    
    assert_has_css_class(small_primary_ring, ["loading", "loading-ring", "loading-sm", "text-primary"])
    
    # Check centering using separate instance
    small_primary_ring_centered = Components::Loading.new(
      type: :ring,
      size: :sm,
      color: :primary
    )
    assert_has_css_class(small_primary_ring_centered, "justify-center")
  end

  # Test accessibility attributes
  test "includes proper accessibility attributes" do
    loading = Components::Loading.new
    
    # Loading spinner should have aria-hidden attribute
    html = render_component(loading)
    assert html.include?('aria-hidden="true"'), "Loading spinner should have aria-hidden attribute"
  end

  # Test block content
  test "renders block content correctly" do
    loading_with_block = Components::Loading.new do
      "Additional loading content"
    end
    
    # Block content should be rendered
    assert_has_text(loading_with_block, "Additional loading content")
  end

  # Test edge cases
  test "handles edge cases gracefully" do
    # Invalid type should not break rendering
    loading_invalid_type = Components::Loading.new(type: :invalid)
    assert_renders_successfully(loading_invalid_type)
    
    # Invalid size should not break rendering
    loading_invalid_size = Components::Loading.new(size: :invalid)
    assert_renders_successfully(loading_invalid_size)
    
    # Invalid color should not break rendering
    loading_invalid_color = Components::Loading.new(color: :invalid)
    assert_renders_successfully(loading_invalid_color)
    
    # Empty text should not show text span
    loading_empty_text = Components::Loading.new(text: "")
    html = render_component(loading_empty_text)
    refute html.match?(/<span[^>]*ml-2/), "Empty text should not create text span"
    
    # Nil text should not show text span
    loading_nil_text = Components::Loading.new(text: nil)
    html = render_component(loading_nil_text)
    refute html.match?(/<span[^>]*ml-2/), "Nil text should not create text span"
  end

  # Test CSS class generation logic
  test "generates clean CSS class strings" do
    loading = Components::Loading.new(type: :spinner, size: :md, color: :primary)
    html = render_component(loading)
    
    # Should not have double spaces or trailing/leading spaces in classes
    refute html.match?(/class="[^"]*\s{2,}[^"]*"/), "Should not have multiple consecutive spaces in class"
    refute html.match?(/class="\s/), "Should not start with space"
    refute html.match?(/\s"/), "Should not end with space"
  end

  # Test container structure
  test "maintains proper container structure" do
    loading = Components::Loading.new(text: "Loading...")
    html = render_component(loading)
    
    # Should have proper nesting: div > span + span
    doc = parse_html(html)
    container = doc.css("div").first
    assert container, "Should have container div"
    
    spans = container.css("span")
    assert_equal 2, spans.length, "Should have 2 span elements (spinner + text)"
    
    # First span should be the loading spinner
    spinner = spans.first
    assert spinner["class"].include?("loading"), "First span should be loading spinner"
    assert_equal "true", spinner["aria-hidden"], "Spinner should have aria-hidden"
    
    # Second span should be the text
    text_span = spans.last
    assert text_span["class"].include?("ml-2"), "Text span should have margin class"
    assert text_span.text.include?("Loading..."), "Text span should contain loading text"
  end

  # Test different loading animations work with different sizes and colors
  test "loading animations work with size and color combinations" do
    # Test each type with different size/color combinations
    [:dots, :ring, :ball].each do |type|
      loading_combo = Components::Loading.new(
        type: type,
        size: :lg,
        color: :error
      )
      
      assert_has_css_class(loading_combo, [
        "loading",
        "loading-#{type}",
        "loading-lg", 
        "text-error"
      ])
    end
  end
end