# frozen_string_literal: true

require_relative "../component_test_case"
require_relative "../test_helpers"

class Components::Dos::FnBarTest < ComponentTestCase
  include ComponentTestHelpers

  test "renders fn bar with function key buttons" do
    component = Components::Dos::FnBar.new
    output = render_component(component)

    assert_includes output, "data-controller=\"fn-bar\""
    assert_includes output, "fixed bottom-0"
  end

  test "renders all function keys" do
    component = Components::Dos::FnBar.new
    output = render_component(component)

    assert_includes output, "F1"
    assert_includes output, "Help"
    assert_includes output, "F2"
    assert_includes output, "New"
    assert_includes output, "F3"
    assert_includes output, "Edit"
    assert_includes output, "F5"
    assert_includes output, "Refresh"
    assert_includes output, "F10"
    assert_includes output, "Quit"
  end

  test "has correct stimulus actions" do
    component = Components::Dos::FnBar.new
    output = render_component(component)

    assert_includes output, "keydown@window->fn-bar#handleKeydown"
    assert_includes output, "click->fn-bar#execute"
  end

  test "buttons have correct action params" do
    component = Components::Dos::FnBar.new
    output = render_component(component)

    assert_includes output, "data-fn-bar-action-param=\"help\""
    assert_includes output, "data-fn-bar-action-param=\"new\""
    assert_includes output, "data-fn-bar-action-param=\"edit\""
    assert_includes output, "data-fn-bar-action-param=\"refresh\""
    assert_includes output, "data-fn-bar-action-param=\"logout\""
  end
end
