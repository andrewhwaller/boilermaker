# frozen_string_literal: true

require "fileutils"
require_relative "boilermaker/version"
require_relative "boilermaker/config"
require_relative "boilermaker/engine"
require_relative "boilermaker/themes"

# Require routes after engine is loaded
require_relative "boilermaker/config/routes"

module Boilermaker
  class << self
    def config
      Config
    end

    def configure
      yield(config) if block_given?
    end

    def feature_enabled?(feature_name)
      config.feature_enabled?(feature_name)
    end
  end
end
