# frozen_string_literal: true

require_relative "../component_test_case"
require_relative "../test_helpers"

class TableRowTest < ComponentTestCase
  include ComponentTestHelpers

  # Test basic row rendering
  test "renders row element successfully" do
    row = Components::Table::Row.new

    assert_renders_successfully(row)
    assert_produces_output(row)
    assert_has_tag(row, "tr")
  end

  # Test default row configuration
  test "renders with default configuration" do
    row = Components::Table::Row.new

    # Should not have any variant classes by default
    html = render_component(row)
    refute html.include?("active"), "Default row should not have active class"
    refute html.include?("hover"), "Default row should not have hover class"
  end

  # Test all available row variants
  test "renders all row variants correctly" do
    Components::Table::Row::VARIANTS.each do |variant, expected_class|
      row = Components::Table::Row.new(variant: variant)
      assert_has_css_class(row, expected_class,
        "Row with variant #{variant} should have class '#{expected_class}'")
    end
  end

  # Test row content rendering
  test "renders row content correctly" do
    # Test with cell content
    row_with_cells = Components::Table::Row.new do
      td { "Cell 1" }
      td { "Cell 2" }
    end

    html = render_component(row_with_cells)
    assert html.include?("Cell 1"), "Row should render cell content"
    assert html.include?("Cell 2"), "Row should render multiple cells"

    # Test with empty content
    row_empty = Components::Table::Row.new
    assert_renders_successfully(row_empty)
  end

  # Test row with custom attributes
  test "renders row with custom attributes" do
    row = Components::Table::Row.new(
      id: "custom-row",
      "data-testid": "row-component",
      "data-id": "123"
    )

    assert_has_attributes(row, "tr", {
      id: "custom-row",
      "data-testid": "row-component", 
      "data-id": "123"
    })
  end

  # Test row variants with content
  test "renders row variants with content correctly" do
    # Active row with content
    active_row = Components::Table::Row.new(variant: :active) do
      td { "Active Cell" }
    end

    html = render_component(active_row)
    assert html.include?("active"), "Row should have active class"
    assert html.include?("Active Cell"), "Row should render content"

    # Hover row with content
    hover_row = Components::Table::Row.new(variant: :hover) do
      td { "Hover Cell" }
    end

    html = render_component(hover_row)
    assert html.include?("hover"), "Row should have hover class"
    assert html.include?("Hover Cell"), "Row should render content"
  end

  # Test edge cases
  test "handles edge cases gracefully" do
    # Invalid variant should not break rendering
    row_invalid_variant = Components::Table::Row.new(variant: :invalid)
    assert_renders_successfully(row_invalid_variant)
    
    # Should not add invalid class
    html = render_component(row_invalid_variant)
    refute html.include?("invalid"), "Invalid variant should not add invalid class"

    # Nil variant should work same as default
    row_nil_variant = Components::Table::Row.new(variant: nil)
    assert_renders_successfully(row_nil_variant)
  end

  # Test CSS class generation logic
  test "generates clean CSS class strings" do
    # Row without variant should not have class attribute if no other classes
    row_no_variant = Components::Table::Row.new
    html = render_component(row_no_variant)
    
    # Should either not have class attribute, or have clean class string
    if html.include?('class="')
      refute html.match?(/class="[^"]*\s{2,}[^"]*"/), "Should not have multiple consecutive spaces"
      refute html.match?(/class="\s/), "Should not start with space"
      refute html.match?(/\s"/), "Should not end with space"
    end

    # Row with variant should have clean class
    row_with_variant = Components::Table::Row.new(variant: :active)
    html = render_component(row_with_variant)
    assert html.include?('class="active"'), "Should have clean active class"
  end

  # Test accessibility
  test "maintains accessibility standards" do
    # Should be a tr element for semantic meaning
    row = Components::Table::Row.new
    assert_has_tag(row, "tr")

    # Row with content should be accessible
    row_with_content = Components::Table::Row.new do
      td { "Accessible content" }
    end
    
    html = render_component(row_with_content)
    assert html.include?("Accessible content"), "Row content should be accessible to screen readers"
  end

  # Test with complex content
  test "handles complex cell content" do
    complex_row = Components::Table::Row.new(variant: :hover) do
      td(class: "font-bold") { "Bold Cell" }
      td do
        span(class: "text-sm") { "Small text" }
      end
      td(colspan: 2) { "Spanning cell" }
    end

    html = render_component(complex_row)
    
    assert html.include?("hover"), "Should maintain row variant"
    assert html.include?("Bold Cell"), "Should render complex cell content"
    assert html.include?("Small text"), "Should render nested elements"
    assert html.include?('colspan="2"'), "Should handle cell attributes"
  end
end