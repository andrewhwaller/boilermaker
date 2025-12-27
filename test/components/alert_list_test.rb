# frozen_string_literal: true

require_relative "component_test_case"
require_relative "test_helpers"

class AlertListTest < ComponentTestCase
  include ComponentTestHelpers

  test "renders successfully" do
    list = Components::AlertList.new

    assert_renders_successfully(list)
    assert_produces_output(list)
  end

  test "renders items from array" do
    items = [
      { name: "ML Alert", href: "/alerts/1", count: 23, status: :active, updated: "2 min ago", has_new: true },
      { name: "Battery Tech", href: "/alerts/2", count: 8, status: :active, updated: "1 hr ago", has_new: true }
    ]
    list = Components::AlertList.new(items: items)

    assert_has_text(list, "ML Alert")
    assert_has_text(list, "Battery Tech")
    assert_has_text(list, "23 new")
    assert_has_text(list, "8 new")
  end

  test "renders items from block" do
    list = Components::AlertList.new

    html = render_component(list) do
      render Components::AlertList::Item.new(
        name: "Custom Alert",
        href: "/custom",
        count: 5,
        status: :active,
        updated: "now",
        has_new: true
      )
    end

    assert html.include?("Custom Alert"), "Should render block content"
  end

  test "applies border styling" do
    list = Components::AlertList.new

    assert_has_css_class(list, "border")
    assert_has_css_class(list, "border-border-default")
  end

  test "accepts custom attributes" do
    list = Components::AlertList.new(
      id: "alert-list",
      "data-testid": "alerts"
    )

    assert_has_attributes(list, "div", {
      id: "alert-list",
      "data-testid": "alerts"
    })
  end
end

class AlertListItemTest < ComponentTestCase
  include ComponentTestHelpers

  test "renders all cells" do
    item = Components::AlertList::Item.new(
      name: "Machine Learning",
      href: "/alerts/ml",
      count: 23,
      status: :active,
      updated: "2 min ago",
      has_new: true
    )

    assert_has_text(item, "Machine Learning")
    assert_has_text(item, "23 new")
    assert_has_text(item, "Active")
    assert_has_text(item, "2 min ago")
  end

  test "renders name as link" do
    item = Components::AlertList::Item.new(
      name: "Test Alert",
      href: "/test",
      count: 0,
      status: :active,
      updated: "now"
    )

    doc = render_and_parse(item)
    link = doc.css("a").first

    assert link, "Should have link"
    assert_equal "/test", link["href"]
    assert_equal "Test Alert", link.text
  end

  test "applies highlight styling when has_new is true" do
    item = Components::AlertList::Item.new(
      name: "Alert",
      href: "/",
      count: 10,
      status: :active,
      updated: "now",
      has_new: true
    )

    html = render_component(item)

    # The count cell should have accent styling when has_new is true
    assert html.include?("text-accent"), "Count cell should have text-accent class"
    assert html.include?("font-semibold"), "Count cell should have font-semibold class"
  end

  test "applies muted styling when has_new is false" do
    item = Components::AlertList::Item.new(
      name: "Alert",
      href: "/",
      count: 0,
      status: :active,
      updated: "now",
      has_new: false
    )

    html = render_component(item)

    # Check that the count cell div has muted class (not accent)
    refute html.include?("text-accent font-semibold"), "Count cell should not have highlight styling"
  end

  test "renders active status with accent-alt dot" do
    item = Components::AlertList::Item.new(
      name: "Alert",
      href: "/",
      count: 0,
      status: :active,
      updated: "now"
    )

    doc = render_and_parse(item)
    dot = doc.css("span.rounded-full").first

    assert_includes dot["class"], "bg-accent-alt"
  end

  test "renders paused status with muted dot" do
    item = Components::AlertList::Item.new(
      name: "Alert",
      href: "/",
      count: 0,
      status: :paused,
      updated: "now"
    )

    doc = render_and_parse(item)
    dot = doc.css("span.rounded-full").first

    assert_includes dot["class"], "bg-muted"
    assert_has_text(item, "Paused")
  end

  test "uses grid layout" do
    item = Components::AlertList::Item.new(
      name: "Alert",
      href: "/",
      count: 0,
      status: :active,
      updated: "now"
    )

    assert_has_css_class(item, "grid")
  end

  test "applies hover styling" do
    item = Components::AlertList::Item.new(
      name: "Alert",
      href: "/",
      count: 0,
      status: :active,
      updated: "now"
    )

    html = render_component(item)
    assert html.include?("hover:bg-surface-alt"), "Should have hover styling"
  end
end
