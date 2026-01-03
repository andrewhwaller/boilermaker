# frozen_string_literal: true

require_relative "component_test_case"
require_relative "test_helpers"

class SectionTest < ComponentTestCase
  include ComponentTestHelpers

  test "renders section element successfully" do
    section = Components::Section.new(title: "Active Alerts")

    assert_renders_successfully(section)
    assert_produces_output(section)
    assert_has_tag(section, "section")
  end

  test "renders section title" do
    section = Components::Section.new(title: "Active Alerts")

    assert_has_text(section, "Active Alerts")
  end

  test "applies uppercase and tracking styles to title" do
    section = Components::Section.new(title: "Test")

    doc = render_and_parse(section)
    title_span = doc.css("span").first

    assert_includes title_span["class"], "uppercase"
    assert_includes title_span["class"], "tracking-widest"
  end

  test "renders action link when provided" do
    section = Components::Section.new(
      title: "Alerts",
      action_text: "+ New Alert",
      action_href: "/alerts/new"
    )

    doc = render_and_parse(section)
    link = doc.css("a").first

    assert link, "Should render action link"
    assert_equal "+ New Alert", link.text
    assert_equal "/alerts/new", link["href"]
  end

  test "does not render action link when not provided" do
    section = Components::Section.new(title: "Alerts")

    doc = render_and_parse(section)
    links = doc.css("a")

    assert links.empty?, "Should not render link when action not provided"
  end

  test "requires both action_text and action_href for link" do
    section = Components::Section.new(title: "Alerts", action_text: "Add")

    doc = render_and_parse(section)
    links = doc.css("a")

    assert links.empty?, "Should not render link without href"
  end

  test "renders content block" do
    section = Components::Section.new(title: "Content Test")

    html = render_component(section) { "Block content here" }

    assert html.include?("Block content here"), "Should render block content"
  end

  test "applies border styling to header" do
    section = Components::Section.new(title: "Styled")

    assert_has_css_class(section, "border-b")
    assert_has_css_class(section, "border-border-light")
  end

  test "accepts custom attributes" do
    section = Components::Section.new(
      title: "Custom",
      id: "custom-section",
      "data-testid": "section"
    )

    assert_has_attributes(section, "section", {
      id: "custom-section",
      "data-testid": "section"
    })
  end

  test "action link has accent color styling" do
    section = Components::Section.new(
      title: "Alerts",
      action_text: "Add",
      action_href: "/add"
    )

    doc = render_and_parse(section)
    link = doc.css("a").first

    assert_includes link["class"], "text-accent"
  end
end
