# frozen_string_literal: true

require_relative "component_test_case"

class ThemeToggleTest < ComponentTestCase
  test "travel_for_position returns correct distances" do
    toggle = Components::ThemeToggle.new(position: :navbar)
    assert_equal 28, toggle.send(:travel_for_position)

    toggle = Components::ThemeToggle.new(position: :sidebar)
    assert_equal 60, toggle.send(:travel_for_position)

    toggle = Components::ThemeToggle.new(position: :mobile)
    assert_equal 50, toggle.send(:travel_for_position)

    toggle = Components::ThemeToggle.new(position: :inline)
    assert_equal 68, toggle.send(:travel_for_position)
  end

  test "initial_is_dark? detects dark theme correctly" do
    toggle = Components::ThemeToggle.new(light_theme: "light", dark_theme: "dark")

    Current.theme_name = "dark"
    assert toggle.send(:initial_is_dark?)

    Current.theme_name = "light"
    refute toggle.send(:initial_is_dark?)

    Current.theme_name = nil
    refute toggle.send(:initial_is_dark?)
  ensure
    Current.theme_name = nil
  end

  test "initial_toggle_class returns correct CSS class" do
    toggle = Components::ThemeToggle.new(light_theme: "light", dark_theme: "dark")

    Current.theme_name = "dark"
    assert_equal "theme-toggle-dark", toggle.send(:initial_toggle_class)

    Current.theme_name = "light"
    assert_equal "", toggle.send(:initial_toggle_class)
  ensure
    Current.theme_name = nil
  end
end
