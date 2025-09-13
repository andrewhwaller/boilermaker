# frozen_string_literal: true

require_relative "../component_test_case"
require_relative "../test_helpers"

class TableHeaderTest < ComponentTestCase
  include ComponentTestHelpers

  # Test basic header rendering
  test "renders header element successfully" do
    header = Components::Table::Header.new
    assert_renders_successfully(header)

    header_output = Components::Table::Header.new
    assert_produces_output(header_output)

    header_tag = Components::Table::Header.new
    assert_has_tag(header_tag, "th")
  end

  # Test header content
  test "renders header content correctly" do
    header_with_text = Components::Table::Header.new { "Column Name" }
    assert_has_text(header_with_text, "Column Name")

    # Test with empty content
    header_empty = Components::Table::Header.new
    assert_renders_successfully(header_empty)
  end

  # Test sortable header
  test "renders sortable header correctly" do
    sortable_header = Components::Table::Header.new(sortable: true)
    html = render_component(sortable_header)

    # Should have cursor pointer class
    assert html.include?("cursor-pointer"), "Sortable header should have cursor-pointer class"
    assert html.include?("select-none"), "Sortable header should have select-none class"

    # Should have sort indicator
    assert html.include?("↕"), "Sortable header should have unsorted indicator"
  end

  # Test sorted header states
  test "renders sorted header states correctly" do
    # Ascending sort
    header_asc = Components::Table::Header.new(sortable: true, sorted: :asc)
    html_asc = render_component(header_asc)
    assert html_asc.include?("↑"), "Ascending sorted header should have up arrow"

    # Descending sort
    header_desc = Components::Table::Header.new(sortable: true, sorted: :desc)
    html_desc = render_component(header_desc)
    assert html_desc.include?("↓"), "Descending sorted header should have down arrow"

    # Unsorted
    header_unsorted = Components::Table::Header.new(sortable: true, sorted: nil)
    html_unsorted = render_component(header_unsorted)
    assert html_unsorted.include?("↕"), "Unsorted header should have bidirectional arrow"
  end

  # Test non-sortable header
  test "renders non-sortable header correctly" do
    header = Components::Table::Header.new(sortable: false)
    html = render_component(header)

    # Should not have cursor pointer class
    refute html.include?("cursor-pointer"), "Non-sortable header should not have cursor-pointer class"

    # Should not have sort indicators
    refute html.include?("↑"), "Non-sortable header should not have sort arrows"
    refute html.include?("↓"), "Non-sortable header should not have sort arrows"
    refute html.include?("↕"), "Non-sortable header should not have sort arrows"
  end

  # Test header with custom attributes
  test "renders header with custom attributes" do
    header = Components::Table::Header.new(
      id: "custom-header",
      "data-column": "name",
      scope: "col"
    )

    assert_has_attributes(header, "th", {
      id: "custom-header",
      "data-column": "name",
      scope: "col"
    })
  end

  # Test header with content and sorting
  test "renders header with content and sorting together" do
    header = Components::Table::Header.new(sortable: true, sorted: :asc) do
      "Name"
    end

    html = render_component(header)

    assert html.include?("Name"), "Should render header text"
    assert html.include?("↑"), "Should render sort indicator"
    assert html.include?("cursor-pointer"), "Should be clickable"
  end

  # Test edge cases
  test "handles edge cases gracefully" do
    # Invalid sorted value should not break rendering
    header_invalid = Components::Table::Header.new(sortable: true, sorted: :invalid)
    assert_renders_successfully(header_invalid)

    header_invalid_test = Components::Table::Header.new(sortable: true, sorted: :invalid)
    html = render_component(header_invalid_test)
    assert html.include?("↕"), "Invalid sort should default to unsorted indicator"

    # Sorted without sortable should not show indicators
    header_sorted_no_sortable = Components::Table::Header.new(sortable: false, sorted: :asc)
    html_no_sortable = render_component(header_sorted_no_sortable)
    refute html_no_sortable.include?("↑"), "Non-sortable header should not show sort indicators even if sorted is set"
  end

  # Test accessibility
  test "maintains accessibility standards" do
    # Should be a th element for semantic meaning
    header = Components::Table::Header.new
    assert_has_tag(header, "th")

    # Sortable header should be accessible
    sortable_header = Components::Table::Header.new(sortable: true) { "Name" }
    html = render_component(sortable_header)
    assert html.include?("Name"), "Header content should be accessible to screen readers"
  end
end
