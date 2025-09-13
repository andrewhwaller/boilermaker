# frozen_string_literal: true

require_relative "../component_test_case"
require_relative "../test_helpers"

class TableCellTest < ComponentTestCase
  include ComponentTestHelpers

  # Test basic cell rendering
  test "renders cell element successfully" do
    cell = Components::Table::Cell.new

    assert_renders_successfully(cell)
    assert_produces_output(cell)
    assert_has_tag(cell, "td")
  end

  # Test default cell configuration
  test "renders with default configuration" do
    cell = Components::Table::Cell.new

    # Should have left alignment by default
    assert_has_css_class(cell, "text-left")

    # Should not have colspan/rowspan by default
    html = render_component(cell)
    refute html.include?("colspan"), "Default cell should not have colspan"
    refute html.include?("rowspan"), "Default cell should not have rowspan"
  end

  # Test all available cell alignments
  test "renders all cell alignments correctly" do
    Components::Table::Cell::ALIGNMENTS.each do |alignment, expected_class|
      cell = Components::Table::Cell.new(align: alignment)
      assert_has_css_class(cell, expected_class,
        "Cell with alignment #{alignment} should have class '#{expected_class}'")
    end
  end

  # Test cell content rendering
  test "renders cell content correctly" do
    # Test with text content
    cell_with_text = Components::Table::Cell.new { "Cell Content" }
    assert_has_text(cell_with_text, "Cell Content")

    # Test with number content
    cell_with_number = Components::Table::Cell.new { "42" }
    assert_has_text(cell_with_number, "42")

    # Test with empty content
    cell_empty = Components::Table::Cell.new
    assert_renders_successfully(cell_empty)
  end

  # Test cell with colspan
  test "renders cell with colspan correctly" do
    cell = Components::Table::Cell.new(colspan: 2)

    assert_has_attributes(cell, "td", { colspan: "2" })
  end

  # Test cell with rowspan
  test "renders cell with rowspan correctly" do
    cell = Components::Table::Cell.new(rowspan: 3)

    assert_has_attributes(cell, "td", { rowspan: "3" })
  end

  # Test cell with both colspan and rowspan
  test "renders cell with both colspan and rowspan correctly" do
    cell = Components::Table::Cell.new(colspan: 2, rowspan: 3)

    assert_has_attributes(cell, "td", {
      colspan: "2",
      rowspan: "3"
    })
  end

  # Test cell with custom attributes
  test "renders cell with custom attributes" do
    cell = Components::Table::Cell.new(
      id: "custom-cell",
      "data-testid": "cell-component",
      "data-value": "123"
    )

    assert_has_attributes(cell, "td", {
      id: "custom-cell",
      "data-testid": "cell-component",
      "data-value": "123"
    })
  end

  # Test cell alignment with content
  test "renders cell alignment with content correctly" do
    # Center aligned cell with content
    center_cell = Components::Table::Cell.new(align: :center) do
      "Centered Text"
    end

    html = render_component(center_cell)
    assert html.include?("text-center"), "Cell should have center alignment class"
    assert html.include?("Centered Text"), "Cell should render content"

    # Right aligned cell with content
    right_cell = Components::Table::Cell.new(align: :right) do
      "Right Text"
    end

    html = render_component(right_cell)
    assert html.include?("text-right"), "Cell should have right alignment class"
    assert html.include?("Right Text"), "Cell should render content"
  end

  # Test cell with custom class and alignment
  test "combines custom class with alignment class" do
    cell = Components::Table::Cell.new(align: :center, class: "font-bold")

    html = render_component(cell)
    assert html.include?("font-bold"), "Should include custom class"
    assert html.include?("text-center"), "Should include alignment class"

    # Both classes should be present in the same class attribute
    assert html.match?(/class="[^"]*font-bold[^"]*text-center[^"]*"/) ||
           html.match?(/class="[^"]*text-center[^"]*font-bold[^"]*"/),
           "Both classes should be in the same class attribute"
  end

  # Test edge cases
  test "handles edge cases gracefully" do
    # Invalid alignment should not break rendering
    cell_invalid_align = Components::Table::Cell.new(align: :invalid)
    assert_renders_successfully(cell_invalid_align)

    # Nil colspan/rowspan should work
    cell_nil_span = Components::Table::Cell.new(colspan: nil, rowspan: nil)
    assert_renders_successfully(cell_nil_span)

    html = render_component(cell_nil_span)
    refute html.include?("colspan"), "Nil colspan should not appear in HTML"
    refute html.include?("rowspan"), "Nil rowspan should not appear in HTML"

    # Zero colspan/rowspan should still render (though invalid HTML)
    cell_zero_span = Components::Table::Cell.new(colspan: 0, rowspan: 0)
    assert_renders_successfully(cell_zero_span)
  end

  # Test CSS class generation logic
  test "generates clean CSS class strings" do
    cell = Components::Table::Cell.new(align: :left, class: "custom-class")
    html = render_component(cell)

    # Should not have double spaces or trailing/leading spaces
    refute html.match?(/class="[^"]*\s{2,}[^"]*"/), "Should not have multiple consecutive spaces in class"
    refute html.match?(/class="\s/), "Should not start with space"
    refute html.match?(/\s"/), "Should not end with space"
  end

  # Test accessibility
  test "maintains accessibility standards" do
    # Should be a td element for semantic meaning
    cell = Components::Table::Cell.new
    assert_has_tag(cell, "td")

    # Cell with content should be accessible
    cell_with_content = Components::Table::Cell.new { "Data content" }
    html = render_component(cell_with_content)
    assert html.include?("Data content"), "Cell content should be accessible to screen readers"

    # Spanning cells should maintain accessibility
    spanning_cell = Components::Table::Cell.new(colspan: 2) { "Spanning content" }
    html = render_component(spanning_cell)
    assert html.include?('colspan="2"'), "Colspan should be properly set for screen readers"
    assert html.include?("Spanning content"), "Spanning cell content should be accessible"
  end

  # Test with complex content
  test "handles complex cell content" do
    complex_cell = Components::Table::Cell.new(align: :center, colspan: 2) do
      div(class: "flex items-center gap-2") do
        span(class: "font-bold") { "Bold" }
        span(class: "text-sm text-gray-500") { "Small" }
      end
    end

    html = render_component(complex_cell)

    assert html.include?("text-center"), "Should maintain alignment"
    assert html.include?('colspan="2"'), "Should maintain colspan"
    assert html.include?("Bold"), "Should render complex content"
    assert html.include?("Small"), "Should render nested elements"
    assert html.include?("flex items-center"), "Should handle nested styling"
  end

  # Test numeric colspan/rowspan values
  test "handles numeric span values correctly" do
    # Integer values
    cell_int = Components::Table::Cell.new(colspan: 5, rowspan: 3)
    html_int = render_component(cell_int)
    assert html_int.include?('colspan="5"'), "Should handle integer colspan"
    assert html_int.include?('rowspan="3"'), "Should handle integer rowspan"

    # String values should work too
    cell_str = Components::Table::Cell.new(colspan: "2", rowspan: "4")
    html_str = render_component(cell_str)
    assert html_str.include?('colspan="2"'), "Should handle string colspan"
    assert html_str.include?('rowspan="4"'), "Should handle string rowspan"
  end
end
