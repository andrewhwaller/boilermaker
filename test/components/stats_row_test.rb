# frozen_string_literal: true

require_relative "component_test_case"
require_relative "test_helpers"

class StatsRowTest < ComponentTestCase
  include ComponentTestHelpers

  test "renders successfully" do
    stats = [{ value: "10", label: "items" }]
    row = Components::StatsRow.new(stats: stats)

    assert_renders_successfully(row)
    assert_produces_output(row)
  end

  test "renders multiple stats" do
    stats = [
      { value: "47", label: "new today" },
      { value: "183", label: "this week" },
      { value: "12", label: "active" }
    ]
    row = Components::StatsRow.new(stats: stats)

    assert_has_text(row, "47")
    assert_has_text(row, "new today")
    assert_has_text(row, "183")
    assert_has_text(row, "this week")
    assert_has_text(row, "12")
    assert_has_text(row, "active")
  end

  test "applies highlight styling to highlighted stats" do
    stats = [{ value: "47", label: "new", highlight: true }]
    row = Components::StatsRow.new(stats: stats)

    doc = render_and_parse(row)
    value_span = doc.css("span.font-bold").first

    assert_includes value_span["class"], "text-accent"
  end

  test "applies normal styling to non-highlighted stats" do
    stats = [{ value: "100", label: "total", highlight: false }]
    row = Components::StatsRow.new(stats: stats)

    doc = render_and_parse(row)
    value_span = doc.css("span.font-bold").first

    assert_includes value_span["class"], "text-body"
  end

  test "applies flex layout with gap" do
    stats = [{ value: "1", label: "test" }]
    row = Components::StatsRow.new(stats: stats)

    assert_has_css_class(row, "flex")
    assert_has_css_class(row, "gap-8")
  end

  test "renders stat value with bold font" do
    stats = [{ value: "42", label: "count" }]
    row = Components::StatsRow.new(stats: stats)

    doc = render_and_parse(row)
    value_span = doc.css("span.font-bold").first

    assert value_span, "Should have bold value span"
    assert_equal "42", value_span.text
  end

  test "renders stat label with muted styling" do
    stats = [{ value: "1", label: "item" }]
    row = Components::StatsRow.new(stats: stats)

    doc = render_and_parse(row)
    label_span = doc.css("span.text-muted").first

    assert label_span, "Should have muted label span"
    assert_equal "item", label_span.text
  end

  test "accepts custom attributes" do
    stats = [{ value: "1", label: "test" }]
    row = Components::StatsRow.new(
      stats: stats,
      id: "stats-row",
      "data-testid": "stats"
    )

    assert_has_attributes(row, "div", {
      id: "stats-row",
      "data-testid": "stats"
    })
  end

  test "uses Stat data structure" do
    stat = Components::StatsRow::Stat.new(
      value: "99",
      label: "percent",
      highlight: true
    )

    assert_equal "99", stat.value
    assert_equal "percent", stat.label
    assert stat.highlight
  end

  test "Stat defaults highlight to false" do
    stat = Components::StatsRow::Stat.new(value: "0", label: "none")

    refute stat.highlight
  end
end
