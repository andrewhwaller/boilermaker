# frozen_string_literal: true

require "rails/engine"

module Boilermaker
  class Engine < ::Rails::Engine
    isolate_namespace Boilermaker

    config.autoload_paths << File.expand_path("app", __dir__)
    config.eager_load_paths << File.expand_path("app", __dir__)

    initializer "boilermaker.assets" do |app|
      app.config.assets.paths << root.join("app", "javascript")
      app.config.assets.paths << root.join("app", "javascript", "controllers")
    end

    initializer "boilermaker.load_config", before: :load_config_initializers do |app|
      begin
        Boilermaker::Config.load!
        Rails.logger.info "Boilermaker configuration loaded successfully"
      rescue => e
        Rails.logger.error "Failed to load Boilermaker configuration: #{e.message}"
        raise e unless Rails.env.production?
      end
    end

    config.to_prepare do
      Dir.glob(File.expand_path("app/controllers/**/*.rb", __dir__)).each do |file|
        load file
      end
    end
  end
end
