# frozen_string_literal: true

module Views
  module Settings
    class Show < Views::Base
      include Phlex::Rails::Helpers::TurboFrameTag
      include Phlex::Rails::Helpers::LinkTo
      include ActionView::Helpers::DateHelper

      def initialize
      end

      def view_template
        page_with_title("Settings") do
          div(class: "flex items-start justify-between mb-4") do
            h1(class: "font-bold text-base-content") { "User Settings" }
          end

          div(class: "max-w-xl space-y-6") do
            render Components::Card.new(title: "Email", header_color: :primary) do
              turbo_frame_tag "profile_settings", class: "block" do
                render Views::Identity::Emails::EditFrame.new(user: Current.user)
              end
            end

            render Components::Card.new(title: "Password", header_color: :primary) do
              turbo_frame_tag "password_settings", class: "block" do
                render Views::Passwords::EditFrame.new(user: Current.user)
              end
            end

            render Components::Card.new(title: "Two-Factor Authentication", header_color: :primary) do
              div(class: "space-y-4") do
                render_two_factor_status
                render_two_factor_actions
              end
            end
          end
        end
      end

      private

        def render_two_factor_status
          div(class: "space-y-2") do
            if Current.user.otp_required_for_sign_in?
              div(class: "flex items-center gap-2") do
                if Boilermaker.config.require_two_factor_authentication?
                  render Components::Badge.new(variant: :warning, size: :sm, style: :outline) { "Required" }
                end
              end
              p(class: "text-sm text-base-content/80") do
                plain "Your account is protected with two-factor authentication. "
                plain "You will need to enter a code from your authenticator app when signing in."
              end
            else
              div(class: "flex items-center gap-2") do
                if Boilermaker.config.require_two_factor_authentication?
                  render Components::Badge.new(variant: :warning, size: :sm) { "Setup required" }
                end
              end
              p(class: "text-sm text-base-content/80") do
                plain "Two-factor authentication adds an extra layer of security to your account."
              end
            end
          end
        end

        def render_two_factor_actions
          div(class: "flex flex-col space-y-2") do
            if Current.user.otp_required_for_sign_in?
              div do
                link_to "View Recovery Codes",
                        two_factor_authentication_profile_recovery_codes_path,
                        class: "btn btn-outline"
              end

              unless Boilermaker.config.require_two_factor_authentication?
                div do
                  link_to "Disable Two-Factor Authentication",
                          destroy_confirmation_two_factor_authentication_profile_totp_path,
                          class: "btn btn-outline btn-error"
                end
              end
            else
              div do
                link_to "Enable Two-Factor Authentication",
                        new_two_factor_authentication_profile_totp_path,
                        class: "btn btn-primary"
              end
            end
          end
        end
    end
  end
end
