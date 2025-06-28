# frozen_string_literal: true

module Views
  module Layouts
    class Application < Views::Base
      include Phlex::Rails::Helpers::ContentFor
      include Phlex::Rails::Helpers::CspMetaTag
      include Phlex::Rails::Helpers::CsrfMetaTags
      include Phlex::Rails::Helpers::JavascriptImportmap
      include Phlex::Rails::Helpers::StylesheetLink
      include Phlex::Rails::Helpers::Tag

      def view_template(&block)
        doctype

        html(lang: "en") do
          head do
            meta(charset: "utf-8")
            meta(name: "viewport", content: "width=device-width,initial-scale=1")

            title { "Boilermaker" }

            csrf_meta_tags
            csp_meta_tag

            stylesheet_link_tag(:app, "data-turbo-track": "reload")

            link(rel: "manifest", href: "/pwa/manifest.json")

            javascript_importmap_tags
          end

          body(class: "min-h-screen bg-background text-foreground") do
            # Flash messages
            flash.each do |type, message|
              div(class: "max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 mt-4") do
                div(class: flash_class(type)) do
                  plain(message)
                end
              end
            end

            # Navigation
            render Views::Components::Navigation.new

            # Main content
            main(class: "max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8") do
              yield_content_or(&block)
            end
          end
        end
      end

      private

      def flash_class(type)
        case type.to_sym
        when :notice then "text-success"
        when :alert then "text-error"
        else "text-muted"
        end
      end
    end
  end
end
