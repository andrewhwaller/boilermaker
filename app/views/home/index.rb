# frozen_string_literal: true

module Views
  module Home
    class Index < Views::Base
      include Phlex::Rails::Helpers::LinkTo

      def initialize
      end

      def view_template
        page_with_title("Dashboard") do
          div(class: "max-w-3xl space-y-8") do
            header_section
            quick_links_section
            account_section
            features_section
            dev_tools_section if Rails.env.development?
          end
        end
      end

      private

      def header_section
        div do
          h1 { app_name }
          p(class: "text-muted text-sm mt-1") do
            span { "v#{app_version}" }
            span(class: "mx-2") { "\u00B7" }
            span { Current.user.email }
          end
        end
      end

      def quick_links_section
        div(class: "flex flex-wrap gap-2") do
          link_to("Settings", settings_path, class: "ui-button ui-button-outline ui-button-sm")

          if Current.account && Current.user&.account_admin_for?(Current.account)
            link_to("Account", account_dashboard_path, class: "ui-button ui-button-outline ui-button-sm")
          end

          if Current.user&.app_admin?
            link_to("Admin", admin_path, class: "ui-button ui-button-outline ui-button-sm")
          end

          if feature_enabled?("two_factor_authentication") && !Current.user.otp_required_for_sign_in?
            link_to("Set up 2FA", new_two_factor_authentication_profile_totp_path, class: "ui-button ui-button-primary ui-button-sm")
          end
        end
      end

      def account_section
        return unless Current.account

        card(title: "Account") do
          div(class: "grid grid-cols-2 gap-4 text-sm") do
            div do
              div(class: "text-muted") { "Name" }
              div(class: "font-medium") { Current.account.name }
            end

            div do
              div(class: "text-muted") { "Members" }
              div(class: "font-medium") { Current.account.members.count.to_s }
            end
          end
        end
      end

      def features_section
        card(title: "Features") do
          div(class: "grid grid-cols-2 md:grid-cols-3 gap-3") do
            feature_item("Two-Factor Auth", "two_factor_authentication")
            feature_item("Invitations", "user_invitations")
            feature_item("Dark Mode", "dark_mode")
            feature_item("Personal Accounts", "personal_accounts")
            feature_item("Notifications", "notifications")
          end
        end
      end

      def dev_tools_section
        card(title: "Development") do
          div(class: "flex flex-wrap gap-2") do
            link_to("Component Showcase", components_showcase_path, class: "ui-button ui-button-outline ui-button-sm")
            link_to("Config", boilermaker.edit_settings_path, class: "ui-button ui-button-outline ui-button-sm")
          end
        end
      end

      def feature_item(name, feature_key)
        enabled = feature_enabled?(feature_key)

        div(class: "flex items-center justify-between py-2 px-3 rounded-box border border-line text-sm") do
          span { name }
          if enabled
            span(class: "ui-badge ui-badge-success ui-badge-xs") { "On" }
          else
            span(class: "text-muted text-xs") { "Off" }
          end
        end
      end
    end
  end
end
