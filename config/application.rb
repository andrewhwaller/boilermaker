require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Add lib directory to load path
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

module BoilermakerApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Configure generators to use Phlex for view scaffolding
    config.generators do |g|
      g.template_engine :phlex_scaffold
      g.scaffold_controller :phlex_scaffold
      g.skip_routes false
      g.helper false
      g.assets false
      g.test_framework nil
    end
  end
end
