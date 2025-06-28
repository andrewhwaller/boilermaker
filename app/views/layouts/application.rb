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

        html do
          head do
            title { plain(content_for(:title) || "Boilermaker") }
            meta name: "viewport", content: "width=device-width,initial-scale=1"
            meta name: "apple-mobile-web-app-capable", content: "yes"
            meta name: "mobile-web-app-capable", content: "yes"
            csrf_meta_tags
            csp_meta_tag

            content_for :head

            # PWA manifest (commented out for now)
            # tag.link rel: "manifest", href: pwa_manifest_path(format: :json)

            link rel: "icon", href: "/icon.png", type: "image/png"
            link rel: "icon", href: "/icon.svg", type: "image/svg+xml"
            link rel: "apple-touch-icon", href: "/icon.png"

            stylesheet_link_tag "application", "data-turbo-track": "reload"
            stylesheet_link_tag "tailwind", "data-turbo-track": "reload"
            javascript_importmap_tags
          end

          body(class: "bg-surface text-foreground") do
            # Navigation
            render Components::Navigation.new

            # Main content area
            main(class: "max-w-4xl mx-auto p-8") do
              # Flash messages
              if notice
                div(class: "text-success mb-4") { plain(notice) }
              end

              if alert
                div(class: "text-error mb-4") { plain(alert) }
              end

              yield_content_or(&block)
            end
          end
        end
      end
    end
  end
end
