# frozen_string_literal: true

require_relative "component_test_case"
require_relative "test_helpers"

class IndexedListTest < ComponentTestCase
  include ComponentTestHelpers

  test "renders successfully with items" do
    list = Components::Boilermaker::IndexedList.new(items: %w[a b c])

    assert_renders_successfully(list)
    assert_produces_output(list)
  end

  test "renders successfully without items" do
    list = Components::Boilermaker::IndexedList.new

    assert_renders_successfully(list)
  end

  test "renders row indices starting from 0" do
    list = Components::Boilermaker::IndexedList.new(items: %w[first second third])

    html = render_component(list)

    assert html.include?("0"), "Should include index 0"
    assert html.include?("1"), "Should include index 1"
    assert html.include?("2"), "Should include index 2"
  end

  test "renders row indices with custom start_index" do
    list = Components::Boilermaker::IndexedList.new(items: %w[a b c], start_index: 5)

    html = render_component(list)

    assert html.include?("5"), "Should include index 5"
    assert html.include?("6"), "Should include index 6"
    assert html.include?("7"), "Should include index 7"
  end

  test "applies text-sm styling" do
    list = Components::Boilermaker::IndexedList.new(items: %w[item])

    assert_has_css_class(list, "text-sm")
  end

  test "renders index in muted text-xs span" do
    list = Components::Boilermaker::IndexedList.new(items: %w[item])

    doc = render_and_parse(list)
    index_span = doc.css("span.text-muted.text-xs").first

    assert index_span, "Should have span with text-muted and text-xs classes"
    assert_equal "0", index_span.text.strip
  end

  test "renders dotted border between rows" do
    list = Components::Boilermaker::IndexedList.new(items: %w[a b])

    html = render_component(list)

    assert html.include?("border-dotted"), "Should have dotted border"
    assert html.include?("border-border-light"), "Should have border-border-light color"
  end

  test "renders with flex layout" do
    list = Components::Boilermaker::IndexedList.new(items: %w[item])

    doc = render_and_parse(list)
    row = doc.css("div.flex").first

    assert row, "Should have flex container"
  end

  test "yields block with item for each row" do
    items = [
      { name: "First", value: 100 },
      { name: "Second", value: 200 }
    ]

    html = render_component(
      Components::Boilermaker::IndexedList.new(items: items)
    ) { |item| item[:name] }

    assert html.include?("First"), "Should render first item name"
    assert html.include?("Second"), "Should render second item name"
  end

  test "accepts custom attributes" do
    list = Components::Boilermaker::IndexedList.new(
      items: %w[item],
      id: "alerts-list",
      "data-testid": "indexed-list"
    )

    assert_has_attributes(list, "div", {
      id: "alerts-list",
      "data-testid" => "indexed-list"
    })
  end

  test "renders with hover-glow class" do
    list = Components::Boilermaker::IndexedList.new(items: %w[item])

    html = render_component(list)

    assert html.include?("hover-glow"), "Should have hover-glow class"
  end

  test "renders empty when no items and no block" do
    list = Components::Boilermaker::IndexedList.new(items: [])

    html = render_component(list)

    # Should just have the wrapper div with no row divs inside
    doc = Nokogiri::HTML.fragment(html)
    assert_equal 1, doc.css("div").count, "Should only have wrapper div"
  end

  test "yields block content when no items but block given" do
    html = render_component(Components::Boilermaker::IndexedList.new) { "Custom empty state" }

    assert html.include?("Custom empty state"), "Should render block content when empty"
  end

  test "index column has fixed width" do
    list = Components::Boilermaker::IndexedList.new(items: %w[item])

    html = render_component(list)

    assert html.include?("w-6"), "Index span should have w-6 width"
    assert html.include?("flex-shrink-0"), "Index span should not shrink"
  end

  test "content area is flexible" do
    list = Components::Boilermaker::IndexedList.new(items: %w[item])

    html = render_component(list)

    assert html.include?("flex-1"), "Content area should be flex-1"
  end
end
