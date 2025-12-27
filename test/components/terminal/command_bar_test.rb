# frozen_string_literal: true

require_relative "../component_test_case"
require_relative "../test_helpers"

class Components::Terminal::CommandBarTest < ComponentTestCase
  include ComponentTestHelpers

  test "renders command bar with default placeholder" do
    component = Components::Terminal::CommandBar.new
    output = render_component(component)

    assert_includes output, "data-controller=\"command-bar\""
    assert_includes output, "placeholder=\"Type / to search or : for commands...\""
    assert_includes output, "fixed bottom-0"
  end

  test "renders command bar with custom placeholder" do
    component = Components::Terminal::CommandBar.new(placeholder: "Custom placeholder")
    output = render_component(component)

    assert_includes output, "placeholder=\"Custom placeholder\""
  end

  test "renders prompt indicator" do
    component = Components::Terminal::CommandBar.new
    output = render_component(component)

    assert_includes output, "data-command-bar-target=\"prompt\""
    assert_includes output, ">"
  end

  test "renders status indicator with keyboard hints" do
    component = Components::Terminal::CommandBar.new
    output = render_component(component)

    assert_includes output, "data-command-bar-target=\"status\""
    assert_includes output, "search"
    assert_includes output, "cmd"
  end

  test "has correct stimulus actions" do
    component = Components::Terminal::CommandBar.new
    output = render_component(component)

    assert_includes output, "keydown@window->command-bar#handleGlobalKeydown"
    assert_includes output, "keydown->command-bar#handleKeydown"
    assert_includes output, "input->command-bar#handleInput"
  end
end
