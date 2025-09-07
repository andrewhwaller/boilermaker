# frozen_string_literal: true

module Views
  module Settings
    class Show < Views::Base
      include Phlex::Rails::Helpers::TurboFrameTag

      def initialize
      end

      def view_template
        page_with_title("Settings") do
          wide_container do
            div(class: "mb-8") do
              h1(class: "text-2xl font-bold text-base-content mb-2") { "Settings" }
              p(class: "text-muted") { "Manage your profile, security, and application preferences" }
            end

            div(class: "space-y-8") do
              profile_section
              theme_section
              security_section
            end
          end
        end
      end

      private

      def profile_section
        section(title: "Profile") do
          p(class: "text-sm text-muted mb-6") { "Manage your email and profile information" }
          turbo_frame_tag "profile_settings" do
            render Views::Identity::Emails::EditFrame.new(user: Current.user)
          end
        end
      end

      def theme_section
        section(title: "Theme Preferences") do
          p(class: "text-sm text-base-content/70 mb-6") { "Choose your preferred theme for the application" }

          div(class: "grid grid-cols-1 md:grid-cols-3 gap-4") do
            # Light Theme Option
            div(class: "border border-base-300 rounded-lg p-4 hover:border-primary transition-colors cursor-pointer",
                data: { action: "click->theme#light" }) do
              div(class: "flex items-center justify-between mb-3") do
                h3(class: "font-medium text-base-content") { "Light" }
                div(class: "w-4 h-4 rounded-full bg-white border-2 border-gray-300")
              end
              p(class: "text-sm text-base-content/70 mb-3") { "Clean, professional light theme" }
              div(class: "flex space-x-1") do
                div(class: "w-4 h-4 bg-white border border-gray-300 rounded")
                div(class: "w-4 h-4 bg-gray-100 border border-gray-300 rounded")
                div(class: "w-4 h-4 bg-gray-200 border border-gray-300 rounded")
              end
            end

            # Dark Theme Option
            div(class: "border border-base-300 rounded-lg p-4 hover:border-primary transition-colors cursor-pointer",
                data: { action: "click->theme#dark" }) do
              div(class: "flex items-center justify-between mb-3") do
                h3(class: "font-medium text-base-content") { "Dark" }
                div(class: "w-4 h-4 rounded-full bg-gray-800 border-2 border-gray-600")
              end
              p(class: "text-sm text-base-content/70 mb-3") { "Sophisticated dark theme" }
              div(class: "flex space-x-1") do
                div(class: "w-4 h-4 bg-gray-900 border border-gray-700 rounded")
                div(class: "w-4 h-4 bg-gray-800 border border-gray-700 rounded")
                div(class: "w-4 h-4 bg-gray-700 border border-gray-600 rounded")
              end
            end

            # System Theme Option
            div(class: "border border-base-300 rounded-lg p-4 hover:border-primary transition-colors cursor-pointer",
                data: { action: "click->theme#system" }) do
              div(class: "flex items-center justify-between mb-3") do
                h3(class: "font-medium text-base-content") { "System" }
                div(class: "w-4 h-4 rounded-full bg-gradient-to-r from-white to-gray-800 border-2 border-gray-400")
              end
              p(class: "text-sm text-base-content/70 mb-3") { "Follow system preference" }
              div(class: "flex space-x-1") do
                div(class: "w-2 h-4 bg-white border border-gray-300 rounded-l")
                div(class: "w-2 h-4 bg-gray-800 border border-gray-700 rounded-r")
              end
            end
          end

          div(class: "mt-4 p-3 bg-base-200 rounded-lg") do
            p(class: "text-sm text-base-content/70") do
              plain "Your theme preference is automatically saved and will persist across browser sessions."
            end
          end
        end
      end

      def security_section
        section(title: "Security") do
          p(class: "text-sm text-muted mb-6") { "Password and authentication settings" }
          turbo_frame_tag "password_settings" do
            render Views::Passwords::EditFrame.new(user: Current.user)
          end
        end
      end
    end
  end
end
