# frozen_string_literal: true

require_relative "component_test_case"
require_relative "test_helpers"

class TabbedNavTest < ComponentTestCase
  include ComponentTestHelpers

  def sample_tabs
    [
      { label: "Dashboard", href: "/", active: true },
      { label: "Alerts", href: "/alerts" },
      { label: "Search", href: "/search" }
    ]
  end

  test "renders successfully" do
    nav = Components::Boilermaker::TabbedNav.new(tabs: sample_tabs)

    assert_renders_successfully(nav)
    assert_produces_output(nav)
  end

  test "renders nav element" do
    nav = Components::Boilermaker::TabbedNav.new(tabs: sample_tabs)

    assert_has_tag(nav, "nav")
  end

  test "renders all tab links" do
    nav = Components::Boilermaker::TabbedNav.new(tabs: sample_tabs)

    doc = render_and_parse(nav)
    links = doc.css("a")

    assert_equal 3, links.count
  end

  test "renders tab labels" do
    nav = Components::Boilermaker::TabbedNav.new(tabs: sample_tabs)

    assert_has_text(nav, "Dashboard")
    assert_has_text(nav, "Alerts")
    assert_has_text(nav, "Search")
  end

  test "renders tab hrefs" do
    nav = Components::Boilermaker::TabbedNav.new(tabs: sample_tabs)

    doc = render_and_parse(nav)
    hrefs = doc.css("a").map { |a| a["href"] }

    assert_includes hrefs, "/"
    assert_includes hrefs, "/alerts"
    assert_includes hrefs, "/search"
  end

  test "applies flex layout to nav" do
    nav = Components::Boilermaker::TabbedNav.new(tabs: sample_tabs)

    assert_has_css_class(nav, "flex")
  end

  test "applies accent border bottom" do
    nav = Components::Boilermaker::TabbedNav.new(tabs: sample_tabs)

    assert_has_css_class(nav, "border-b-2")
    assert_has_css_class(nav, "border-accent")
  end

  test "applies bottom margin" do
    nav = Components::Boilermaker::TabbedNav.new(tabs: sample_tabs)

    assert_has_css_class(nav, "mb-8")
  end

  test "active tab has accent text color" do
    nav = Components::Boilermaker::TabbedNav.new(tabs: sample_tabs)

    doc = render_and_parse(nav)
    active_link = doc.css("a").find { |a| a.text == "Dashboard" }

    assert active_link["class"].include?("text-accent")
  end

  test "active tab has border styling" do
    nav = Components::Boilermaker::TabbedNav.new(tabs: sample_tabs)

    doc = render_and_parse(nav)
    active_link = doc.css("a").find { |a| a.text == "Dashboard" }

    assert active_link["class"].include?("border-accent")
    assert active_link["class"].include?("bg-surface")
  end

  test "inactive tab has muted text color" do
    nav = Components::Boilermaker::TabbedNav.new(tabs: sample_tabs)

    doc = render_and_parse(nav)
    inactive_link = doc.css("a").find { |a| a.text == "Alerts" }

    assert inactive_link["class"].include?("text-muted")
  end

  test "inactive tab has hover styling" do
    nav = Components::Boilermaker::TabbedNav.new(tabs: sample_tabs)

    doc = render_and_parse(nav)
    inactive_link = doc.css("a").find { |a| a.text == "Alerts" }

    assert inactive_link["class"].include?("hover:text-accent")
  end

  test "tabs have uppercase styling" do
    nav = Components::Boilermaker::TabbedNav.new(tabs: sample_tabs)

    doc = render_and_parse(nav)
    first_link = doc.css("a").first

    assert first_link["class"].include?("uppercase")
  end

  test "tabs have letter-spacing styling" do
    nav = Components::Boilermaker::TabbedNav.new(tabs: sample_tabs)

    doc = render_and_parse(nav)
    first_link = doc.css("a").first

    assert first_link["class"].include?("tracking-[0.08em]")
  end

  test "tabs have 11px font size" do
    nav = Components::Boilermaker::TabbedNav.new(tabs: sample_tabs)

    doc = render_and_parse(nav)
    first_link = doc.css("a").first

    assert first_link["class"].include?("text-[11px]")
  end

  test "accepts Tab data objects" do
    tabs = [
      Components::Boilermaker::TabbedNav::Tab.new(label: "Home", href: "/home", active: true),
      Components::Boilermaker::TabbedNav::Tab.new(label: "About", href: "/about")
    ]
    nav = Components::Boilermaker::TabbedNav.new(tabs: tabs)

    assert_has_text(nav, "Home")
    assert_has_text(nav, "About")
  end

  test "accepts custom attributes" do
    nav = Components::Boilermaker::TabbedNav.new(
      tabs: sample_tabs,
      id: "main-nav",
      "data-testid": "tabbed-nav"
    )

    assert_has_attributes(nav, "nav", {
      id: "main-nav",
      "data-testid" => "tabbed-nav"
    })
  end

  test "tabs have negative margin for overlap" do
    nav = Components::Boilermaker::TabbedNav.new(tabs: sample_tabs)

    html = render_component(nav)
    assert html.include?("-mb-[2px]"), "Tabs should have negative margin"
  end

  test "tabs have padding" do
    nav = Components::Boilermaker::TabbedNav.new(tabs: sample_tabs)

    doc = render_and_parse(nav)
    first_link = doc.css("a").first

    assert first_link["class"].include?("px-5")
    assert first_link["class"].include?("py-2.5")
  end
end
