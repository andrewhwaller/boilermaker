# frozen_string_literal: true

require "test_helper"

class Components::Kits::UIKitTest < ActiveSupport::TestCase
  test "provides access to all kits" do
    kits = Components::Kits::UIKit.kits

    assert_includes kits.keys, :form
    assert_includes kits.keys, :navigation
    assert_equal Components::Kits::FormKit, kits[:form]
    assert_equal Components::Kits::NavigationKit, kits[:navigation]
  end

  test "provides access to all components by category" do
    components = Components::Kits::UIKit.components

    assert_includes components.keys, :form
    assert_includes components.keys, :navigation
    assert_includes components.keys, :base

    # Check form components
    form_components = components[:form]
    assert_equal Components::Button, form_components[:button]
    assert_equal Components::Input, form_components[:input]
    assert_equal Components::Label, form_components[:label]
    assert_equal Components::FormField, form_components[:form_field]

    # Check navigation components
    nav_components = components[:navigation]
    assert_equal Components::Navigation, nav_components[:navigation]
    assert_equal Components::DropdownMenu, nav_components[:dropdown_menu]
  end

  test "provides quick access to specific kits" do
    assert_equal Components::Kits::FormKit, Components::Kits::UIKit.form
    assert_equal Components::Kits::NavigationKit, Components::Kits::UIKit.navigation
  end

  test "lists all available components" do
    component_list = Components::Kits::UIKit.list_components

    assert_includes component_list, "form.button"
    assert_includes component_list, "form.input"
    assert_includes component_list, "form.label"
    assert_includes component_list, "form.form_field"
    assert_includes component_list, "navigation.navigation"
    assert_includes component_list, "navigation.dropdown_menu"
    assert_includes component_list, "base.base"
  end
end
