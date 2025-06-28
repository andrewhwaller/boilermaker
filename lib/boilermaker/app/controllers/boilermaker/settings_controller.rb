module Boilermaker
  class SettingsController < ApplicationController
    before_action :add_engine_view_path
    
    def show
      # Display current configuration settings with safe defaults
      @settings = safe_config_data
      @features = safe_features_data
      
      # Explicitly render the view
      render 'boilermaker/settings/show'
    end

    def edit
      # Allow editing of configuration
      @settings = safe_config_data
      @features = safe_features_data
    end

    def update
      # Update configuration (implement as needed)
      redirect_to boilermaker.settings_path, notice: "Settings updated successfully."
    end
    
    private
    
    def add_engine_view_path
      prepend_view_path File.expand_path('../../views', __dir__)
    end
    
    def safe_config_data
      return {} unless defined?(Boilermaker::Config) && Boilermaker::Config.respond_to?(:data)
      Boilermaker::Config.data || {}
    rescue => e
      Rails.logger.error "Error loading Boilermaker config: #{e.message}"
      {}
    end
    
    def safe_features_data
      return {} unless defined?(Boilermaker::Config) && Boilermaker::Config.respond_to?(:get)
      Boilermaker::Config.get('features') || {}
    rescue => e
      Rails.logger.error "Error loading Boilermaker features: #{e.message}"
      {}
    end
  end
end

