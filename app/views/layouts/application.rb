# frozen_string_literal: true

module Views
  module Layouts
    class Application < Phlex::HTML
      include Components
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
            theme: Current.theme_name || ::Boilermaker::Config.theme_name,
            polarity: Current.polarity || ::Boilermaker::Themes.default_polarity_for(Current.theme_name)
          }
        ) do
          head do
            meta(charset: "utf-8")
            meta(name: "viewport", content: "width=device-width,initial-scale=1")

            title { page_title }

            csrf_meta_tags
            csp_meta_tag

            link(rel: "icon", type: "image/svg+xml", href: "/favicon.svg")

            stylesheet_link_tag(:app, "data-turbo-track": "reload")

            raw app_font_style_tag

            raw font_stylesheet_link_tag

            link(rel: "manifest", href: "/pwa/manifest.json")

            javascript_importmap_tags
          end

          body(class: body_classes) do
            render Components::ImpersonationBanner.new
            render_navigation if Current.user.present?

            div(class: content_wrapper_classes) do
              render_flash_messages unless flash.empty?

              main(class: main_content_classes) do
                yield_content_or(&block)
              end
            end

            render_theme_components if Current.user.present?
          end
        end
      end

      def page_title
        content_for?(:title) ? content_for(:title) : "Boilermaker"
      end

      private

      def sidebar_layout?
        ::Boilermaker.config.get("ui.navigation.layout_mode") == "sidebar"
      end

      def authenticated_with_sidebar?
        Current.user.present? && sidebar_layout?
      end

      def render_navigation
        if sidebar_layout?
          render Components::SidebarNavigation.new(request: view_context.request)
        else
          render Components::Navigation.new(request: view_context.request)
        end
      end

      def body_classes
        base = "min-h-screen bg-surface text-body theme-transition"
        base = "#{base} pl-64" if authenticated_with_sidebar?
        base = "#{base} pb-12" if has_bottom_bar?
        base
      end

      def content_wrapper_classes
        authenticated_with_sidebar? ? "min-h-screen" : ""
      end

      def flash_container_classes
        if authenticated_with_sidebar?
          "px-8 pt-4 space-y-2"
        else
          "max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 mt-4 space-y-2"
        end
      end

      def main_content_classes
        if authenticated_with_sidebar?
          "px-8 py-8"
        else
          "max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8"
        end
      end

      def render_flash_messages
        div(class: flash_container_classes) do
          flash.each do |type, message|
            variant = case type.to_sym
            when :notice, :success then :success
            when :alert, :error then :error
            else :info
            end
            render Alert.new(message: message, variant: variant)
          end
        end
      end

      def yield_content_or(&block)
        block_given? ? yield : content_for(:content)
      end

      def render_theme_components
        theme = Current.theme_name || Boilermaker::Config.theme_name

        case theme
        when "terminal"
          render Components::Terminal::CommandBar.new
        when "amber"
          render Components::Amber::FnBar.new
        end
      end

      def has_bottom_bar?
        theme = Current.theme_name || Boilermaker::Config.theme_name
        %w[terminal amber].include?(theme)
      end
    end
  end
end
