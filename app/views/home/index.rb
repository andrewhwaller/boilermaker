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
        # Set the page title
        set_title("Dashboard")

        if @notice
          p(class: "text-success mb-4") { plain(@notice) }
        end

        div(class: "space-y-6") do
          # Welcome section
          div(class: "bg-white rounded-lg shadow p-6") do
            h1(class: "text-2xl font-bold mb-4") { "Welcome to #{app_name}" }
            p(class: "text-gray-600 mb-4") { plain("Version #{app_version}") }
          end

          # User info section
          div(class: "bg-white rounded-lg shadow p-6") do
            h2(class: "text-xl font-semibold mb-4") { "User Information" }
            p(class: "text-gray-600") { "You are currently signed in as #{Current.user.email}" }
          end

          # Feature showcase section
          div(class: "bg-white rounded-lg shadow p-6") do
            h2(class: "text-lg font-semibold mb-4") { "Available Features" }
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
          div(class: "bg-white rounded-lg shadow p-6") do
            button_to("Sign out", session_path(Current.session), method: :delete,
                     class: "bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700")
          end
        end
      end

      private

      def feature_card(name, feature_key)
        enabled = feature_enabled?(feature_key)
        div(class: "p-3 border rounded-lg #{enabled ? 'bg-green-50 border-green-200' : 'bg-gray-50 border-gray-200'}") do
          div(class: "flex items-center justify-between") do
            span(class: "text-sm font-medium") { name }
            span(class: "inline-flex items-center px-2 py-1 rounded-full text-xs font-medium #{enabled ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'}") do
              enabled ? "Enabled" : "Disabled"
            end
          end
        end
      end
    end
  end
end
