# frozen_string_literal: true

require_relative "component_test_case"
require_relative "test_helpers"

class ToastTest < ComponentTestCase
  include ComponentTestHelpers

  # Basic rendering tests
  test "renders successfully with message" do
    toast = Components::Toast.new(message: "Test toast")
    assert_renders_successfully(toast)
  end

  test "returns empty when message is blank" do
    toast = Components::Toast.new(message: nil)
    html = render_component(toast)
    assert html.blank?

    toast = Components::Toast.new(message: "")
    html = render_component(toast)
    assert html.blank?
  end

  test "has correct base CSS classes" do
    toast = Components::Toast.new(message: "Test")
    assert_has_css_class(toast, ["toast", "alert"])
  end

  test "renders all variants correctly" do
    Components::Toast::VARIANTS.each do |variant, css_class|
      toast = Components::Toast.new(message: "Test", variant: variant)
      assert_has_css_class(toast, css_class)
    end
  end

  test "renders all positions correctly" do
    Components::Toast::POSITIONS.each do |position, css_classes|
      css_classes.split(" ").each do |css_class|
        toast = Components::Toast.new(message: "Test", position: position)
        assert_has_css_class(toast, css_class)
      end
    end
  end

  test "shows icons when enabled" do
    toast = Components::Toast.new(message: "Success", variant: :success, icon: true)
    html = render_component(toast)
    assert html.include?("✓")
  end

  test "hides icons when disabled" do
    toast = Components::Toast.new(message: "Success", variant: :success, icon: false)
    html = render_component(toast)
    refute html.include?("✓")
  end

  test "always renders dismiss button" do
    toast = Components::Toast.new(message: "Test")
    html = render_component(toast)
    assert html.include?("<button")
    assert html.include?('data-dismiss="toast"')
  end

  test "includes auto-dismiss attributes when duration set" do
    toast = Components::Toast.new(message: "Test", duration: 3000)
    html = render_component(toast)
    assert html.include?('data-controller="toast"')
    assert html.include?('data-toast-duration-value="3000"')
  end

  test "does not include auto-dismiss attributes when duration is 0" do
    toast = Components::Toast.new(message: "Test", duration: 0)
    html = render_component(toast)
    refute html.include?('data-controller="toast"')
  end

  test "has proper ARIA attributes for errors" do
    toast = Components::Toast.new(message: "Error", variant: :error)
    html = render_component(toast)
    assert html.include?('role="alert"')
    assert html.include?('aria-live="assertive"')
    assert html.include?('aria-atomic="true"')
  end

  test "has proper ARIA attributes for non-errors" do
    toast = Components::Toast.new(message: "Info", variant: :info)
    html = render_component(toast)
    assert html.include?('role="status"')
    assert html.include?('aria-live="polite"')
    assert html.include?('aria-atomic="true"')
  end

  test "includes custom attributes" do
    toast = Components::Toast.new(message: "Test", id: "custom-toast")
    html = render_component(toast)
    assert html.include?('id="custom-toast"')
  end

  test "escapes HTML content by default" do
    toast = Components::Toast.new(message: "<script>alert('xss')</script>")
    html = render_component(toast)
    assert html.include?("&lt;script&gt;")
    refute html.include?("<script>")
  end

  test "handles invalid position gracefully" do
    toast = Components::Toast.new(message: "Test", position: "invalid")
    html = render_component(toast)
    # Should fallback to default position
    assert html.include?("toast-top")
    assert html.include?("toast-end")
  end
end