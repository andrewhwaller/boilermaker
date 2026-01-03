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
