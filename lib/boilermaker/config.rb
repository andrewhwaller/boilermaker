# frozen_string_literal: true

require "yaml"
require "fileutils"
require_relative "themes"

module Boilermaker
  class Config
    CONFIG_PATH = Rails.root.join("config", "boilermaker.yml").freeze

    class << self
      attr_reader :data

      def load!
        @data = load_yaml_config
        validate_required! if Rails.env.development?
        @data.freeze
      end

      def reload!
        load!
        Rails.logger.info "Boilermaker configuration reloaded"
      end

      # Universal accessor
      def get(key_path)
        load! unless @data
        return nil unless @data.is_a?(Hash)

        keys = key_path.to_s.split(".")
        keys.reduce(@data) { |value, key| value.is_a?(Hash) ? value[key] : nil }
      end

      # Essential convenience methods
      def app_name
        get("app.name") || "Boilermaker"
      end

      def app_version
        get("app.version") || "1.0.0"
      end

      def feature_enabled?(feature_name)
        get("features.#{feature_name}") == true
      end

      # Feature flag convenience methods
      def multi_tenant?
        feature_enabled?("multi_tenant")
      end

      def personal_accounts?
        feature_enabled?("personal_accounts")
      end

      def two_factor_authentication?
        feature_enabled?("two_factor_authentication")
      end

      # Additional convenience methods
      def support_email
        get("app.support_email") || "support@example.com"
      end

      def password_min_length
        get("auth.password.min_length") || 12
      end

      def session_timeout_minutes
        get("auth.session.timeout_minutes") || 1440
      end

      def primary_color
        get("ui.brand.primary_color") || get("ui.colors.primary") || "#000000"
      end

      def secondary_color
        get("ui.brand.secondary_color") || get("ui.colors.secondary") || "#ffffff"
      end

      def theme_light_name
        get("ui.theme.light") || "work-station"
      end

      def theme_dark_name
        get("ui.theme.dark") || "command-center"
      end

      def font_name
        get("ui.typography.font") || "CommitMono"
      end

      # Settings form support
      def load_raw
        return {} unless File.exist?(CONFIG_PATH)
        YAML.load_file(CONFIG_PATH, aliases: true) || {}
      rescue
        {}
      end

      def write!(config_hash)
        File.write(CONFIG_PATH, config_hash.to_yaml)
      end

      # Support for accessing config sections (used by tests)
      def method_missing(method_name, *args, &block)
        load! unless @data
        if @data.is_a?(Hash) && @data.key?(method_name.to_s)
          ConfigSection.new(@data[method_name.to_s])
        else
          super
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        load! unless @data
        (@data.is_a?(Hash) && @data.key?(method_name.to_s)) || super
      end

      # Update config from form parameters
      def update_from_params!(params_hash)
        config = load_raw
        update_config_data!(config, params_hash.deep_stringify_keys)
        validate_config!(config)
        write!(config)
        reload!

        # Run post-update hooks but don't let failures break the main flow
        begin
          run_post_update_hooks
        rescue => e
          Rails.logger.warn "Post-update hooks failed: #{e.message}"
          # Don't re-raise - config update was successful
        end
      end

      private

      def load_yaml_config
        return {} unless File.exist?(CONFIG_PATH)

        full_config = YAML.load_file(CONFIG_PATH, aliases: true) || {}
        defaults = full_config["default"] || {}
        env_overrides = full_config[Rails.env] || {}
        defaults.merge(env_overrides)
      rescue => e
        Rails.logger.error "Failed to load Boilermaker configuration: #{e.message}. Using defaults."
        {}
      end

      def validate_required!
        raise "Required configuration missing: app.name" if get("app.name").nil?
      end

      def update_config_data!(config, params_hash)
        dev = (config["development"] ||= {})

        # Update app settings
        if params_hash["app"].is_a?(Hash)
          dev["app"] = (dev["app"] || {}).merge(params_hash["app"])
        end

        # Update features (normalize to boolean)
        if params_hash["features"].is_a?(Hash)
          features = normalize_boolean_values(params_hash["features"])
          dev["features"] = (dev["features"] || {}).merge(features)
        end

        # Update theme settings
        if params_hash.dig("ui", "theme").is_a?(Hash)
          dev["ui"] ||= {}
          dev["ui"]["theme"] = (dev["ui"]["theme"] || {}).merge(params_hash["ui"]["theme"])
        end

        # Update navigation settings
        if params_hash.dig("ui", "navigation").is_a?(Hash)
          dev["ui"] ||= {}
          dev["ui"]["navigation"] = (dev["ui"]["navigation"] || {}).merge(params_hash["ui"]["navigation"])
        end

        # Update typography settings
        if params_hash.dig("ui", "typography").is_a?(Hash)
          dev["ui"] ||= {}
          dev["ui"]["typography"] = (dev["ui"]["typography"] || {}).merge(params_hash["ui"]["typography"])
        end
      end

      def validate_config!(config)
        defaults = config["default"] || {}
        dev = config["development"] || {}
        merged = defaults.merge(dev)

        raise "app.name is required" if merged.dig("app", "name").nil?
      end

      def normalize_boolean_values(hash)
        hash.transform_values { |v| v == true || v == "true" || v == "1" }
      end

      def run_post_update_hooks
        begin
          Rails.logger.info "[settings] Themes updated: light=#{theme_light_name}, dark=#{theme_dark_name}"
        rescue
          # ignore logger availability
        end
        Rails.application.load_tasks unless defined?(Rake::Task) && Rake::Task.task_defined?("daisyui:prebuilt")
        Rake::Task["daisyui:prebuilt"].reenable
        Rake::Task["daisyui:prebuilt"].invoke

        FileUtils.touch(Rails.root.join("tmp", "restart.txt"))
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
