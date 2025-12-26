# frozen_string_literal: true

require_relative "component_test_case"
require_relative "test_helpers"

class BadgeTest < ComponentTestCase
  include ComponentTestHelpers

  # Test basic badge rendering
  test "renders badge element successfully" do
    badge = Components::Badge.new

    assert_renders_successfully(badge)

    # Use separate instance to avoid double render
    badge_output = Components::Badge.new
    assert_produces_output(badge_output)

    # Check that it renders as a span element
    badge_tag = Components::Badge.new
    assert_has_tag(badge_tag, "span")
  end

  # Test default badge configuration
  test "renders with default neutral variant and medium size" do
    badge = Components::Badge.new

    # Should have base badge class and neutral variant
    assert_has_css_class(badge, [ "badge", "badge-neutral" ])
  end

  # Test all available badge variants
  test "renders all badge variants correctly" do
    Components::Badge::VARIANTS.each do |variant, expected_class|
      badge_base = Components::Badge.new(variant: variant)
      assert_has_css_class(badge_base, "badge",
        "Badge with variant #{variant} should have base 'badge' class")

      badge_variant = Components::Badge.new(variant: variant)
      assert_has_css_class(badge_variant, expected_class,
        "Badge with variant #{variant} should have class '#{expected_class}'")
    end
  end

  # Test all available badge sizes
  test "renders all badge sizes correctly" do
    { xs: "badge-xs", sm: "badge-sm", md: nil, lg: "badge-lg" }.each do |size, expected_class|
      badge = Components::Badge.new(size: size)

      if expected_class.present?
        assert_has_css_class(badge, expected_class,
          "Badge with size #{size} should have class '#{expected_class}'")
      else
        # Medium size should not have a size class
        html = render_component(badge)
        refute html.match?(/badge-(xs|sm|lg)/),
          "Medium badge should not have explicit size class"
      end
    end
  end

  # Test all available badge styles
  test "renders all badge styles correctly" do
    { neutral: nil, outline: "badge-outline" }.each do |variant, expected_class|
      badge = Components::Badge.new(variant: variant)

      if expected_class.present?
        assert_has_css_class(badge, expected_class,
          "Badge with variant #{variant} should have class '#{expected_class}'")
      else
        # Default variant should not have a variant class beyond 'badge'
        html = render_component(badge)
        refute html.match?(/badge-(primary|secondary|destructive|success|warning|info|accent|outline)/),
          "Neutral badge should not have variant-specific classes"
      end
    end
  end

  # Test badge content rendering
  test "renders badge content correctly" do
    # Test with text content
    badge_with_text = Components::Badge.new { "Test Badge" }
    assert_has_text(badge_with_text, "Test Badge")

    # Test with number content
    badge_with_number = Components::Badge.new { "42" }
    assert_has_text(badge_with_number, "42")

    # Test with empty content (should still render)
    badge_empty = Components::Badge.new
    assert_renders_successfully(badge_empty)
  end

  # Test badge with custom attributes
  test "renders badge with custom attributes" do
    badge = Components::Badge.new(
      id: "custom-badge",
      "data-testid": "badge-component",
      title: "Custom Badge"
    )

    assert_has_attributes(badge, "span", {
      id: "custom-badge",
      "data-testid": "badge-component",
      title: "Custom Badge"
    })
  end

  # Test badge combinations
  test "renders badge with multiple option combinations correctly" do
    # Small outline badge
    small_outline = Components::Badge.new(
      variant: :outline,
      size: :sm
    )

    assert_has_css_class(small_outline, [ "badge", "badge-outline", "badge-sm" ])

    # Large error badge
    large_error = Components::Badge.new(
      variant: :error,
      size: :lg
    )

    assert_has_css_class(large_error, [ "badge", "badge-error", "badge-lg" ])
  end

  # Test edge cases
  test "handles edge cases gracefully" do
    # Invalid variant should not break rendering
    badge_invalid_variant = Components::Badge.new(variant: :invalid)
    assert_renders_successfully(badge_invalid_variant)

    # Invalid size should not break rendering
    badge_invalid_size = Components::Badge.new(size: :invalid)
    assert_renders_successfully(badge_invalid_size)

    # Invalid variant should not break rendering (already tested above)
    # badge_invalid_variant already tested
  end

  # Test CSS class generation logic
  test "generates clean CSS class strings" do
    # Test that empty/nil classes are properly filtered out
    badge = Components::Badge.new(variant: :neutral, size: :md, style: :default)
    html = render_component(badge)

    # Should not have double spaces or trailing/leading spaces
    refute html.match?(/class="[^"]*\s{2,}[^"]*"/), "Should not have multiple consecutive spaces in class"
    refute html.match?(/class="\s/), "Should not start with space"
    refute html.match?(/\s"/), "Should not end with space"
  end

  # Test accessibility
  test "maintains accessibility standards" do
    # Badge should be a span element for semantic meaning
    badge = Components::Badge.new
    assert_has_tag(badge, "span")

    # Badge with content should be readable
    badge_with_content = Components::Badge.new { "New" }
    html = render_component(badge_with_content)
    assert html.include?("New"), "Badge content should be accessible to screen readers"
  end
end
