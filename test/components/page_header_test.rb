# frozen_string_literal: true

require_relative "component_test_case"
require_relative "test_helpers"

class PageHeaderTest < ComponentTestCase
  include ComponentTestHelpers

  test "renders successfully" do
    header = Components::PageHeader.new(title: "Dashboard")

    assert_renders_successfully(header)
    assert_produces_output(header)
  end

  test "renders title" do
    header = Components::PageHeader.new(title: "Your Alerts")

    assert_has_tag(header, "h1")
    assert_has_text(header, "Your Alerts")
  end

  test "renders meta text when provided" do
    header = Components::PageHeader.new(
      title: "Your Alerts",
      meta: "Monitoring 12 keyword sets"
    )

    assert_has_tag(header, "p")
    assert_has_text(header, "Monitoring 12 keyword sets")
  end

  test "does not render meta when not provided" do
    header = Components::PageHeader.new(title: "Dashboard")

    doc = render_and_parse(header)
    paragraphs = doc.css("p")

    assert paragraphs.empty?, "Should not render p element when no meta"
  end

  test "renders stats row" do
    stats = [
      { value: "47", label: "new today", highlight: true },
      { value: "183", label: "this week", highlight: false }
    ]
    header = Components::PageHeader.new(title: "Alerts", stats: stats)

    assert_has_text(header, "47")
    assert_has_text(header, "new today")
    assert_has_text(header, "183")
    assert_has_text(header, "this week")
  end

  test "applies highlight styling to highlighted stats" do
    stats = [{ value: "47", label: "new", highlight: true }]
    header = Components::PageHeader.new(title: "Alerts", stats: stats)

    doc = render_and_parse(header)
    value_span = doc.css("span.font-bold").first

    assert_includes value_span["class"], "text-accent"
  end

  test "applies normal styling to non-highlighted stats" do
    stats = [{ value: "100", label: "total", highlight: false }]
    header = Components::PageHeader.new(title: "Alerts", stats: stats)

    doc = render_and_parse(header)
    value_span = doc.css("span.font-bold").first

    assert_includes value_span["class"], "text-body"
  end

  test "does not render stats section when empty" do
    header = Components::PageHeader.new(title: "Dashboard")

    html = render_component(header)
    # Stats section has gap-8 class
    refute html.include?("gap-8"), "Should not render stats section when empty"
  end

  test "accepts custom attributes" do
    header = Components::PageHeader.new(
      title: "Dashboard",
      id: "page-header",
      "data-testid": "header"
    )

    assert_has_attributes(header, "div", {
      id: "page-header",
      "data-testid": "header"
    })
  end

  test "uses Stat data structure" do
    stat = Components::PageHeader::Stat.new(
      value: "42",
      label: "items",
      highlight: true
    )

    assert_equal "42", stat.value
    assert_equal "items", stat.label
    assert stat.highlight
  end

  test "Stat defaults highlight to false" do
    stat = Components::PageHeader::Stat.new(value: "1", label: "test")

    refute stat.highlight
  end
end
