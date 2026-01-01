# frozen_string_literal: true

require_relative "component_test_case"
require_relative "test_helpers"

class BoxPanelTest < ComponentTestCase
  include ComponentTestHelpers

  test "renders successfully" do
    panel = Components::Boilermaker::BoxPanel.new(title: "Settings")

    assert_renders_successfully(panel)
    assert_produces_output(panel)
  end

  test "renders title text" do
    panel = Components::Boilermaker::BoxPanel.new(title: "User Options")

    assert_has_text(panel, "User Options")
  end

  test "applies accent border" do
    panel = Components::Boilermaker::BoxPanel.new(title: "Test")

    assert_has_css_class(panel, "border-2")
    assert_has_css_class(panel, "border-accent")
  end

  test "applies bottom margin" do
    panel = Components::Boilermaker::BoxPanel.new(title: "Test")

    assert_has_css_class(panel, "mb-4")
  end

  test "title bar has accent background" do
    panel = Components::Boilermaker::BoxPanel.new(title: "Test")

    assert_has_css_class(panel, "bg-accent")
  end

  test "title bar has surface text color" do
    panel = Components::Boilermaker::BoxPanel.new(title: "Test")

    assert_has_css_class(panel, "text-surface")
  end

  test "title bar has padding" do
    panel = Components::Boilermaker::BoxPanel.new(title: "Test")

    doc = render_and_parse(panel)
    title_div = doc.css("div.px-3.py-1").first

    assert title_div, "Should have padding"
  end

  test "title bar is bold" do
    panel = Components::Boilermaker::BoxPanel.new(title: "Test")

    assert_has_css_class(panel, "font-bold")
  end

  test "title bar has small text size" do
    panel = Components::Boilermaker::BoxPanel.new(title: "Test")

    assert_has_css_class(panel, "text-sm")
  end

  test "title bar has wide tracking" do
    panel = Components::Boilermaker::BoxPanel.new(title: "Test")

    assert_has_css_class(panel, "tracking-wide")
  end

  test "content area has padding" do
    panel = Components::Boilermaker::BoxPanel.new(title: "Test")

    assert_has_css_class(panel, "p-3")
  end

  test "yields block content" do
    html = render_component(
      Components::Boilermaker::BoxPanel.new(title: "Options")
    ) { "Content inside panel" }

    assert html.include?("Content inside panel"), "Should render block content"
  end

  test "renders with empty content" do
    panel = Components::Boilermaker::BoxPanel.new(title: "Empty")

    html = render_component(panel)
    doc = Nokogiri::HTML.fragment(html)

    # Should have title div and content div
    assert_equal 3, doc.css("div").count, "Should have wrapper, title bar, and content div"
  end

  test "accepts custom attributes" do
    panel = Components::Boilermaker::BoxPanel.new(
      title: "Test",
      id: "options-panel",
      "data-testid": "box-panel"
    )

    assert_has_attributes(panel, "div", {
      id: "options-panel",
      "data-testid" => "box-panel"
    })
  end
end
