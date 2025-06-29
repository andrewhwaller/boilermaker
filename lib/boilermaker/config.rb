# frozen_string_literal: true

require "yaml"
require "erb"

module Boilermaker
  class Config
    class << self
      attr_reader :data

      def load!
        @data = load_config
        validate_config! unless Rails.env.production?
        freeze_config
      end

      # Reload configuration (useful for testing)
      def reload!
        load!
        Rails.logger.info "Boilermaker configuration reloaded"
      end

      def method_missing(method_name, *args, &block)
        if @data.is_a?(Hash) && @data.key?(method_name.to_s)
          ConfigSection.new(@data[method_name.to_s])
        else
          super
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        (@data.is_a?(Hash) && @data.key?(method_name.to_s)) || super
      end

      # Direct access method for any configuration value
      def get(key_path)
        # Auto-load configuration if not already loaded
        load! unless @data

        return nil unless @data.is_a?(Hash)

        keys = key_path.to_s.split(".")
        value = @data

        keys.each do |key|
          if value.is_a?(Hash) && value.key?(key)
            value = value[key]
          else
            return nil
          end
        end

        value
      end

      # Convenience methods for commonly accessed config
      def app_name
        get("app.name") || "Boilermaker"
      end

      def app_version
        get("app.version") || "1.0.0"
      end

      def app_description
        get("app.description") || "A modern Rails application"
      end

      def support_email
        get("app.support_email") || "support@example.com"
      end

      # Feature flags
      def feature_enabled?(feature_name)
        get("features.#{feature_name}") == true
      end

      def personal_accounts?
        feature_enabled?("personal_accounts")
      end

      def multi_tenant?
        feature_enabled?("multi_tenant")
      end

      def two_factor_authentication?
        feature_enabled?("two_factor_authentication")
      end

      # Authentication config
      def password_min_length
        12
      end

      def session_timeout_minutes
        1440 # 24 hours
      end

      def remember_me_duration_days
        30
      end

      # Account config
      def max_users_per_account
        get("accounts.max_users_per_account") || 10
      end

      def default_account_name
        get("accounts.default_account_name") || "Personal"
      end

      # Email config
      def from_email
        get("email.from_email") || "noreply@example.com"
      end

      def from_name
        get("email.from_name") || app_name
      end

      # UI config
      def primary_color
        get("ui.brand.primary_color") || "#3b82f6"
      end

      def secondary_color
        get("ui.brand.secondary_color") || "#64748b"
      end

      def show_branding?
        get("ui.navigation.show_branding") != false
      end

      private

      def load_config
        config_file = Rails.root.join("config", "boilermaker.yml")

        unless File.exist?(config_file)
          if Rails.env.production?
            Rails.logger.warn "Boilermaker configuration file not found at #{config_file}, using defaults"
            return {}
          else
            raise "Boilermaker configuration file not found at #{config_file}"
          end
        end

        erb_content = ERB.new(File.read(config_file)).result
        full_config = YAML.safe_load(erb_content, aliases: true)

        # Get config for current environment, fallback to default
        env_config = full_config[Rails.env] || full_config["default"]

        unless env_config
          if Rails.env.production?
            Rails.logger.warn "No configuration found for environment '#{Rails.env}' in #{config_file}, using defaults"
            return {}
          else
            raise "No configuration found for environment '#{Rails.env}' in #{config_file}"
          end
        end

        env_config
      rescue => e
        if Rails.env.production?
          Rails.logger.error "Failed to load Boilermaker configuration: #{e.message}, using defaults"
          {}
        else
          Rails.logger.error "Failed to load Boilermaker configuration: #{e.message}"
          raise
        end
      end

      def validate_config!
        # Skip validation in production
        return if Rails.env.production?

        # Validate required configuration
        required_configs = [
          "app.name"
        ]

        required_configs.each do |config_path|
          value = get(config_path)
          if value.nil?
            raise "Required configuration missing: #{config_path}"
          end
        end

        Rails.logger.debug "Boilermaker configuration validation passed"
      end

      def freeze_config
        @data.deep_freeze if @data.respond_to?(:deep_freeze)
        @data.freeze
      end
    end

    # Helper class for nested configuration access
    class ConfigSection
      def initialize(data)
        @data = data
      end

      def method_missing(method_name, *args, &block)
        if @data.is_a?(Hash) && @data.key?(method_name.to_s)
          value = @data[method_name.to_s]
          value.is_a?(Hash) ? ConfigSection.new(value) : value
        else
          super
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        @data.is_a?(Hash) && @data.key?(method_name.to_s) || super
      end

      def [](key)
        @data[key.to_s] if @data.is_a?(Hash)
      end

      def to_h
        @data
      end
    end
  end
end

# Add deep_freeze method to Hash if it doesn't exist
class Hash
  def deep_freeze
    freeze
    each_value do |v|
      v.deep_freeze if v.respond_to?(:deep_freeze)
    end
    self
  end
end
