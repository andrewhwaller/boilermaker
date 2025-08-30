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
              p(class: "text-muted mb-4") { plain("Version #{app_version}") }
            end

            # User info section
            card do
              h2(class: "text-xl font-semibold text-foreground mb-4") { "User Information" }
              p(class: "text-muted") { "You are currently signed in as #{Current.user.email}" }
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

            # Sign out section
            card do
              button_to("Sign out", session_path(Current.session), method: :delete,
                class: "bg-destructive text-destructive-foreground hover:bg-destructive/90 disabled:opacity-50")
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
            span(class: "inline-flex items-center px-2 py-1 rounded-full text-xs font-medium #{enabled ? "bg-success/20 text-success" : "bg-muted/20 text-muted"}") do
              enabled ? "Enabled" : "Disabled"
            end
          end
        end
      end
    end
  end
end
