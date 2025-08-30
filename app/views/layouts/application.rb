# frozen_string_literal: true

module Views
  module Layouts
    class Application < Phlex::HTML
      # Include the Components kit for component access
      include Components

      # Include Rails helpers
      include Phlex::Rails::Helpers::Routes
      include Phlex::Rails::Helpers::ContentFor
      include Phlex::Rails::Helpers::CSPMetaTag
      include Phlex::Rails::Helpers::CSRFMetaTags
      include Phlex::Rails::Helpers::Flash
      include Phlex::Rails::Helpers::JavaScriptImportmapTags
      include Phlex::Rails::Helpers::StyleSheetLinkTag
      include Phlex::Rails::Helpers::Tag
      include ApplicationHelper

      def view_template(&block)
        doctype

        html(lang: "en") do
          head do
            meta(charset: "utf-8")
            meta(name: "viewport", content: "width=device-width,initial-scale=1")

            title { page_title }

            csrf_meta_tags
            csp_meta_tag

            stylesheet_link_tag(:app, "data-turbo-track": "reload")

            link(rel: "manifest", href: "/pwa/manifest.json")

            javascript_importmap_tags
          end

          body(class: "min-h-screen bg-surface text-foreground") do
            # Navigation
            render Components::Navigation.new

            # Flash messages
            unless flash.empty?
              div(class: "max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 mt-4") do
                flash.each do |type, message|
                  div(class: flash_class(type)) do
                    plain(message)
                  end
                end
              end
            end

            # Main content
            main(class: "max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8") do
              yield_content_or(&block)
            end
          end
        end
      end

      # Helper method to get page title with fallback
      def page_title
        content_for?(:title) ? content_for(:title) : "Boilermaker"
      end

      private

      # Helper to handle both content_for and direct block content
      def yield_content_or(&block)
        if block_given?
          yield
        elsif content_for?(:content)
          content_for(:content)
        end
      end

      def flash_class(type)
        base_classes = "p-4 mb-4 rounded-lg"
        type_classes = case type.to_sym
        when :notice, :success
          "bg-success/10 text-success border border-green-200"
        when :alert, :error
          "bg-error/10 text-error border border-red-200"
        else
          "bg-muted/10 text-muted border border-border"
        end
        "#{base_classes} #{type_classes}"
      end
    end
  end
end
