# frozen_string_literal: true

module Views
  module Boilermaker
    module Layouts
      # Base dashboard layout that provides a consistent structure
      # for all theme-specific dashboard layouts
      class DashboardBase < Phlex::HTML
        include Phlex::Rails::Helpers::Routes
        include Phlex::Rails::Helpers::ContentFor
        include Phlex::Rails::Helpers::CSPMetaTag
        include Phlex::Rails::Helpers::CSRFMetaTags
        include Phlex::Rails::Helpers::Flash
        include Phlex::Rails::Helpers::JavaScriptImportmapTags
        include Phlex::Rails::Helpers::StyleSheetLinkTag
        include ApplicationHelper

        def initialize(title: "Dashboard")
          @title = title
        end

        # Override in subclasses to provide theme-specific header
        def header_content = nil

        # Override in subclasses to provide theme-specific footer
        def footer_content = nil

        # Override in subclasses to set the theme class
        def theme_name = "paper"

        # Override in subclasses to set polarity
        def polarity = "light"

        def view_template(&block)
          doctype

          html(
            lang: "en",
            data: {
              theme: theme_name,
              polarity: polarity
            }
          ) {
            render_head
            render_body(&block)
          }
        end

        private

          def render_head
            head {
              meta(charset: "utf-8")
              meta(name: "viewport", content: "width=device-width,initial-scale=1")
              title { @title }
              csrf_meta_tags
              csp_meta_tag
              link(rel: "icon", type: "image/svg+xml", href: "/favicon.svg")
              stylesheet_link_tag(:app, "data-turbo-track": "reload")
              raw app_font_style_tag
              raw font_stylesheet_link_tag
              javascript_importmap_tags
            }
          end

          def render_body(&block)
            body(class: "bg-surface text-body min-h-screen") {
              header_content
              main(class: "max-w-4xl mx-auto p-6") { yield }
              footer_content
            }
          end
      end
    end
  end
end
