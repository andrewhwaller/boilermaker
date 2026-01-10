# frozen_string_literal: true

require "test_helper"

module Settings
  class BillingsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = users(:regular_user)
    end

    # Feature flag tests
    test "returns 404 when payments feature is disabled" do
      with_config(features: { payments: false }) do
        sign_in_as @user
        get settings_billing_url
        assert_response :not_found
      end
    end

    # Authentication tests
    test "show requires authentication" do
      with_config(features: { payments: true }) do
        get settings_billing_url
        assert_redirected_to sign_in_url
      end
    end

    # Show tests
    test "should get show" do
      with_config(features: { payments: true }) do
        sign_in_as @user
        get settings_billing_url
        assert_response :success
      end
    end

    test "show displays billing information for user" do
      with_config(features: { payments: true }) do
        sign_in_as @user
        get settings_billing_url
        assert_response :success
      end
    end
  end
end
