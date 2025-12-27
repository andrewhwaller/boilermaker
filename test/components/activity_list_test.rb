# frozen_string_literal: true

require_relative "component_test_case"
require_relative "test_helpers"

class ActivityListTest < ComponentTestCase
  include ComponentTestHelpers

  test "renders successfully" do
    list = Components::ActivityList.new

    assert_renders_successfully(list)
    assert_produces_output(list)
  end

  test "renders items from array" do
    items = [
      { time: "2 min ago", content: "First activity" },
      { time: "1 hr ago", content: "Second activity" }
    ]
    list = Components::ActivityList.new(items: items)

    assert_has_text(list, "2 min ago")
    assert_has_text(list, "First activity")
    assert_has_text(list, "1 hr ago")
    assert_has_text(list, "Second activity")
  end

  test "renders items from block" do
    list = Components::ActivityList.new

    html = render_component(list) do
      render Components::ActivityList::Item.new(time: "now") { "Block content" }
    end

    assert html.include?("now"), "Should render time"
    assert html.include?("Block content"), "Should render block content"
  end

  test "applies text styling" do
    list = Components::ActivityList.new

    assert_has_css_class(list, "text-xs")
  end

  test "accepts custom attributes" do
    list = Components::ActivityList.new(
      id: "activity-feed",
      "data-testid": "activities"
    )

    assert_has_attributes(list, "div", {
      id: "activity-feed",
      "data-testid": "activities"
    })
  end
end

class ActivityListItemTest < ComponentTestCase
  include ComponentTestHelpers

  test "renders time and content" do
    item = Components::ActivityList::Item.new(time: "2 min ago") { "Activity happened" }

    assert_has_text(item, "2 min ago")
    assert_has_text(item, "Activity happened")
  end

  test "applies flex layout" do
    item = Components::ActivityList::Item.new(time: "now") { "Test" }

    assert_has_css_class(item, "flex")
    assert_has_css_class(item, "gap-3")
  end

  test "applies border styling" do
    item = Components::ActivityList::Item.new(time: "now") { "Test" }

    assert_has_css_class(item, "border-b")
    assert_has_css_class(item, "border-border-light")
  end

  test "applies muted styling to time" do
    item = Components::ActivityList::Item.new(time: "yesterday") { "Event" }

    doc = render_and_parse(item)
    time_span = doc.css("span").first

    assert_includes time_span["class"], "text-muted"
    assert_equal "yesterday", time_span.text
  end

  test "applies body styling to content" do
    item = Components::ActivityList::Item.new(time: "now") { "Content text" }

    doc = render_and_parse(item)
    content_span = doc.css("span.text-body").first

    assert content_span, "Should have content span with text-body class"
  end

  test "renders html content in block" do
    item = Components::ActivityList::Item.new(time: "now") { "Simple content" }

    html = render_component(item)

    assert html.include?("Simple content"), "Should render block content"
  end

  test "accepts custom attributes" do
    item = Components::ActivityList::Item.new(
      time: "now",
      id: "activity-1",
      "data-testid": "activity"
    ) { "Test" }

    assert_has_attributes(item, "div", {
      id: "activity-1",
      "data-testid": "activity"
    })
  end

  test "time cell has fixed min-width" do
    item = Components::ActivityList::Item.new(time: "now") { "Test" }

    doc = render_and_parse(item)
    time_span = doc.css("span").first

    assert_includes time_span["class"], "min-w-[70px]"
  end
end
