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

        html(lang: "en", data: { controller: "theme" }) do
          head do
            meta(charset: "utf-8")
            meta(name: "viewport", content: "width=device-width,initial-scale=1")

            title { page_title }

            csrf_meta_tags
            csp_meta_tag

            stylesheet_link_tag(:app, "data-turbo-track": "reload")

            link(rel: "manifest", href: "/pwa/manifest.json")

            javascript_importmap_tags

            # Early theme initialization to prevent FOUC
            script do
              unsafe_raw <<~JAVASCRIPT
                (function() {
                  try {
                    const THEME_LIGHT = 'light';
                    const THEME_DARK = 'dark';
                    const THEME_SYSTEM = 'system';
                    const STORAGE_KEY = 'theme-preference';
                    
                    // Get stored preference
                    let storedPreference = null;
                    try {
                      storedPreference = localStorage.getItem(STORAGE_KEY);
                    } catch (e) {
                      // localStorage not available
                    }
                    
                    // Determine effective theme
                    let effectiveTheme = THEME_LIGHT; // default
                    
                    if (storedPreference === THEME_LIGHT || storedPreference === THEME_DARK) {
                      effectiveTheme = storedPreference;
                    } else if (storedPreference === THEME_SYSTEM || !storedPreference) {
                      // Use system preference
                      if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
                        effectiveTheme = THEME_DARK;
                      }
                    }
                    
                    // Apply theme class immediately
                    const htmlElement = document.documentElement;
                    htmlElement.classList.remove(THEME_LIGHT, THEME_DARK);
                    
                    if (effectiveTheme === THEME_DARK) {
                      htmlElement.classList.add(THEME_DARK);
                    } else if (effectiveTheme === THEME_LIGHT) {
                      htmlElement.classList.add(THEME_LIGHT);
                    }
                    // System preference with no class allows CSS media queries to work
                  } catch (error) {
                    // Fail silently to prevent breaking page load
                    console.error('Theme initialization failed:', error);
                  }
                })();
              JAVASCRIPT
            end
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
          "bg-success-background text-success-text border border-success"
        when :alert, :error
          "bg-error-background text-error-text border border-error"
        else
          "bg-foreground/5 text-foreground-muted border border-border"
        end
        "#{base_classes} #{type_classes}"
      end
    end
  end
end
