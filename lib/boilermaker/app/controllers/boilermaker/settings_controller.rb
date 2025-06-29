require "fileutils"

module Boilermaker
  class SettingsController < ApplicationController
    before_action :add_engine_view_path
    skip_before_action :verify_authenticity_token if Rails.env.development?

    def show
      config = load_config
      @settings = config || {}
      @features = @settings.dig('features') || {}
      render "boilermaker/settings/show"
    end

    def edit
      config = load_config
      @settings = config || {}
      @features = @settings.dig('features') || {}
      render "boilermaker/settings/edit"
    end

    def update
      return head :forbidden unless Rails.env.development?

      config_file = Rails.root.join("config", "boilermaker.yml")
      current_config = File.exist?(config_file) ? YAML.load_file(config_file, aliases: true) || {} : {}
      
      current_config["development"] ||= {}
      
      if settings_params[:app]
        current_config["development"]["app"] ||= {}
        current_config["development"]["app"].merge!(settings_params[:app].to_h.stringify_keys)
      end
      
      if settings_params[:features]
        current_config["development"]["features"] ||= {}
        features = settings_params[:features].to_h.transform_values { |v| v == "1" || v == "true" || v == true }
        current_config["development"]["features"].merge!(features.stringify_keys)
      end
      
      File.write(config_file, current_config.to_yaml)
      
      # Reload the configuration immediately so changes are visible
      Boilermaker::Config.reload!
      
      # Touch restart file for next request (optional in development)
      FileUtils.touch(Rails.root.join('tmp', 'restart.txt'))
      
      redirect_to boilermaker.settings_path, notice: "Settings updated!"
    end

    private

    def add_engine_view_path
      prepend_view_path File.expand_path("../../views", __dir__)
    end

    def load_config
      config_file = Rails.root.join("config", "boilermaker.yml")
      return {} unless File.exist?(config_file)
      
      config = YAML.load_file(config_file, aliases: true) || {}
      config.dig("development") || config.dig("default") || {}
    rescue => e
      Rails.logger.warn "Could not load config: #{e.message}"
      {}
    end

    def settings_params
      params.require(:settings).permit(
        app: [:name, :version, :support_email, :description],
        features: [:user_registration, :password_reset, :two_factor_authentication, :multi_tenant, :personal_accounts]
      )
    end
  end
end
