# frozen_string_literal: true

require_relative "component_test_case"
require_relative "test_helpers"

class ResultsTableTest < ComponentTestCase
  include ComponentTestHelpers

  test "renders table element successfully" do
    columns = [{ key: :id, label: "ID" }]
    rows = [{ id: "1" }]
    table = Components::ResultsTable.new(columns: columns, rows: rows)

    assert_renders_successfully(table)
    assert_produces_output(table)
    assert_has_tag(table, "table")
  end

  test "renders thead and tbody" do
    columns = [{ key: :name, label: "Name" }]
    rows = [{ name: "Test" }]
    table = Components::ResultsTable.new(columns: columns, rows: rows)

    assert_has_tag(table, "thead")
    assert_has_tag(table, "tbody")
  end

  test "renders column headers" do
    columns = [
      { key: :patent_id, label: "Patent" },
      { key: :title, label: "Title" },
      { key: :assignee, label: "Assignee" }
    ]
    rows = []
    table = Components::ResultsTable.new(columns: columns, rows: rows)

    doc = render_and_parse(table)
    headers = doc.css("th")

    assert_equal 3, headers.length
    assert_equal "Patent", headers[0].text
    assert_equal "Title", headers[1].text
    assert_equal "Assignee", headers[2].text
  end

  test "renders row data" do
    columns = [
      { key: :id, label: "ID" },
      { key: :name, label: "Name" }
    ]
    rows = [
      { id: "001", name: "First" },
      { id: "002", name: "Second" }
    ]
    table = Components::ResultsTable.new(columns: columns, rows: rows)

    assert_has_text(table, "001")
    assert_has_text(table, "First")
    assert_has_text(table, "002")
    assert_has_text(table, "Second")
  end

  test "renders link cells with href" do
    columns = [{ key: :patent, label: "Patent" }]
    rows = [{ patent: { text: "US2024001", href: "/patents/1" } }]
    table = Components::ResultsTable.new(columns: columns, rows: rows)

    doc = render_and_parse(table)
    link = doc.css("a").first

    assert link, "Should render link"
    assert_equal "/patents/1", link["href"]
    assert_equal "US2024001", link.text
  end

  test "applies column width when specified" do
    columns = [{ key: :id, label: "ID", width: "130px" }]
    rows = [{ id: "1" }]
    table = Components::ResultsTable.new(columns: columns, rows: rows)

    doc = render_and_parse(table)
    header = doc.css("th").first

    assert_equal "width: 130px", header["style"]
  end

  test "applies cell_class when specified" do
    columns = [{ key: :score, label: "Score", cell_class: "font-bold text-accent" }]
    rows = [{ score: "94%" }]
    table = Components::ResultsTable.new(columns: columns, rows: rows)

    doc = render_and_parse(table)
    cell = doc.css("td").first

    assert_includes cell["class"], "font-bold"
    assert_includes cell["class"], "text-accent"
  end

  test "applies table styling" do
    columns = [{ key: :a, label: "A" }]
    rows = []
    table = Components::ResultsTable.new(columns: columns, rows: rows)

    assert_has_css_class(table, "w-full")
    assert_has_css_class(table, "border-collapse")
    assert_has_css_class(table, "border")
    assert_has_css_class(table, "border-border-default")
  end

  test "applies hover styling to rows" do
    columns = [{ key: :a, label: "A" }]
    rows = [{ a: "test" }]
    table = Components::ResultsTable.new(columns: columns, rows: rows)

    doc = render_and_parse(table)
    row = doc.css("tbody tr").first

    assert_includes row["class"], "hover:bg-surface-alt"
  end

  test "applies header styling" do
    columns = [{ key: :a, label: "Header" }]
    rows = []
    table = Components::ResultsTable.new(columns: columns, rows: rows)

    doc = render_and_parse(table)
    header = doc.css("th").first

    assert_includes header["class"], "uppercase"
    assert_includes header["class"], "bg-surface-alt"
  end

  test "accepts custom attributes" do
    columns = [{ key: :a, label: "A" }]
    rows = []
    table = Components::ResultsTable.new(
      columns: columns,
      rows: rows,
      id: "results-table",
      "data-testid": "table"
    )

    assert_has_attributes(table, "table", {
      id: "results-table",
      "data-testid": "table"
    })
  end

  test "uses Column data structure" do
    column = Components::ResultsTable::Column.new(
      key: :patent_id,
      label: "Patent",
      width: "100px",
      cell_class: "font-mono"
    )

    assert_equal :patent_id, column.key
    assert_equal "Patent", column.label
    assert_equal "100px", column.width
    assert_equal "font-mono", column.cell_class
  end

  test "Column defaults width and cell_class to nil" do
    column = Components::ResultsTable::Column.new(key: :id, label: "ID")

    assert_nil column.width
    assert_nil column.cell_class
  end
end
