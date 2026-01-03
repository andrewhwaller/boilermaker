# frozen_string_literal: true

require_relative "component_test_case"
require_relative "test_helpers"

class AppHeaderTest < ComponentTestCase
  include ComponentTestHelpers

  test "renders header element successfully" do
    header = Components::AppHeader.new(logo_text: "TESTAPP")

    assert_renders_successfully(header)
    assert_produces_output(header)
    assert_has_tag(header, "header")
  end

  test "renders logo text" do
    header = Components::AppHeader.new(logo_text: "PATENTWATCH")

    assert_has_text(header, "PATENTWATCH")
  end

  test "renders navigation items" do
    nav_items = [
      { label: "Alerts", href: "/alerts", active: true },
      { label: "Search", href: "/search", active: false }
    ]
    header = Components::AppHeader.new(logo_text: "APP", nav_items: nav_items)

    doc = render_and_parse(header)

    assert_has_tag(header, "nav")
    assert_has_text(header, "Alerts")
    assert_has_text(header, "Search")

    links = doc.css("nav a")
    assert_equal 2, links.length
    assert_equal "/alerts", links[0]["href"]
    assert_equal "/search", links[1]["href"]
  end

  test "applies active styling to active nav items" do
    nav_items = [
      { label: "Alerts", href: "/alerts", active: true },
      { label: "Search", href: "/search", active: false }
    ]
    header = Components::AppHeader.new(logo_text: "APP", nav_items: nav_items)

    doc = render_and_parse(header)
    links = doc.css("nav a")

    assert_includes links[0]["class"], "text-body"
    assert_includes links[1]["class"], "text-muted"
  end

  test "renders user email when provided" do
    header = Components::AppHeader.new(
      logo_text: "APP",
      user_email: "user@company.com"
    )

    assert_has_text(header, "user@company.com")
  end

  test "does not render user section when email not provided" do
    header = Components::AppHeader.new(logo_text: "APP")

    html = render_component(header)
    refute html.include?("@"), "Should not render email-like content"
  end

  test "does not render nav section when no items provided" do
    header = Components::AppHeader.new(logo_text: "APP")

    doc = render_and_parse(header)
    nav = doc.css("nav")

    assert nav.empty?, "Should not render nav element when no items"
  end

  test "applies correct border and background classes" do
    header = Components::AppHeader.new(logo_text: "APP")

    assert_has_css_class(header, "border-b-2")
    assert_has_css_class(header, "border-border-default")
    assert_has_css_class(header, "bg-surface")
  end

  test "accepts custom attributes" do
    header = Components::AppHeader.new(
      logo_text: "APP",
      id: "main-header",
      "data-testid": "app-header"
    )

    assert_has_attributes(header, "header", {
      id: "main-header",
      "data-testid": "app-header"
    })
  end

  test "uses NavItem data structure" do
    nav_item = Components::AppHeader::NavItem.new(
      label: "Dashboard",
      href: "/dash",
      active: true
    )

    assert_equal "Dashboard", nav_item.label
    assert_equal "/dash", nav_item.href
    assert nav_item.active
  end
end
