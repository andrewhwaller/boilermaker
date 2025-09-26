# frozen_string_literal: true

require_relative "component_test_case"
require_relative "test_helpers"

class LoadingTest < ComponentTestCase
  include ComponentTestHelpers

  # Test basic rendering
  test "renders loading element successfully" do
    loading = Components::Loading.new
    assert_renders_successfully(loading)
    assert_has_tag(loading, "div")
    assert_has_tag(loading, "span")
  end

  # Test default configuration
  test "renders with default dots type and medium size" do
    loading = Components::Loading.new
    assert_has_css_class(loading, [ "loading-ascii", "ascii-dots", "text-base" ])
  end

  # Test all types
  test "renders all loading types correctly" do
    Components::Loading::TYPES.each do |type, expected_class|
      loading = Components::Loading.new(type: type)
      assert_has_css_class(loading, [ "loading-ascii", expected_class ])
    end
  end

  # Test all sizes
  test "renders all loading sizes correctly" do
    Components::Loading::SIZES.each do |size, expected_class|
      loading = Components::Loading.new(size: size)
      assert_has_css_class(loading, expected_class)
    end
  end

  # Test colors
  test "renders loading colors correctly" do
    loading = Components::Loading.new(color: :primary)
    assert_has_css_class(loading, "text-primary")
  end

  # Test with text
  test "renders loading with text correctly" do
    loading = Components::Loading.new(text: "Loading...")
    assert_has_text(loading, "Loading...")

    html = render_component(loading)
    assert html.include?("ml-2"), "Should have text margin"
    refute html.include?("justify-center"), "Should not center when text present"
  end

  # Test without text
  test "centers loading when no text provided" do
    loading = Components::Loading.new
    assert_has_css_class(loading, "justify-center")
  end

  # Test accessibility
  test "includes aria-hidden attribute" do
    loading = Components::Loading.new
    html = render_component(loading)
    assert html.include?('aria-hidden="true"')
  end
end
