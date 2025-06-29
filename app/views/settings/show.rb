# frozen_string_literal: true

module Views
  module Settings
    class Show < Views::Base
      include Phlex::Rails::Helpers::TurboFrameTag

      def initialize
      end

      def view_template
        div(class: "max-w-4xl mx-auto p-6") do
          header
          sections
        end
      end

      private

      def header
        div(class: "mb-8") do
          h1(class: "text-2xl font-bold text-foreground mb-2") { "Settings" }
          p(class: "text-muted-foreground") { "Manage your profile, security, and application preferences" }
        end
      end

      def sections
        div(class: "space-y-8") do
          profile_section
          security_section
        end
      end

      def profile_section
        section do
          section_header("Profile", "Manage your email and profile information")
          turbo_frame_tag "profile_settings" do
            render Views::Identity::Emails::EditFrame.new(user: Current.user)
          end
        end
      end

      def security_section
        section do
          section_header("Security", "Password and authentication settings")
          turbo_frame_tag "password_settings" do
            render Views::Passwords::EditFrame.new(user: Current.user)
          end
        end
      end

      def section_header(title, description)
        div(class: "mb-6") do
          h2(class: "text-xl font-semibold text-foreground mb-1") { title }
          p(class: "text-sm text-muted-foreground") { description }
        end
      end
    end
  end
end