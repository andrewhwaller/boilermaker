# frozen_string_literal: true

require_relative "component_test_case"
require_relative "test_helpers"

class AppFooterTest < ComponentTestCase
  include ComponentTestHelpers

  test "renders footer element successfully" do
    footer = Components::AppFooter.new

    assert_renders_successfully(footer)
    assert_produces_output(footer)
    assert_has_tag(footer, "footer")
  end

  test "renders status items" do
    status_items = [
      { label: "USPTO connected", online: true },
      { label: "Last sync: 2 min ago", online: false }
    ]
    footer = Components::AppFooter.new(status_items: status_items)

    assert_has_text(footer, "USPTO connected")
    assert_has_text(footer, "Last sync: 2 min ago")
  end

  test "renders online indicator dot for online status items" do
    status_items = [ { label: "Connected", online: true } ]
    footer = Components::AppFooter.new(status_items: status_items)

    doc = render_and_parse(footer)
    dots = doc.css("span.rounded-full")

    assert_equal 1, dots.length, "Should have one status dot"
    assert_includes dots.first["class"], "bg-accent-alt"
  end

  test "does not render dot for offline status items" do
    status_items = [ { label: "Disconnected", online: false } ]
    footer = Components::AppFooter.new(status_items: status_items)

    doc = render_and_parse(footer)
    dots = doc.css("span.rounded-full")

    assert dots.empty?, "Should not have status dot for offline items"
  end

  test "renders version text" do
    footer = Components::AppFooter.new(version_text: "PATENTWATCH v1.0")

    assert_has_text(footer, "PATENTWATCH v1.0")
  end

  test "does not render version section when not provided" do
    footer = Components::AppFooter.new

    html = render_component(footer)
    refute html.include?("v1.0"), "Should not have version text"
  end

  test "applies correct border and background classes" do
    footer = Components::AppFooter.new

    assert_has_css_class(footer, "border-t")
    assert_has_css_class(footer, "border-border-light")
    assert_has_css_class(footer, "bg-surface")
  end

  test "accepts custom attributes" do
    footer = Components::AppFooter.new(
      id: "main-footer",
      "data-testid": "app-footer"
    )

    assert_has_attributes(footer, "footer", {
      id: "main-footer",
      "data-testid": "app-footer"
    })
  end

  test "uses StatusItem data structure" do
    status_item = Components::AppFooter::StatusItem.new(
      label: "Connected",
      online: true
    )

    assert_equal "Connected", status_item.label
    assert status_item.online
  end

  test "StatusItem defaults online to false" do
    status_item = Components::AppFooter::StatusItem.new(label: "Status")

    refute status_item.online
  end
end
