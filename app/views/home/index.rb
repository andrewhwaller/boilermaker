# frozen_string_literal: true

module Views
  module Home
    class Index < Views::Base
      include Phlex::Rails::Helpers::LinkTo
      include Phlex::Rails::Helpers::ButtonTo

      def initialize
      end

      def view_template
        page_with_title("Dashboard") do
          div(class: "space-y-6") do
            # Welcome section
            card do
              h1(class: "font-bold text-base-content mb-4") { "Welcome to #{app_name}" }
              p(class: "text-base-content/70 mb-4") { plain("Version #{app_version}") }
            end

            # User info section
            card do
              h2(class: "font-semibold text-base-content mb-4") { "User Information" }
              p(class: "text-base-content/70") { "You are currently signed in as #{Current.user.email}" }
            end

            # Theme testing section
            card do
              h2(class: "font-semibold text-base-content mb-4") { "Theme Controls" }
              p(class: "text-base-content/70 mb-4") { "Test the theme system with these controls:" }

              div(class: "flex flex-wrap gap-2 mb-4") do
                button(
                  data: { action: "click->theme#light" },
                  class: "ui-button ui-button-outline"
                ) { "Light Theme" }

                button(
                  data: { action: "click->theme#dark" },
                  class: "ui-button ui-button-outline"
                ) { "Dark Theme" }

                button(
                  data: { action: "click->theme#system" },
                  class: "ui-button ui-button-outline"
                ) { "System Theme" }

                button(
                  data: { action: "click->theme#toggle" },
                  class: "ui-button ui-button-accent"
                ) { "Toggle Theme" }
              end

              div(class: "text-sm text-base-content/70") do
                p { "Test the theme system by clicking the buttons above or using the theme toggle in the navigation bar." }
              end
            end

            # Feature showcase section
            card do
              h2(class: "font-semibold text-base-content mb-4") { "Available Features" }
              div(class: "grid grid-cols-2 md:grid-cols-3 gap-4") do
                feature_card("Two-Factor Authentication", "two_factor_authentication")
                feature_card("User Invitations", "user_invitations")
                feature_card("Dark Mode", "dark_mode")
                feature_card("Personal Accounts", "personal_accounts")
                feature_card("Notifications", "notifications")
              end
            end

            # Development tools section
            if Rails.env.development?
              card do
                h2(class: "font-semibold text-base-content mb-4") { "Development Tools" }
                div(class: "space-y-2") do
                  link_to("Component Showcase", components_showcase_path, class: "link link-primary")
                  plain(" - Test all UI components in light and dark themes")
                end
              end
            end

            # Sign out section
            card do
              button_to("Sign out", session_path("current"), method: :delete,
                class: "ui-button ui-button-error")
            end
          end
        end
      end

      private

      def feature_card(name, feature_key)
        enabled = feature_enabled?(feature_key)
        box_classes = "border border-base-300 bg-base-100"

        div(class: "p-3 rounded-box #{box_classes}") do
          div(class: "flex items-center justify-between") do
            span(class: "text-sm font-medium text-base-content") { name }
            span(class: "ui-badge #{enabled ? 'ui-badge-success' : 'ui-badge-ghost'} ui-badge-sm") do
              enabled ? "Enabled" : "Disabled"
            end
          end
        end
      end
    end
  end
end
