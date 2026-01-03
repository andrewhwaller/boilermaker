# frozen_string_literal: true

require "rails/generators"
require "yaml"

module Boilermaker
  module Generators
    class BaseGenerator < Rails::Generators::Base
      # Hide this generator from the list - it's a parent class, not runnable
      hide!

      class_option :skip_routes, type: :boolean, default: false,
                                 desc: "Skip route generation"
      class_option :skip_tests, type: :boolean, default: false,
                                desc: "Skip test file generation"
      class_option :skip_config, type: :boolean, default: false,
                                 desc: "Skip config file updates"
      class_option :skip_seeds, type: :boolean, default: false,
                                desc: "Skip seed data generation"

      protected

      # Add a gem to the Gemfile if not already present
      def add_gem(name, version = nil, options = {})
        gemfile_content = File.read(gemfile_path)
        return if gemfile_content.include?("gem \"#{name}\"") ||
                  gemfile_content.include?("gem '#{name}'")

        gem_line = if version
          "gem \"#{name}\", \"#{version}\""
        else
          "gem \"#{name}\""
        end

        options.each do |key, value|
          gem_line += ", #{key}: #{value.inspect}"
        end

        append_to_file gemfile_path, "\n#{gem_line}\n"
        say "Added gem: #{name}", :green
      end

      # Run bundle install
      def bundle_install
        say "Running bundle install...", :yellow
        run "bundle install"
      end

      # Create a route file for the feature
      def create_route_file(feature_name, content)
        return if options[:skip_routes]

        routes_dir = Rails.root.join("config", "routes")
        FileUtils.mkdir_p(routes_dir)

        route_file = routes_dir.join("#{feature_name}.rb")
        create_file route_file, content
        add_draw_to_routes(feature_name)
      end

      # Add draw statement to main routes.rb
      def add_draw_to_routes(feature_name)
        routes_file = Rails.root.join("config", "routes.rb")
        routes_content = File.read(routes_file)
        draw_line = "  draw :#{feature_name}"

        return if routes_content.include?(draw_line)

        # Insert before the final 'end'
        insert_point = routes_content.rindex("end")
        return unless insert_point

        new_content = routes_content.insert(insert_point, "#{draw_line}\n")
        File.write(routes_file, new_content)
        say "Added 'draw :#{feature_name}' to routes.rb", :green
      end

      # Update boilermaker.yml with feature flags
      def update_config(feature_config)
        return if options[:skip_config]

        config_path = Rails.root.join("config", "boilermaker.yml")
        config = if File.exist?(config_path)
          YAML.load_file(config_path, aliases: true, permitted_classes: [Symbol]) || {}
        else
          {}
        end

        # Update development section
        config["development"] ||= {}
        config["development"]["features"] ||= {}
        feature_config.each do |key, value|
          config["development"]["features"][key.to_s] = value
        end

        # Update default section too
        config["default"] ||= {}
        config["default"]["features"] ||= {}
        feature_config.each do |key, value|
          config["default"]["features"][key.to_s] = value
        end

        File.write(config_path, config.to_yaml)
        say "Updated config/boilermaker.yml with feature flags", :green
      end

      # Append seed data to db/seeds.rb
      def append_seeds(seed_content)
        return if options[:skip_seeds]

        seeds_file = Rails.root.join("db", "seeds.rb")
        append_to_file seeds_file, "\n#{seed_content}\n"
        say "Added development seeds to db/seeds.rb", :green
      end

      # Interactive scope selection for features that need it
      def prompt_for_scope(feature_name)
        say ""
        say "This feature can be scoped to:", :yellow
        say "  [1] Account - One #{feature_name} per team/organization"
        say "  [2] User    - Each user has their own #{feature_name}"
        say ""

        answer = ask("Select scope:")

        case answer.strip
        when "1", "account", "Account"
          :account
        when "2", "user", "User"
          :user
        else
          say "Invalid selection. Please enter 1 or 2.", :red
          prompt_for_scope(feature_name)
        end
      end

      # Check if a feature is enabled in config
      def feature_enabled?(feature_name)
        config_path = Rails.root.join("config", "boilermaker.yml")
        return false unless File.exist?(config_path)

        config = YAML.load_file(config_path, aliases: true, permitted_classes: [Symbol]) || {}
        dev_config = config["development"] || {}
        features = dev_config["features"] || {}
        features[feature_name.to_s] == true
      end

      # Create a controller concern for feature access control
      def create_feature_concern(feature_name)
        concern_content = <<~RUBY
          # frozen_string_literal: true

          module #{feature_name.camelize}Feature
            extend ActiveSupport::Concern

            included do
              before_action :require_#{feature_name}_feature!
            end

            private

            def require_#{feature_name}_feature!
              return if ::Boilermaker.config.feature_enabled?("#{feature_name}")

              render plain: "Feature not available", status: :not_found
            end
          end
        RUBY

        create_file Rails.root.join("app", "controllers", "concerns", "#{feature_name}_feature.rb"),
                    concern_content
      end

      # Print next steps after generation
      def print_next_steps(steps)
        say ""
        say "Next steps:", :green
        steps.each_with_index do |step, index|
          say "  #{index + 1}. #{step}"
        end
        say ""
      end

      private

      def gemfile_path
        Rails.root.join("Gemfile")
      end
    end
  end
end
