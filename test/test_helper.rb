ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/mock"
require "active_job/test_helper"

module ActiveSupport
  class TestCase
    include ActiveJob::TestHelper
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...

    # Temporarily override config for testing
    def with_config(**overrides)
      original_config = Boilermaker::Config.instance_variable_get(:@data)

      begin
        # Load the current config
        current_config = Boilermaker::Config.load_raw

        # Deep merge the overrides into the test environment
        test_config = current_config["test"] || {}
        merged_overrides = deep_merge_config(test_config, overrides.deep_stringify_keys)
        current_config["test"] = merged_overrides

        # Create a new configuration with the merged data
        defaults = current_config["default"] || {}
        env_data = current_config["test"] || {}
        new_data = defaults.merge(env_data)

        Boilermaker::Config.instance_variable_set(:@data, new_data.freeze)
        yield
      ensure
        Boilermaker::Config.instance_variable_set(:@data, original_config)
      end
    end

    # Specific helper for 2FA requirement testing
    def with_required_2fa
      with_config(security: { require_two_factor_authentication: true }) { yield }
    end

    private

    def deep_merge_config(base, overrides)
      result = base.dup
      overrides.each do |key, value|
        if value.is_a?(Hash) && result[key].is_a?(Hash)
          result[key] = deep_merge_config(result[key], value)
        else
          result[key] = value
        end
      end
      result
    end
  end
end

module ActionDispatch
  class IntegrationTest
    def sign_in_as(user, account = nil)
      post sign_in_url, params: { email: user.email, password: "Secret1*3*5*" }
      if account
        session = user.sessions.last
        session.update!(account: account) if session
      end
      user
    end
  end
end
