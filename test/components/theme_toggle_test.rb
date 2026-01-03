# frozen_string_literal: true

require_relative "component_test_case"

class ThemeToggleTest < ComponentTestCase
  test "initial_is_dark? detects dark polarity correctly" do
    toggle = Components::ThemeToggle.new

    Current.polarity = "dark"
    assert toggle.send(:initial_is_dark?)

    Current.polarity = "light"
    refute toggle.send(:initial_is_dark?)

    Current.polarity = nil
    refute toggle.send(:initial_is_dark?)
  ensure
    Current.polarity = nil
  end

  test "current_polarity_label returns correct text" do
    toggle = Components::ThemeToggle.new

    Current.polarity = "dark"
    assert_equal "DARK", toggle.send(:current_polarity_label)

    Current.polarity = "light"
    assert_equal "LIGHT", toggle.send(:current_polarity_label)
  ensure
    Current.polarity = nil
  end

  test "renders with default configuration" do
    toggle = Components::ThemeToggle.new
    output = render_component(toggle)

    assert_includes output, "data-controller=\"theme\""
    assert_includes output, "role=\"switch\""
  end

  test "renders with position configurations" do
    %i[inline navbar sidebar fixed].each do |position|
      toggle = Components::ThemeToggle.new(position: position)
      output = render_component(toggle)

      assert_includes output, "data-controller=\"theme\""
    end
  end

  test "renders with label hidden" do
    toggle = Components::ThemeToggle.new(show_label: false)
    output = render_component(toggle)

    refute_includes output, "Display Mode"
  end
end
