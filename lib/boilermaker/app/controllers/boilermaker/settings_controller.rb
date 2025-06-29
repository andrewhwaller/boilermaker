require 'fileutils'

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
      
      # Explicitly render the edit view
      render 'boilermaker/settings/edit'
    end

    def update
      # Update configuration based on form submission
      begin
        # Update the configuration file
        updated_settings = update_config_file(settings_params)
        
        # Reload the configuration in memory
        Boilermaker::Config.reload!
        
        # Check if critical settings changed that require restart
        restart_needed = check_restart_needed(updated_settings)
        
        # Log the successful update
        Rails.logger.info "Boilermaker configuration updated successfully"
        
        # Provide user feedback
        success_message = "Configuration updated successfully!"
        if restart_needed && Rails.env.development?
          success_message += " Some changes require a server restart to take full effect."
        end
        
        redirect_to boilermaker.settings_path, notice: success_message
        
      rescue => e
        Rails.logger.error "Failed to update Boilermaker configuration: #{e.message}"
        redirect_to boilermaker.edit_settings_path, 
                   alert: "Failed to update configuration: #{e.message}"
      end
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
    
    def settings_params
      params.require(:settings).permit(
        app: [:name, :version, :support_email, :description],
        features: [:user_registration, :password_reset, :two_factor_authentication, :multi_tenant, :personal_accounts]
      )
    end
    
    def update_config_file(new_settings)
      config_file = Rails.root.join("config", "boilermaker.yml")
      
      # Ensure the config directory exists
      FileUtils.mkdir_p(File.dirname(config_file))
      
      # Load the current configuration file with alias support
      current_config = if File.exist?(config_file)
        YAML.load_file(config_file, aliases: true) || {}
      else
        {}
      end
      
      # Update the configuration for the current environment
      env_config = current_config[Rails.env] || {}
      
      # Track what we're updating for validation
      updated_settings = {}
      
      # Merge the new settings
      if new_settings[:app]
        env_config['app'] ||= {}
        app_updates = new_settings[:app].to_h.stringify_keys
        env_config['app'].merge!(app_updates)
        updated_settings[:app] = app_updates
        Rails.logger.info "Updated app settings: #{app_updates.inspect}"
      end
      
      if new_settings[:features]
        env_config['features'] ||= {}
        # Convert feature values to booleans
        feature_updates = new_settings[:features].to_h.transform_values do |value|
          value == '1' || value == 'true' || value == true
        end
        env_config['features'].merge!(feature_updates.stringify_keys)
        updated_settings[:features] = feature_updates
        Rails.logger.info "Updated feature settings: #{feature_updates.inspect}"
      end
      
      # Update the configuration
      current_config[Rails.env] = env_config
      
      # Also update the default section to keep it in sync
      current_config['default'] = env_config.dup
      
      # Create a backup before writing
      if File.exist?(config_file)
        backup_file = "#{config_file}.backup.#{Time.current.to_i}"
        FileUtils.cp(config_file, backup_file)
        Rails.logger.info "Created backup at #{backup_file}"
      end
      
      # Write the updated configuration back to the file
      File.write(config_file, YAML.dump(current_config))
      Rails.logger.info "Boilermaker configuration written to #{config_file}"
      
      # Verify the file was written correctly
      unless File.exist?(config_file)
        raise "Configuration file was not created successfully"
      end
      
      updated_settings
    end

    def validate_config_update(updated_settings)
      config_file = Rails.root.join("config", "boilermaker.yml")
      
      # Verify the file exists and is readable
      unless File.exist?(config_file) && File.readable?(config_file)
        raise "Configuration file is not accessible after update"
      end
      
      # Try to load and parse the file to ensure it's valid YAML
      begin
        reloaded_config = YAML.load_file(config_file, aliases: true)
        env_config = reloaded_config[Rails.env] || reloaded_config["default"]
        
        unless env_config.is_a?(Hash)
          raise "Configuration structure is invalid after update"
        end
        
        # Verify our updates are actually in the file
        if updated_settings[:app]
          updated_settings[:app].each do |key, value|
            actual_value = env_config.dig('app', key)
            if actual_value != value
              Rails.logger.warn "App setting '#{key}' expected '#{value}' but got '#{actual_value}'"
            end
          end
        end
        
        if updated_settings[:features]
          updated_settings[:features].each do |key, value|
            actual_value = env_config.dig('features', key)
            if actual_value != value
              Rails.logger.warn "Feature setting '#{key}' expected '#{value}' but got '#{actual_value}'"
            end
          end
        end
        
        Rails.logger.info "Boilermaker configuration validation passed"
        
      rescue => e
        raise "Configuration file is invalid after update: #{e.message}"
      end
    end

    def check_restart_needed(updated_settings)
      # In development, certain changes might benefit from a server restart
      return false unless Rails.env.development?
      
      critical_app_settings = ['name']
      critical_features = ['multi_tenant', 'personal_accounts']
      
      restart_needed = false
      
      if updated_settings[:app]
        restart_needed ||= (updated_settings[:app].keys & critical_app_settings).any?
      end
      
      if updated_settings[:features]
        restart_needed ||= (updated_settings[:features].keys.map(&:to_s) & critical_features).any?
      end
      
      if restart_needed
        Rails.logger.info "Restart recommended due to critical setting changes"
      end
      
      restart_needed
    end
  end
end

