# frozen_string_literal: true

require "test_helper"
require Rails.root.join("lib", "boilermaker")

class Boilermaker::ConfigTest < ActiveSupport::TestCase
  def setup
    @original_data = Boilermaker::Config.instance_variable_get(:@data)
    # Create a temporary config for testing
    @temp_config = {
      "app" => {
        "name" => "Test App",
        "version" => "2.0.0",
        "support_email" => "test@example.com"
      },
      "features" => {
        "multi_tenant" => true,
        "personal_accounts" => false,
        "two_factor_authentication" => true
      },
      "auth" => {
        "password" => {
          "min_length" => 8
        },
        "session" => {
          "timeout_minutes" => 60
        }
      },
      "ui" => {
        "brand" => {
          "primary_color" => "#ff0000",
          "secondary_color" => "#00ff00"
        },
        "typography" => {
          "font" => "Inter"
        }
      }
    }

    # Stub the data loading for tests
    Boilermaker::Config.instance_variable_set(:@data, @temp_config)
  end

  def teardown
    # Restore original config to avoid leaking into other tests in the process
    Boilermaker::Config.instance_variable_set(:@data, @original_data)
  end

  test "get method returns correct values" do
    assert_equal "Test App", Boilermaker::Config.get("app.name")
    assert_equal "2.0.0", Boilermaker::Config.get("app.version")
    assert_equal 8, Boilermaker::Config.get("auth.password.min_length")
    assert_nil Boilermaker::Config.get("nonexistent.key")
  end

  test "feature_enabled? returns correct boolean values" do
    assert Boilermaker::Config.feature_enabled?("multi_tenant")
    assert_not Boilermaker::Config.feature_enabled?("personal_accounts")
    assert Boilermaker::Config.feature_enabled?("two_factor_authentication")
    assert_not Boilermaker::Config.feature_enabled?("nonexistent_feature")
  end

  test "convenience methods return correct values" do
    assert_equal "Test App", Boilermaker::Config.app_name
    assert_equal "2.0.0", Boilermaker::Config.app_version
    assert_equal "test@example.com", Boilermaker::Config.support_email
    assert_equal 8, Boilermaker::Config.password_min_length
    assert_equal 60, Boilermaker::Config.session_timeout_minutes
    assert_equal "#ff0000", Boilermaker::Config.primary_color
    assert_equal "#00ff00", Boilermaker::Config.secondary_color
  end

  test "font_name returns configured font" do
    assert_equal "Inter", Boilermaker::Config.font_name
  end

  test "font_name returns default when not configured" do
    # Remove font config
    @temp_config["ui"]["typography"] = {}
    Boilermaker::Config.instance_variable_set(:@data, @temp_config)

    assert_equal "CommitMono", Boilermaker::Config.font_name
  end

  test "multi_tenant? and personal_accounts? return correct values" do
    assert Boilermaker::Config.multi_tenant?
    assert_not Boilermaker::Config.personal_accounts?
  end

  test "method_missing provides access to config sections" do
    app_section = Boilermaker::Config.app
    assert_kind_of Boilermaker::Config::ConfigSection, app_section
    assert_equal "Test App", app_section.name
    assert_equal "2.0.0", app_section.version
  end

  test "ConfigSection provides dot notation access" do
    auth_section = Boilermaker::Config.auth
    assert_equal 8, auth_section.password.min_length
    assert_equal 60, auth_section.session.timeout_minutes
  end

  test "ConfigSection bracket access works" do
    ui_section = Boilermaker::Config.ui
    assert_equal "#ff0000", ui_section["brand"]["primary_color"]
    assert_equal "#00ff00", ui_section["brand"]["secondary_color"]
  end

  test "engine module provides convenience methods" do
    assert_equal Boilermaker::Config, Boilermaker.config
    assert Boilermaker.feature_enabled?("multi_tenant")
    assert_not Boilermaker.feature_enabled?("personal_accounts")
  end
end
