# frozen_string_literal: true

require_relative "component_test_case"

class ThemeToggleTest < ComponentTestCase
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

  test "current_polarity_label returns correct text" do
    toggle = Components::ThemeToggle.new(light_theme: "light", dark_theme: "dark")

    Current.theme_name = "dark"
    assert_equal "NEGATIVE", toggle.send(:current_polarity_label)

    Current.theme_name = "light"
    assert_equal "POSITIVE", toggle.send(:current_polarity_label)
  ensure
    Current.theme_name = nil
  end
end
