# frozen_string_literal: true

require "fileutils"
require_relative "boilermaker/version"
require_relative "boilermaker/config"
require_relative "boilermaker/engine"

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

    # Simple restart method for settings interface
    def restart
      if Rails.env.development?
        Rails.logger.info "Boilermaker: Restarting Rails application..."
        # Touch the restart file - this is the standard Rails way to restart
        FileUtils.touch(Rails.root.join('tmp', 'restart.txt'))
        true
      else
        Rails.logger.warn "Boilermaker: Restart only available in development mode"
        false
      end
    end

    # Restart the application after configuration changes
    def restart!
      if Rails.env.development?
        restart_development_server!
      elsif Rails.env.production?
        restart_production_server!
      else
        Rails.logger.info "Boilermaker restart requested but no restart strategy defined for #{Rails.env} environment"
      end
    end

    private

    def restart_development_server!
      Rails.logger.info "Boilermaker: Restarting development server..."

      # Touch tmp/restart.txt to trigger Rails reloader
      restart_file = Rails.root.join("tmp", "restart.txt")
      FileUtils.touch(restart_file)

      Rails.logger.info "Boilermaker: Development server restart triggered via tmp/restart.txt"
    end

    def restart_production_server!
      Rails.logger.info "Boilermaker: Production restart requested"

      # In production, we'll use different strategies based on deployment method
      if File.exist?(Rails.root.join("tmp", "pids", "server.pid"))
        # Standard Rails server deployment
        restart_file = Rails.root.join("tmp", "restart.txt")
        FileUtils.touch(restart_file)
        Rails.logger.info "Boilermaker: Production server restart triggered via tmp/restart.txt"
      elsif system_has_command?("systemctl")
        # Systemd deployment
        restart_systemd_service!
      elsif File.exist?("/tmp/unicorn.pid") || File.exist?("/var/run/unicorn.pid")
        # Unicorn deployment
        restart_unicorn_server!
      else
        # Fallback: just touch restart file
        restart_file = Rails.root.join("tmp", "restart.txt")
        FileUtils.touch(restart_file)
        Rails.logger.warn "Boilermaker: Using fallback restart method (tmp/restart.txt). Consider configuring a more specific restart strategy."
      end
    end

    def restart_systemd_service!
      service_name = ENV["BOILERMAKER_SYSTEMD_SERVICE"] || "#{Rails.application.class.module_parent_name.downcase}-#{Rails.env}"

      begin
        system("sudo systemctl reload #{service_name}")
        Rails.logger.info "Boilermaker: Systemd service '#{service_name}' reloaded"
      rescue => e
        Rails.logger.error "Boilermaker: Failed to reload systemd service: #{e.message}"
        # Fallback to restart file
        FileUtils.touch(Rails.root.join("tmp", "restart.txt"))
      end
    end

    def restart_unicorn_server!
      begin
        # Send USR2 signal to Unicorn master for graceful restart
        pid_file = File.exist?("/tmp/unicorn.pid") ? "/tmp/unicorn.pid" : "/var/run/unicorn.pid"
        pid = File.read(pid_file).strip.to_i
        Process.kill("USR2", pid)
        Rails.logger.info "Boilermaker: Unicorn server graceful restart initiated"
      rescue => e
        Rails.logger.error "Boilermaker: Failed to restart Unicorn: #{e.message}"
        # Fallback to restart file
        FileUtils.touch(Rails.root.join("tmp", "restart.txt"))
      end
    end

    def system_has_command?(command)
      system("which #{command} > /dev/null 2>&1")
    end
  end
end
