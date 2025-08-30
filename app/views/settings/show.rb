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
              h1(class: "text-2xl font-bold text-foreground mb-2") { "Settings" }
              p(class: "text-muted") { "Manage your profile, security, and application preferences" }
            end

            div(class: "space-y-8") do
              profile_section
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
