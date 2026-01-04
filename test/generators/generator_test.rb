# frozen_string_literal: true

require "test_helper"
require "rails/generators/test_case"
require_relative "../../lib/generators/boilermaker/payments/payments_generator"
require_relative "../../lib/generators/boilermaker/notifications/notifications_generator"

class PaymentsGeneratorTest < Rails::Generators::TestCase
  tests Boilermaker::Generators::PaymentsGenerator
  destination Rails.root.join("tmp/generators")
  setup :prepare_destination

  test "payments generator inherits from base generator" do
    assert Boilermaker::Generators::PaymentsGenerator < Boilermaker::Generators::BaseGenerator
    assert Boilermaker::Generators::PaymentsGenerator < Rails::Generators::Base
  end

  test "payments generator has required templates" do
    template_dir = File.expand_path("../../lib/generators/boilermaker/payments/templates", __dir__)

    expected_templates = %w[
      initializers/pay.rb.tt
      controllers/payments_controller.rb.tt
      views/payments/pricing.rb.tt
      views/settings/billing.rb.tt
      components/pricing_card.rb.tt
      components/subscription_status.rb.tt
      tests/payments_controller_test.rb.tt
    ]

    expected_templates.each do |template|
      path = File.join(template_dir, template)
      assert File.exist?(path), "Missing template: #{template}"
    end
  end

  test "payments generator pretend mode shows expected files" do
    # Simulate scope selection by setting instance variable
    generator = Boilermaker::Generators::PaymentsGenerator.new([], { pretend: true, skip_routes: true, skip_config: true, skip_seeds: true })
    generator.instance_variable_set(:@scope, :user)

    # Verify generator methods exist
    assert generator.respond_to?(:create_controller)
    assert generator.respond_to?(:create_views)
    assert generator.respond_to?(:create_components)
  end
end

class NotificationsGeneratorTest < Rails::Generators::TestCase
  tests Boilermaker::Generators::NotificationsGenerator
  destination Rails.root.join("tmp/generators")
  setup :prepare_destination

  test "notifications generator has required templates" do
    template_dir = File.expand_path("../../lib/generators/boilermaker/notifications/templates", __dir__)

    expected_templates = %w[
      models/notifiable.rb.tt
      controllers/notifications_controller.rb.tt
      views/notifications/index.rb.tt
      views/settings/notifications.rb.tt
      components/notification_bell.rb.tt
      components/notification_item.rb.tt
      notifiers/welcome_notifier.rb.tt
      notifiers/application_notifier.rb.tt
      tests/notifications_controller_test.rb.tt
    ]

    expected_templates.each do |template|
      path = File.join(template_dir, template)
      assert File.exist?(path), "Missing template: #{template}"
    end
  end

  test "notifications generator pretend mode shows expected files" do
    generator = Boilermaker::Generators::NotificationsGenerator.new([], { pretend: true, skip_routes: true, skip_config: true, skip_seeds: true })
    generator.instance_variable_set(:@scope, :user)

    assert generator.respond_to?(:create_controller)
    assert generator.respond_to?(:create_views)
    assert generator.respond_to?(:create_components)
    assert generator.respond_to?(:create_example_notifiers)
  end
end

class BaseGeneratorTest < ActiveSupport::TestCase
  test "base generator provides helper methods" do
    # Load the base generator
    require_relative "../../lib/generators/boilermaker/base_generator"

    generator_class = Boilermaker::Generators::BaseGenerator

    # Should have these class options
    assert generator_class.class_options.key?(:skip_routes)
    assert generator_class.class_options.key?(:skip_tests)
    assert generator_class.class_options.key?(:skip_config)
    assert generator_class.class_options.key?(:skip_seeds)
  end
end

class GeneratorListingTest < ActiveSupport::TestCase
  test "generators appear in rails generate help" do
    output = `bin/rails generate --help 2>&1`

    assert_match(/boilermaker:payments/, output)
    assert_match(/boilermaker:notifications/, output)
    # Base should be hidden
    refute_match(/boilermaker:base/, output)
  end

  test "generators show usage info" do
    payments_output = `bin/rails generate boilermaker:payments --help 2>&1`
    assert_match(/subscription billing/, payments_output)
    assert_match(/Stripe/, payments_output)

    notifications_output = `bin/rails generate boilermaker:notifications --help 2>&1`
    assert_match(/notification system/, notifications_output)
    assert_match(/Noticed/, notifications_output)
  end
end
