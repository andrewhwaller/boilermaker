# frozen_string_literal: true

require_relative "component_test_case"
require_relative "test_helpers"

class FkeyBarTest < ComponentTestCase
  include ComponentTestHelpers

  def sample_actions
    {
      f1: "Help",
      f2: "Save",
      f5: "Refresh",
      f10: "Quit"
    }
  end

  test "renders successfully" do
    bar = Components::FkeyBar.new

    assert_renders_successfully(bar)
    assert_produces_output(bar)
  end

  test "renders all 10 function keys" do
    bar = Components::FkeyBar.new

    %w[F1 F2 F3 F4 F5 F6 F7 F8 F9 F10].each do |key|
      assert_has_text(bar, key)
    end
  end

  test "renders action labels for defined keys" do
    bar = Components::FkeyBar.new(actions: sample_actions)

    assert_has_text(bar, "Help")
    assert_has_text(bar, "Save")
    assert_has_text(bar, "Refresh")
    assert_has_text(bar, "Quit")
  end

  test "applies flex layout" do
    bar = Components::FkeyBar.new

    assert_has_css_class(bar, "flex")
  end

  test "applies accent border top" do
    bar = Components::FkeyBar.new

    assert_has_css_class(bar, "border-t-2")
    assert_has_css_class(bar, "border-accent")
  end

  test "applies top padding" do
    bar = Components::FkeyBar.new

    assert_has_css_class(bar, "pt-2")
  end

  test "applies top margin" do
    bar = Components::FkeyBar.new

    assert_has_css_class(bar, "mt-4")
  end

  test "key labels have accent background" do
    bar = Components::FkeyBar.new

    doc = render_and_parse(bar)
    key_spans = doc.css("span.bg-accent")

    assert key_spans.count >= 10, "All key labels should have accent background"
  end

  test "key labels have surface text color" do
    bar = Components::FkeyBar.new

    doc = render_and_parse(bar)
    key_spans = doc.css("span.text-surface")

    assert key_spans.count >= 10
  end

  test "key labels have padding" do
    bar = Components::FkeyBar.new

    doc = render_and_parse(bar)
    key_span = doc.css("span.px-1").first

    assert key_span, "Key labels should have px-1"
  end

  test "key labels are bold" do
    bar = Components::FkeyBar.new

    doc = render_and_parse(bar)
    key_span = doc.css("span.font-bold").first

    assert key_span, "Key labels should be bold"
  end

  test "action labels have muted text color" do
    bar = Components::FkeyBar.new(actions: sample_actions)

    doc = render_and_parse(bar)
    action_spans = doc.css("span.text-muted")

    assert action_spans.count >= 10
  end

  test "action labels have left margin" do
    bar = Components::FkeyBar.new(actions: sample_actions)

    doc = render_and_parse(bar)
    action_spans = doc.css("span.ml-1")

    assert action_spans.count >= 10
  end

  test "key slots are flex-1 for equal distribution" do
    bar = Components::FkeyBar.new

    doc = render_and_parse(bar)
    key_slots = doc.css("div.flex-1")

    assert_equal 10, key_slots.count
  end

  test "key slots are centered" do
    bar = Components::FkeyBar.new

    doc = render_and_parse(bar)
    key_slots = doc.css("div.text-center")

    assert_equal 10, key_slots.count
  end

  test "key slots have text-xs styling" do
    bar = Components::FkeyBar.new

    doc = render_and_parse(bar)
    key_slots = doc.css("div.text-xs")

    assert_equal 10, key_slots.count
  end

  test "accepts string keys for actions" do
    bar = Components::FkeyBar.new(actions: { "F1" => "Help" })

    assert_has_text(bar, "Help")
  end

  test "accepts lowercase symbol keys" do
    bar = Components::FkeyBar.new(actions: { f1: "Help" })

    assert_has_text(bar, "Help")
  end

  test "accepts uppercase symbol keys" do
    bar = Components::FkeyBar.new(actions: { F1: "Help" })

    assert_has_text(bar, "Help")
  end

  test "undefined keys show empty action" do
    bar = Components::FkeyBar.new(actions: { f1: "Help" })

    doc = render_and_parse(bar)
    f2_slot = doc.css("div.flex-1")[1]
    action_span = f2_slot.css("span.text-muted").first

    assert_equal "", action_span.text.strip
  end

  test "accepts custom attributes" do
    bar = Components::FkeyBar.new(
      actions: sample_actions,
      id: "function-keys",
      "data-testid": "fkey-bar"
    )

    assert_has_attributes(bar, "div", {
      id: "function-keys",
      "data-testid" => "fkey-bar"
    })
  end
end
