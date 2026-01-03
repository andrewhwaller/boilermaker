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
    bar = Components::Boilermaker::MenuBar.new(items: sample_items)

    assert_renders_successfully(bar)
    assert_produces_output(bar)
  end

  test "renders all menu items" do
    bar = Components::Boilermaker::MenuBar.new(items: sample_items)

    doc = render_and_parse(bar)
    links = doc.css("a")

    assert_equal 3, links.count
  end

  test "renders item labels" do
    bar = Components::Boilermaker::MenuBar.new(items: sample_items)

    doc = render_and_parse(bar)
    text = doc.text

    assert text.include?("File"), "Should contain 'File' text"
    assert text.include?("Edit"), "Should contain 'Edit' text"
    assert text.include?("View"), "Should contain 'View' text"
  end

  test "renders item hrefs" do
    bar = Components::Boilermaker::MenuBar.new(items: sample_items)

    doc = render_and_parse(bar)
    hrefs = doc.css("a").map { |a| a["href"] }

    assert_includes hrefs, "#file"
    assert_includes hrefs, "#edit"
    assert_includes hrefs, "#view"
  end

  test "underlines hotkey character at index 0" do
    bar = Components::Boilermaker::MenuBar.new(items: sample_items)

    doc = render_and_parse(bar)
    underlined_spans = doc.css("span.underline")

    assert underlined_spans.count >= 3, "Each item should have underlined hotkey"
    assert_equal "F", underlined_spans[0].text
    assert_equal "E", underlined_spans[1].text
    assert_equal "V", underlined_spans[2].text
  end

  test "underlines correct character based on hotkey_index" do
    items = [ { label: "Help", hotkey_index: 2 } ]
    bar = Components::Boilermaker::MenuBar.new(items: items)

    doc = render_and_parse(bar)
    underlined = doc.css("span.underline").first

    assert_equal "l", underlined.text
  end

  test "active item has different styling than inactive" do
    items = [
      { label: "File", active: true },
      { label: "Edit", active: false }
    ]
    bar = Components::Boilermaker::MenuBar.new(items: items)

    doc = render_and_parse(bar)
    links = doc.css("a")

    # Active and inactive should have different classes
    assert_not_equal links[0]["class"], links[1]["class"]
  end

  test "accepts Item data objects" do
    items = [
      Components::Boilermaker::MenuBar::Item.new(label: "File", hotkey_index: 0, href: "#file"),
      Components::Boilermaker::MenuBar::Item.new(label: "Help", hotkey_index: 0, href: "#help")
    ]
    bar = Components::Boilermaker::MenuBar.new(items: items)

    doc = render_and_parse(bar)
    text = doc.text

    assert text.include?("File"), "Should contain 'File' text"
    assert text.include?("Help"), "Should contain 'Help' text"
  end

  test "default href is #" do
    items = [ { label: "File" } ]
    bar = Components::Boilermaker::MenuBar.new(items: items)

    doc = render_and_parse(bar)
    link = doc.css("a").first

    assert_equal "#", link["href"]
  end

  test "accepts custom attributes" do
    bar = Components::Boilermaker::MenuBar.new(
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
