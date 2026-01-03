# frozen_string_literal: true

require_relative "../component_test_case"
require_relative "../test_helpers"

class Components::Brutalist::KeyboardHintTest < ComponentTestCase
  include ComponentTestHelpers

  test "renders keyboard hint with single key" do
    component = Components::Brutalist::KeyboardHint.new(keys: "K", action: "search")
    output = render_component(component)

    assert_includes output, "data-controller=\"keyboard-hint\""
    assert_includes output, "K"
    assert_includes output, "search"
  end

  test "renders keyboard hint with multiple keys" do
    component = Components::Brutalist::KeyboardHint.new(keys: %w[cmd K], action: "search")
    output = render_component(component)

    assert_includes output, "data-keyboard-hint-keys-value=\"cmd+K\""
    assert_includes output, "+"
  end

  test "formats special keys correctly" do
    component = Components::Brutalist::KeyboardHint.new(keys: "cmd", action: "test")
    output = render_component(component)
    # Should render the Mac command symbol
    assert_includes output, "kbd"
  end

  test "hides action when inline is false" do
    component = Components::Brutalist::KeyboardHint.new(keys: "K", action: "search", inline: false)
    output = render_component(component)

    # Action should not be shown in non-inline mode
    refute_includes output, "<span class=\"text-muted ml-1\">search</span>"
  end

  test "sets correct stimulus values" do
    component = Components::Brutalist::KeyboardHint.new(keys: %w[ctrl S], action: "save")
    output = render_component(component)

    assert_includes output, "data-keyboard-hint-keys-value=\"ctrl+S\""
    assert_includes output, "data-keyboard-hint-action-value=\"save\""
  end
end
