# frozen_string_literal: true

require "test_helper"

class AlertHelperTest < ActionView::TestCase
  include AlertHelper

  # Test render_flash_alerts with various flash messages
  test "render_flash_alerts converts flash messages to Alert components" do
    # Set up flash messages
    flash[:notice] = "Operation successful"
    flash[:alert] = "Something went wrong"
    flash[:warning] = "Be careful"
    flash[:info] = "For your information"
    flash[:success] = "Great job"
    flash[:error] = "Critical error"

    alerts = render_flash_alerts

    # Should return array of Alert components
    assert_equal 6, alerts.length
    assert alerts.all? { |alert| alert.is_a?(Components::Alert) }

    # Check variant mappings
    notice_alert = alerts.find { |a| a.instance_variable_get(:@message) == "Operation successful" }
    assert_equal :success, notice_alert.instance_variable_get(:@variant)

    alert_flash = alerts.find { |a| a.instance_variable_get(:@message) == "Something went wrong" }
    assert_equal :error, alert_flash.instance_variable_get(:@variant)

    warning_alert = alerts.find { |a| a.instance_variable_get(:@message) == "Be careful" }
    assert_equal :warning, warning_alert.instance_variable_get(:@variant)

    info_alert = alerts.find { |a| a.instance_variable_get(:@message) == "For your information" }
    assert_equal :info, info_alert.instance_variable_get(:@variant)

    success_alert = alerts.find { |a| a.instance_variable_get(:@message) == "Great job" }
    assert_equal :success, success_alert.instance_variable_get(:@variant)

    error_alert = alerts.find { |a| a.instance_variable_get(:@message) == "Critical error" }
    assert_equal :error, error_alert.instance_variable_get(:@variant)

    # All alerts should be dismissible
    assert alerts.all? { |alert| alert.instance_variable_get(:@dismissible) }
  end

  test "render_flash_alerts filters out blank messages" do
    flash[:notice] = "Valid message"
    flash[:alert] = ""
    flash[:warning] = nil
    flash[:info] = "   "

    alerts = render_flash_alerts

    # Should only return alert for valid message
    assert_equal 1, alerts.length
    assert_equal "Valid message", alerts.first.instance_variable_get(:@message)
  end

  test "render_flash_alerts handles unknown flash types" do
    flash[:unknown_type] = "Unknown message"

    alerts = render_flash_alerts

    # Should default to info variant
    assert_equal 1, alerts.length
    assert_equal :info, alerts.first.instance_variable_get(:@variant)
    assert_equal "Unknown message", alerts.first.instance_variable_get(:@message)
  end

  test "render_flash_alerts returns empty array when no flash messages" do
    alerts = render_flash_alerts
    assert_equal 0, alerts.length
  end

  # Test flash_toast helper
  test "flash_toast creates Toast component with correct parameters" do
    toast = flash_toast("Test toast message", variant: :success, position: "bottom-center", duration: 3000)

    assert_instance_of Components::Toast, toast
    assert_equal "Test toast message", toast.instance_variable_get(:@message)
    assert_equal :success, toast.instance_variable_get(:@variant)
    assert_equal "bottom-center", toast.instance_variable_get(:@position)
    assert_equal 3000, toast.instance_variable_get(:@duration)
  end

  test "flash_toast uses default parameters" do
    toast = flash_toast("Default toast")

    assert_equal :info, toast.instance_variable_get(:@variant)
    assert_equal "top-end", toast.instance_variable_get(:@position)
    assert_equal 5000, toast.instance_variable_get(:@duration)
  end

  test "flash_toast passes through additional options" do
    toast = flash_toast("Custom toast", icon: false, id: "custom-id")

    assert_equal false, toast.instance_variable_get(:@show_icon)
    assert_equal({ id: "custom-id" }, toast.instance_variable_get(:@attributes))
  end

  # Test flash_alert helper
  test "flash_alert creates Alert component with correct parameters" do
    alert = flash_alert("Test alert message", variant: :error, dismissible: false)

    assert_instance_of Components::Alert, alert
    assert_equal "Test alert message", alert.instance_variable_get(:@message)
    assert_equal :error, alert.instance_variable_get(:@variant)
    assert_equal false, alert.instance_variable_get(:@dismissible)
  end

  test "flash_alert uses default parameters" do
    alert = flash_alert("Default alert")

    assert_equal :info, alert.instance_variable_get(:@variant)
    assert_equal true, alert.instance_variable_get(:@dismissible)
  end

  test "flash_alert passes through additional options" do
    alert = flash_alert("Custom alert", icon: false, class: "custom-class")

    assert_equal false, alert.instance_variable_get(:@show_icon)
    assert_equal({ class: "custom-class" }, alert.instance_variable_get(:@attributes))
  end

  # Test flash_type_to_variant helper
  test "flash_type_to_variant maps flash types correctly" do
    assert_equal :success, flash_type_to_variant("notice")
    assert_equal :success, flash_type_to_variant(:notice)
    assert_equal :error, flash_type_to_variant("alert")
    assert_equal :error, flash_type_to_variant(:alert)
    assert_equal :success, flash_type_to_variant("success")
    assert_equal :error, flash_type_to_variant("error")
    assert_equal :warning, flash_type_to_variant("warning")
    assert_equal :info, flash_type_to_variant("info")
  end

  test "flash_type_to_variant returns info for unknown types" do
    assert_equal :info, flash_type_to_variant("unknown")
    assert_equal :info, flash_type_to_variant(:unknown)
    assert_equal :info, flash_type_to_variant(nil)
  end

  # Test flash_type_error? helper
  test "flash_type_error? identifies error flash types" do
    assert flash_type_error?("alert")
    assert flash_type_error?(:alert)
    assert flash_type_error?("error")
    assert flash_type_error?(:error)

    refute flash_type_error?("notice")
    refute flash_type_error?("success")
    refute flash_type_error?("warning")
    refute flash_type_error?("info")
    refute flash_type_error?(nil)
  end

  # Test flash_type_success? helper
  test "flash_type_success? identifies success flash types" do
    assert flash_type_success?("notice")
    assert flash_type_success?(:notice)
    assert flash_type_success?("success")
    assert flash_type_success?(:success)

    refute flash_type_success?("alert")
    refute flash_type_success?("error")
    refute flash_type_success?("warning")
    refute flash_type_success?("info")
    refute flash_type_success?(nil)
  end

  # Test constant mapping coverage
  test "FLASH_TO_VARIANT constant has expected mappings" do
    expected_mappings = {
      'notice' => :success,
      'alert' => :error,
      'success' => :success,
      'error' => :error,
      'warning' => :warning,
      'info' => :info
    }

    assert_equal expected_mappings, AlertHelper::FLASH_TO_VARIANT
  end

  # Test edge cases
  test "handles edge cases gracefully" do
    # Empty flash
    flash.clear
    alerts = render_flash_alerts
    assert_equal 0, alerts.length

    # Flash with empty string keys
    flash[""] = "Empty key message"
    alerts = render_flash_alerts
    assert_equal 1, alerts.length
    assert_equal :info, alerts.first.instance_variable_get(:@variant)

    # Flash with numeric keys (converted to string)
    flash[123] = "Numeric key message"
    alerts = render_flash_alerts
    assert_equal 2, alerts.length
  end

  # Test integration scenarios
  test "typical Rails controller flash usage" do
    # Simulate typical controller flash usage
    flash[:notice] = "User was successfully created."
    flash[:alert] = "Email has already been taken."

    alerts = render_flash_alerts

    assert_equal 2, alerts.length

    success_alert = alerts.find { |a| a.instance_variable_get(:@variant) == :success }
    error_alert = alerts.find { |a| a.instance_variable_get(:@variant) == :error }

    assert success_alert
    assert error_alert
    assert_equal "User was successfully created.", success_alert.instance_variable_get(:@message)
    assert_equal "Email has already been taken.", error_alert.instance_variable_get(:@message)

    # Both should be dismissible for better UX
    assert success_alert.instance_variable_get(:@dismissible)
    assert error_alert.instance_variable_get(:@dismissible)
  end
end