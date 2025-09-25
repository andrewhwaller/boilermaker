# frozen_string_literal: true

require_relative "component_test_case"
require_relative "test_helpers"

class AlertTest < ComponentTestCase
  include ComponentTestHelpers

  # Basic rendering tests
  test "renders successfully with message" do
    alert = Components::Alert.new(message: "Test message")
    assert_renders_successfully(alert)
  end

  test "returns empty when message is blank" do
    alert = Components::Alert.new(message: nil)
    html = render_component(alert)
    assert html.blank?

    alert = Components::Alert.new(message: "")
    html = render_component(alert)
    assert html.blank?
  end

  test "has correct base CSS classes" do
    alert = Components::Alert.new(message: "Test")
    assert_has_css_class(alert, "alert")
  end

  test "renders all variants correctly" do
    Components::Alert::VARIANTS.each do |variant, css_class|
      alert = Components::Alert.new(message: "Test", variant: variant)
      assert_has_css_class(alert, css_class)
    end
  end

  test "renders dismiss button when dismissible" do
    alert = Components::Alert.new(message: "Test", dismissible: true)
    html = render_component(alert)
    assert html.include?("<button")
    assert html.include?('data-dismiss="alert"')
  end

  test "does not render dismiss button when not dismissible" do
    alert = Components::Alert.new(message: "Test", dismissible: false)
    html = render_component(alert)
    refute html.include?("<button")
  end

  test "has proper ARIA attributes for errors" do
    alert = Components::Alert.new(message: "Error", variant: :error)
    html = render_component(alert)
    assert html.include?('role="alert"')
    assert html.include?('aria-live="assertive"')
  end

  test "has proper ARIA attributes for non-errors" do
    alert = Components::Alert.new(message: "Info", variant: :info)
    html = render_component(alert)
    assert html.include?('role="status"')
    assert html.include?('aria-live="polite"')
  end

  test "includes custom attributes" do
    alert = Components::Alert.new(message: "Test", id: "custom-alert")
    html = render_component(alert)
    assert html.include?('id="custom-alert"')
  end

  test "escapes HTML content by default" do
    alert = Components::Alert.new(message: "<script>alert('xss')</script>")
    html = render_component(alert)
    assert html.include?("&lt;script&gt;")
    refute html.include?("<script>")
  end
end
