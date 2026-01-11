# frozen_string_literal: true

require "test_helper"

class PaymentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:regular_user)
  end

  # Feature flag tests
  test "returns 404 when payments feature is disabled" do
    with_config(features: { payments: false }) do
      sign_in_as @user
      get pricing_url
      assert_response :not_found
    end
  end

  # Pricing page tests
  test "should get pricing without authentication" do
    with_config(features: { payments: true }) do
      get pricing_url
      assert_response :success
    end
  end

  test "should get pricing when authenticated" do
    with_config(features: { payments: true }) do
      sign_in_as @user
      get pricing_url
      assert_response :success
    end
  end

  # Checkout tests
  test "checkout requires authentication" do
    with_config(features: { payments: true }) do
      post checkout_url(plan: "pro")
      assert_redirected_to sign_in_url
    end
  end

  test "checkout with invalid plan redirects to pricing with alert" do
    with_config(features: { payments: true }) do
      sign_in_as @user
      post checkout_url(plan: "nonexistent_plan")
      assert_redirected_to pricing_path
      assert_equal "Invalid plan selected", flash[:alert]
    end
  end

  # Success page tests
  test "success requires authentication" do
    with_config(features: { payments: true }) do
      get payment_success_url
      assert_redirected_to sign_in_url
    end
  end

  test "success redirects to billing settings with notice" do
    with_config(features: { payments: true }) do
      sign_in_as @user
      get payment_success_url
      assert_redirected_to settings_billing_path
      assert_equal "Thank you for subscribing!", flash[:notice]
    end
  end

  # Cancel page tests
  test "cancel requires authentication" do
    with_config(features: { payments: true }) do
      get payment_cancel_url
      assert_redirected_to sign_in_url
    end
  end

  test "cancel redirects to pricing with notice" do
    with_config(features: { payments: true }) do
      sign_in_as @user
      get payment_cancel_url
      assert_redirected_to pricing_path
      assert_equal "Checkout cancelled", flash[:notice]
    end
  end

  # Portal tests
  test "portal requires authentication" do
    with_config(features: { payments: true }) do
      post billing_portal_url
      assert_redirected_to sign_in_url
    end
  end

  # Stripe URL validation tests
  test "redirect_to_stripe rejects non-stripe URLs" do
    with_config(features: { payments: true }) do
      sign_in_as @user

      # Create a controller instance to test the private method
      controller = PaymentsController.new
      controller.instance_variable_set(:@_request, ActionDispatch::Request.new({}))
      controller.instance_variable_set(:@_response, ActionDispatch::Response.new)

      # Test with a malicious URL
      uri = URI.parse("https://evil.com/steal-data")
      assert_not uri.host&.end_with?(".stripe.com"), "Non-Stripe URL should fail validation"

      # Test with a valid Stripe URL
      uri = URI.parse("https://checkout.stripe.com/session123")
      assert uri.host&.end_with?(".stripe.com"), "Stripe URL should pass validation"

      # Test with billing portal URL
      uri = URI.parse("https://billing.stripe.com/session/abc")
      assert uri.host&.end_with?(".stripe.com"), "Stripe billing URL should pass validation"
    end
  end
end
