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

        html(
          lang: "en",
          data: {
            controller: "theme",
            "theme-light-name-value": Boilermaker::Config.theme_light_name,
            "theme-dark-name-value": Boilermaker::Config.theme_dark_name,
            theme: (Current.theme_name || Boilermaker::Config.theme_light_name)
          }
        ) do
          head do
            meta(charset: "utf-8")
            meta(name: "viewport", content: "width=device-width,initial-scale=1")

            title { page_title }

            csrf_meta_tags
            csp_meta_tag

            # Ensure theme matches localStorage/system before CSS loads to avoid flashes
            script do
              plain %(
                (function(){
                  try {
                    var d = document.documentElement;
                    var ls = localStorage.getItem('theme-preference');
                    var light = d.dataset.themeLightNameValue;
                    var dark = d.dataset.themeDarkNameValue;
                    var name = null;
                    if (ls === 'dark') name = dark;
                    else if (ls === 'light') name = light;
                    else {
                      // Fall back to system preference when no stored choice
                      var mq = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)');
                      if (mq && mq.matches) name = dark; else name = light;
                    }
                    if (name) {
                      d.setAttribute('data-theme', name);
                      document.cookie = 'theme_name=' + encodeURIComponent(name) + '; path=/; max-age=31536000; samesite=lax';
                    }
                  } catch (e) {}
                })();
              )
            end

            stylesheet_link_tag(:app, "data-turbo-track": "reload")

            link(rel: "manifest", href: "/pwa/manifest.json")

            javascript_importmap_tags

            # JS-driven indicator transform; no additional CSS needed here
          end

          body(class: body_classes) do
            # Navigation
            render_navigation

            # Content area
            div(class: content_wrapper_classes) do
              # Flash messages
              unless flash.empty?
                div(class: flash_container_classes) do
                  flash.each do |type, message|
                    div(class: flash_class(type)) do
                      span { plain(message) }
                    end
                  end
                end
              end

              # Main content
              main(class: main_content_classes) do
                yield_content_or(&block)
              end
            end
          end
        end
      end

      # Helper method to get page title with fallback
      def page_title
        content_for?(:title) ? content_for(:title) : "Boilermaker"
      end

      private

      # Layout mode detection
      def sidebar_layout?
        Boilermaker.config.get("ui.navigation.layout_mode") == "sidebar"
      end

      def navbar_layout?
        !sidebar_layout?
      end

      # Navigation rendering
      def render_navigation
        if sidebar_layout?
          render Components::SidebarNavigation.new(request: helpers.request)
        else
          render Components::Navigation.new(request: helpers.request)
        end
      end

      # Layout-specific classes
      def body_classes
        base = "min-h-screen bg-base-100 text-base-content"
        sidebar_layout? ? "#{base} pl-64" : base
      end

      def content_wrapper_classes
        sidebar_layout? ? "min-h-screen" : ""
      end

      def flash_container_classes
        if sidebar_layout?
          "px-8 pt-4 space-y-2"
        else
          "max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 mt-4 space-y-2"
        end
      end

      def main_content_classes
        if sidebar_layout?
          "px-8 py-8"
        else
          "max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8"
        end
      end

      # Helper to handle both content_for and direct block content
      def yield_content_or(&block)
        if block_given?
          yield
        elsif content_for?(:content)
          content_for(:content)
        end
      end

      def flash_class(type)
        case type.to_sym
        when :notice, :success
          "alert alert-success"
        when :alert, :error
          "alert alert-error"
        else
          "alert"
        end
      end
    end
  end
end
