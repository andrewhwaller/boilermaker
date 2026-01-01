# frozen_string_literal: true

require_relative "component_test_case"
require_relative "test_helpers"

class KbdHintTest < ComponentTestCase
  include ComponentTestHelpers

  test "renders successfully" do
    hint = Components::Boilermaker::KbdHint.new(key: "Ctrl+C")

    assert_renders_successfully(hint)
    assert_produces_output(hint)
  end

  test "renders kbd element" do
    hint = Components::Boilermaker::KbdHint.new(key: "Enter")

    assert_has_tag(hint, "kbd")
  end

  test "renders key text" do
    hint = Components::Boilermaker::KbdHint.new(key: "Esc")

    assert_has_text(hint, "Esc")
  end

  test "applies font-mono styling" do
    hint = Components::Boilermaker::KbdHint.new(key: "Tab")

    assert_has_css_class(hint, "font-mono")
  end

  test "applies small text size" do
    hint = Components::Boilermaker::KbdHint.new(key: "Tab")

    html = render_component(hint)
    assert html.include?("text-[10px]"), "Should have text-[10px] class"
  end

  test "applies background styling" do
    hint = Components::Boilermaker::KbdHint.new(key: "Tab")

    assert_has_css_class(hint, "bg-surface-alt")
  end

  test "applies border styling" do
    hint = Components::Boilermaker::KbdHint.new(key: "Tab")

    assert_has_css_class(hint, "border")
    assert_has_css_class(hint, "border-border-default")
  end

  test "applies rounded and padding" do
    hint = Components::Boilermaker::KbdHint.new(key: "Tab")

    assert_has_css_class(hint, "rounded")
    assert_has_css_class(hint, "px-1")
  end

  test "accepts custom attributes" do
    hint = Components::Boilermaker::KbdHint.new(
      key: "F1",
      id: "help-key",
      "data-testid": "kbd"
    )

    assert_has_attributes(hint, "kbd", {
      id: "help-key",
      "data-testid" => "kbd"
    })
  end

  test "renders single key" do
    hint = Components::Boilermaker::KbdHint.new(key: "K")

    doc = render_and_parse(hint)
    kbd = doc.css("kbd").first

    assert_equal "K", kbd.text.strip
  end

  test "renders key combination" do
    hint = Components::Boilermaker::KbdHint.new(key: "Ctrl+Shift+P")

    doc = render_and_parse(hint)
    kbd = doc.css("kbd").first

    assert_equal "Ctrl+Shift+P", kbd.text.strip
  end
end
