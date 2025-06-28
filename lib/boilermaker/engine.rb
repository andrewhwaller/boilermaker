# frozen_string_literal: true

require 'rails/engine'

module Boilermaker
  class Engine < ::Rails::Engine
    isolate_namespace Boilermaker

    # Configure autoload paths
    config.autoload_paths << File.expand_path('app', __dir__)
    config.eager_load_paths << File.expand_path('app', __dir__)
    
    # Load configuration
    initializer 'boilermaker.load_config', before: :load_config_initializers do |app|
      begin
        Boilermaker::Config.load!
        Rails.logger.info "Boilermaker configuration loaded successfully"
      rescue => e
        Rails.logger.error "Failed to load Boilermaker configuration: #{e.message}"
        # Don't raise in production, just log and continue with defaults
        raise e unless Rails.env.production?
      end
    end
    
    # Explicitly load controllers
    config.to_prepare do
      Dir.glob(File.expand_path('app/controllers/**/*.rb', __dir__)).each do |file|
        load file
      end
    end
  end
end 