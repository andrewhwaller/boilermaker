# frozen_string_literal: true

module Views
  module Home
    class Index < Views::Base
      include Phlex::Rails::Helpers::LinkTo
      include Phlex::Rails::Helpers::ButtonTo

      def initialize(notice: nil)
        @notice = notice
      end

      def view_template
        page_with_title("Dashboard") do
          if @notice
            div(class: "bg-success/10 text-success p-4 rounded-lg mb-6") { plain(@notice) }
          end

          div(class: "space-y-6") do
            # Welcome section
            card do
              h1(class: "text-2xl font-bold text-foreground mb-4") { "Welcome to #{app_name}" }
              p(class: "text-foreground-muted mb-4") { plain("Version #{app_version}") }
            end

            # User info section
            card do
              h2(class: "text-xl font-semibold text-foreground mb-4") { "User Information" }
              p(class: "text-foreground-muted") { "You are currently signed in as #{Current.user.email}" }
            end

            # Theme testing section
            card do
              h2(class: "text-lg font-semibold text-foreground mb-4") { "Theme Controls" }
              p(class: "text-foreground-muted mb-4") { "Test the theme system with these controls:" }
              
              div(class: "flex flex-wrap gap-3 mb-4") do
                button(
                  data: { action: "click->theme#light" },
                  class: "px-4 py-2 bg-button text-button-text border border-button hover:bg-button-hover rounded-lg"
                ) { "Light Theme" }
                
                button(
                  data: { action: "click->theme#dark" },
                  class: "px-4 py-2 bg-button text-button-text border border-button hover:bg-button-hover rounded-lg"
                ) { "Dark Theme" }
                
                button(
                  data: { action: "click->theme#system" },
                  class: "px-4 py-2 bg-button text-button-text border border-button hover:bg-button-hover rounded-lg"
                ) { "System Theme" }
                
                button(
                  data: { action: "click->theme#toggle" },
                  class: "px-4 py-2 bg-accent text-accent-text border border-accent hover:bg-accent-hover rounded-lg"
                ) { "Toggle Theme" }
              end
              
              div(class: "text-sm text-foreground-muted") do
                p { "Current theme info will be updated by the controller" }
                div(id: "theme-debug", class: "mt-2 p-3 bg-surface border border-border rounded-lg font-mono text-xs") do
                  "Theme debug info will appear here"
                end
              end
            end

            # Feature showcase section
            card do
              h2(class: "text-lg font-semibold text-foreground mb-4") { "Available Features" }
              div(class: "grid grid-cols-2 md:grid-cols-3 gap-4") do
                feature_card("Two-Factor Authentication", "two_factor_authentication")
                feature_card("User Invitations", "user_invitations")
                feature_card("Dark Mode", "dark_mode")
                feature_card("Personal Accounts", "personal_accounts")
                feature_card("Multi-Tenant", "multi_tenant")
                feature_card("Notifications", "notifications")
              end
            end

            # Development tools section
            if Rails.env.development?
              card do
                h2(class: "text-lg font-semibold text-foreground mb-4") { "Development Tools" }
                div(class: "space-y-2") do
                  link_to("Component Showcase", components_showcase_path, class: "inline-block text-accent hover:text-accent-hover hover:underline")
                  plain(" - Test all UI components in light and dark themes")
                end
              end
            end

            # Sign out section
            card do
              button_to("Sign out", session_path(Current.session), method: :delete,
                class: "bg-error text-error-text hover:bg-error/90 disabled:opacity-50")
            end
          end
        end
      end

      private

      def feature_card(name, feature_key)
        enabled = feature_enabled?(feature_key)
        card_class = enabled ? "bg-success-background border-success" : "bg-foreground/5 border-border"

        div(class: "p-3 border rounded-lg #{card_class}") do
          div(class: "flex items-center justify-between") do
            span(class: "text-sm font-medium text-foreground") { name }
            span(class: "inline-flex items-center px-2 py-1 rounded-full text-xs font-medium #{enabled ? "bg-success/20 text-success" : "bg-foreground-muted/20 text-foreground-muted"}") do
              enabled ? "Enabled" : "Disabled"
            end
          end
        end
      end
    end
  end
end
