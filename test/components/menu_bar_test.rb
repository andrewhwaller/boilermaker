# frozen_string_literal: true

require_relative "component_test_case"
require_relative "test_helpers"

class MenuBarTest < ComponentTestCase
  include ComponentTestHelpers

  def sample_items
    [
      { label: "File", hotkey_index: 0, href: "#file" },
      { label: "Edit", hotkey_index: 0, href: "#edit" },
      { label: "View", hotkey_index: 0, href: "#view" }
    ]
  end

  test "renders successfully" do
    bar = Components::MenuBar.new(items: sample_items)

    assert_renders_successfully(bar)
    assert_produces_output(bar)
  end

  test "renders all menu items" do
    bar = Components::MenuBar.new(items: sample_items)

    doc = render_and_parse(bar)
    links = doc.css("a")

    assert_equal 3, links.count
  end

  test "renders item labels" do
    bar = Components::MenuBar.new(items: sample_items)

    doc = render_and_parse(bar)
    text = doc.text

    assert text.include?("File"), "Should contain 'File' text"
    assert text.include?("Edit"), "Should contain 'Edit' text"
    assert text.include?("View"), "Should contain 'View' text"
  end

  test "renders item hrefs" do
    bar = Components::MenuBar.new(items: sample_items)

    doc = render_and_parse(bar)
    hrefs = doc.css("a").map { |a| a["href"] }

    assert_includes hrefs, "#file"
    assert_includes hrefs, "#edit"
    assert_includes hrefs, "#view"
  end

  test "applies flex layout" do
    bar = Components::MenuBar.new(items: sample_items)

    assert_has_css_class(bar, "flex")
  end

  test "applies accent background" do
    bar = Components::MenuBar.new(items: sample_items)

    assert_has_css_class(bar, "bg-accent")
  end

  test "applies surface text color" do
    bar = Components::MenuBar.new(items: sample_items)

    assert_has_css_class(bar, "text-surface")
  end

  test "applies text-sm styling" do
    bar = Components::MenuBar.new(items: sample_items)

    assert_has_css_class(bar, "text-sm")
  end

  test "underlines hotkey character" do
    bar = Components::MenuBar.new(items: sample_items)

    doc = render_and_parse(bar)
    underlined_spans = doc.css("span.underline")

    assert underlined_spans.count >= 3, "Each item should have underlined hotkey"
    assert_equal "F", underlined_spans[0].text
    assert_equal "E", underlined_spans[1].text
    assert_equal "V", underlined_spans[2].text
  end

  test "underlines correct character based on hotkey_index" do
    items = [{ label: "Help", hotkey_index: 0 }]
    bar = Components::MenuBar.new(items: items)

    doc = render_and_parse(bar)
    underlined = doc.css("span.underline").first

    assert_equal "H", underlined.text
  end

  test "underlines middle character when hotkey_index is non-zero" do
    items = [{ label: "Help", hotkey_index: 2 }]
    bar = Components::MenuBar.new(items: items)

    doc = render_and_parse(bar)
    underlined = doc.css("span.underline").first

    assert_equal "l", underlined.text
  end

  test "active item has surface background" do
    items = [{ label: "File", active: true }]
    bar = Components::MenuBar.new(items: items)

    doc = render_and_parse(bar)
    active_link = doc.css("a").first

    assert active_link["class"].include?("bg-surface")
  end

  test "active item has accent text" do
    items = [{ label: "File", active: true }]
    bar = Components::MenuBar.new(items: items)

    doc = render_and_parse(bar)
    active_link = doc.css("a").first

    assert active_link["class"].include?("text-accent")
  end

  test "inactive item has hover styling" do
    items = [{ label: "File", active: false }]
    bar = Components::MenuBar.new(items: items)

    doc = render_and_parse(bar)
    link = doc.css("a").first

    assert link["class"].include?("hover:bg-surface")
    assert link["class"].include?("hover:text-accent")
  end

  test "items have padding" do
    bar = Components::MenuBar.new(items: sample_items)

    doc = render_and_parse(bar)
    first_link = doc.css("a").first

    assert first_link["class"].include?("px-4")
    assert first_link["class"].include?("py-1")
  end

  test "accepts Item data objects" do
    items = [
      Components::MenuBar::Item.new(label: "File", hotkey_index: 0, href: "#file"),
      Components::MenuBar::Item.new(label: "Help", hotkey_index: 0, href: "#help")
    ]
    bar = Components::MenuBar.new(items: items)

    doc = render_and_parse(bar)
    text = doc.text

    assert text.include?("File"), "Should contain 'File' text"
    assert text.include?("Help"), "Should contain 'Help' text"
  end

  test "default href is #" do
    items = [{ label: "File" }]
    bar = Components::MenuBar.new(items: items)

    doc = render_and_parse(bar)
    link = doc.css("a").first

    assert_equal "#", link["href"]
  end

  test "accepts custom attributes" do
    bar = Components::MenuBar.new(
      items: sample_items,
      id: "main-menu",
      "data-testid": "menu-bar"
    )

    assert_has_attributes(bar, "div", {
      id: "main-menu",
      "data-testid" => "menu-bar"
    })
  end
end
