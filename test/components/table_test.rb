# frozen_string_literal: true

require_relative "component_test_case"
require_relative "test_helpers"

class TableTest < ComponentTestCase
  include ComponentTestHelpers

  # Test basic table rendering
  test "renders table element successfully" do
    table = Components::Table.new
    assert_renders_successfully(table)

    table_output = Components::Table.new
    assert_produces_output(table_output)

    table_tag = Components::Table.new
    assert_has_tag(table_tag, "table")
  end

  # Test default table configuration
  test "renders with default configuration" do
    table = Components::Table.new
    assert_has_css_class(table, "ui-table")

    # Should not have variant class by default
    table_default = Components::Table.new
    html = render_component(table_default)
    refute html.include?("ui-table-striped"), "Default table should not have striped variant"
    refute html.include?("ui-table-bordered"), "Default table should not have bordered variant"
  end

  # Test all available table variants
  test "renders all table variants correctly" do
    Components::Table::VARIANTS.each do |variant, expected_class|
      table_base = Components::Table.new(variant: variant)
      assert_has_css_class(table_base, "ui-table",
        "Table with variant #{variant} should have base 'ui-table' class")

      table_variant = Components::Table.new(variant: variant)
      assert_has_css_class(table_variant, expected_class,
        "Table with variant #{variant} should have class '#{expected_class}'")
    end
  end

  # Test all available table sizes
  test "renders all table sizes correctly" do
    Components::Table::SIZES.each do |size, expected_class|
      table = Components::Table.new(size: size)

      if expected_class.present?
        assert_has_css_class(table, expected_class,
          "Table with size #{size} should have class '#{expected_class}'")
      else
        # Medium size should not have a size class
        html = render_component(table)
        refute html.match?(/ui-table-(xs|sm|lg)/),
          "Medium table should not have explicit size class"
      end
    end
  end

  # Test table with headers
  test "renders table with headers correctly" do
    headers = [ "Name", "Email", "Role" ]
    table = Components::Table.new(headers: headers)

    html = render_component(table)

    # Should have thead element
    assert html.include?("<thead>"), "Table should have thead element"

    # Should have th elements for each header
    headers.each do |header|
      assert html.include?("<th>#{header}</th>"), "Table should have th element for #{header}"
    end
  end

  # Test table with array data
  test "renders table with array data correctly" do
    headers = [ "Name", "Age" ]
    data = [
      [ "John", "30" ],
      [ "Jane", "25" ]
    ]

    table = Components::Table.new(headers: headers, data: data)
    html = render_component(table)

    # Should have tbody element
    assert html.include?("<tbody>"), "Table should have tbody element"

    # Should have tr elements for each row
    assert html.scan("<tr>").length >= 2, "Table should have at least 2 tr elements in tbody"

    # Should have td elements with data
    assert html.include?("<td>John</td>"), "Table should have John data"
    assert html.include?("<td>30</td>"), "Table should have age 30 data"
    assert html.include?("<td>Jane</td>"), "Table should have Jane data"
    assert html.include?("<td>25</td>"), "Table should have age 25 data"
  end

  # Test table with hash data
  test "renders table with hash data correctly" do
    headers = [ "name", "age", "role" ]
    data = [
      { "name" => "John", "age" => "30", "role" => "Admin" },
      { "name" => "Jane", "age" => "25", "role" => "User" }
    ]

    table = Components::Table.new(headers: headers, data: data)
    html = render_component(table)

    # Should render hash values in correct order
    assert html.include?("<td>John</td>"), "Table should have John data"
    assert html.include?("<td>Admin</td>"), "Table should have Admin role"
    assert html.include?("<td>Jane</td>"), "Table should have Jane data"
    assert html.include?("<td>User</td>"), "Table should have User role"
  end

  # Test table with empty data
  test "renders table with empty data correctly" do
    headers = [ "Name", "Email" ]
    table = Components::Table.new(headers: headers, data: [])

    html = render_component(table)

    # Should show "No data available" message
    assert html.include?("No data available"), "Table should show no data message when empty"

    # Should have proper colspan
    assert html.include?('colspan="2"'), "Empty message should span all columns"
  end

  # Test table without headers
  test "renders table without headers correctly" do
    data = [ [ "John", "30" ], [ "Jane", "25" ] ]
    table = Components::Table.new(data: data)

    html = render_component(table)

    # Should not have thead element
    refute html.include?("<thead>"), "Table without headers should not have thead"

    # Should still have tbody with data
    assert html.include?("<tbody>"), "Table should have tbody element"
    assert html.include?("<td>John</td>"), "Table should have data"
  end

  # Test table with custom attributes
  test "renders table with custom attributes" do
    table = Components::Table.new(
      id: "custom-table",
      "data-testid": "table-component",
      role: "grid"
    )

    assert_has_attributes(table, "table", {
      id: "custom-table",
      "data-testid": "table-component",
      role: "grid"
    })
  end

  # Test table with block content
  test "renders table with custom block content" do
    # Test that block content is accepted and renders without errors
    table_with_block = Components::Table.new do
      # Simple text content to verify block is accepted
      "Custom table content"
    end

    assert_renders_successfully(table_with_block)

    # Use separate instance for HTML testing
    table_content_test = Components::Table.new do
      "Custom table content"
    end
    html = render_component(table_content_test)
    assert html.include?("Custom table content"), "Table should render block content"
  end

  # Test table combinations
  test "renders table with multiple option combinations correctly" do
    # Striped compact table
    striped_compact = Components::Table.new(
      variant: :striped,
      size: :sm
    )

    assert_has_css_class(striped_compact, [ "ui-table", "ui-table-striped", "ui-table-sm" ])

    # Header pin large table
    header_pin_large = Components::Table.new(
      variant: :header_pin,
      size: :lg
    )

    assert_has_css_class(header_pin_large, [ "ui-table", "ui-table-header-pin", "ui-table-lg" ])
  end

  # Test edge cases
  test "handles edge cases gracefully" do
    # Invalid variant should not break rendering
    table_invalid_variant = Components::Table.new(variant: :invalid)
    assert_renders_successfully(table_invalid_variant)

    # Invalid size should not break rendering
    table_invalid_size = Components::Table.new(size: :invalid)
    assert_renders_successfully(table_invalid_size)

    # Nil data should not break rendering
    table_nil_data = Components::Table.new(data: nil)
    assert_renders_successfully(table_nil_data)

    # Mixed data types in array
    mixed_data = [ [ "string", 123 ], [ true, nil ] ]
    table_mixed = Components::Table.new(data: mixed_data)
    assert_renders_successfully(table_mixed)
  end

  # Test CSS class generation logic
  test "generates clean CSS class strings" do
    table = Components::Table.new(variant: :zebra, size: :md)
    html = render_component(table)

    # Should not have double spaces or trailing/leading spaces
    refute html.match?(/class="[^"]*\s{2,}[^"]*"/), "Should not have multiple consecutive spaces in class"
    refute html.match?(/class="\s/), "Should not start with space"
    refute html.match?(/\s"/), "Should not end with space"
  end

  # Test accessibility
  test "maintains accessibility standards" do
    headers = [ "Name", "Email", "Role" ]
    data = [ [ "John", "john@example.com", "Admin" ] ]

    # Should be a table element for semantic meaning
    table_tag = Components::Table.new(headers: headers, data: data)
    assert_has_tag(table_tag, "table")

    # Test table structure
    table_structure = Components::Table.new(headers: headers, data: data)
    html = render_component(table_structure)

    # Should have proper table structure
    assert html.include?("<thead>"), "Table should have thead for accessibility"
    assert html.include?("<tbody>"), "Table should have tbody for accessibility"
    assert html.include?("<th>"), "Table should have th elements for accessibility"
    assert html.include?("<td>"), "Table should have td elements for accessibility"
  end

  # Test data type handling
  test "handles different data types correctly" do
    # String data
    string_data = [ [ "text", "more text" ] ]
    table_string = Components::Table.new(data: string_data)
    html_string = render_component(table_string)
    assert html_string.include?("text"), "Should handle string data"

    # Numeric data
    numeric_data = [ [ 123, 456.78 ] ]
    table_numeric = Components::Table.new(data: numeric_data)
    html_numeric = render_component(table_numeric)
    assert html_numeric.include?("123"), "Should handle integer data"
    assert html_numeric.include?("456.78"), "Should handle float data"

    # Boolean data
    boolean_data = [ [ true, false ] ]
    table_boolean = Components::Table.new(data: boolean_data)
    html_boolean = render_component(table_boolean)
    assert html_boolean.include?("true"), "Should handle boolean true"
    assert html_boolean.include?("false"), "Should handle boolean false"

    # Nil data
    nil_data = [ [ nil, "not nil" ] ]
    table_nil = Components::Table.new(data: nil_data)
    html_nil = render_component(table_nil)
    assert html_nil.include?("not nil"), "Should handle nil values gracefully"
  end

  # Test performance with larger datasets
  test "handles moderate datasets efficiently" do
    # Create 50 rows of data
    large_data = 50.times.map { |i| [ "User #{i}", "user#{i}@example.com", "Role #{i % 3}" ] }
    headers = [ "Name", "Email", "Role" ]

    # Should render without errors
    table_render = Components::Table.new(headers: headers, data: large_data)
    assert_renders_successfully(table_render)

    # Test content
    table_content = Components::Table.new(headers: headers, data: large_data)
    html = render_component(table_content)

    # Should contain first and last entries
    assert html.include?("User 0"), "Should render first row"
    assert html.include?("User 49"), "Should render last row"

    # Should have correct number of data rows (50 + 1 header row)
    tr_count = html.scan("<tr>").length
    assert tr_count >= 50, "Should have at least 50 data rows"
  end
end
