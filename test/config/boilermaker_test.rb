# frozen_string_literal: true

require "test_helper"

class BoilermakerConfigTest < ActiveSupport::TestCase
  test "user_registration is disabled" do
    refute Boilermaker::Config.feature_enabled?("user_registration"), "user_registration should be false for single-user tool"
  end
end
