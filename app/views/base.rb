# frozen_string_literal: true

module Views
  class Base < Phlex::HTML
    include Phlex::Rails
    include Phlex::Rails::Helpers::Routes
    include Phlex::Rails::Helpers::Pluralize
    include Phlex::Rails::Helpers::NumberToHuman
    include Phlex::Rails::Helpers::Truncate
    include Phlex::Rails::Helpers::Tag
    include Phlex::Rails::Helpers::FormWith
    include Phlex::Rails::Helpers::ButtonTo
    include Phlex::Rails::Helpers::LinkTo
    include Phlex::Rails::Helpers::ContentFor
    include Phlex::Rails::Helpers::Flash
    include Rails.application.routes.url_helpers

    def default_url_options
      { host: "localhost", port: 3000 }
    end

    def initialize(...)
      super
      @helpers = Rails.application.routes.url_helpers
    end

    def helpers
      @helpers
    end

    def self.layout(layout = nil)
      if layout
        @layout = layout
      else
        @layout || "application"
      end
    end

    def self.template_path(path = nil)
      if path
        @template_path = path
      else
        @template_path || default_template_path
      end
    end

    def self.default_template_path
      name.underscore.sub(%r{/view$}, "").sub(%r{^views/}, "")
    end

    def view_template
      raise NotImplementedError, "#{self.class} must implement #view_template"
    end

    def template
      view_template
    end

    private

    def render(component)
      component.call
    end
  end
end
