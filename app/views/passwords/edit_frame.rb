# frozen_string_literal: true

module Views
  module Passwords
    class EditFrame < Views::Base
      include Phlex::Rails::Helpers::FormWith
      include Phlex::Rails::Helpers::TurboFrameTag
      include Phlex::Rails::Helpers::Pluralize

      def initialize(user:, alert: nil, notice: nil)
        @user = user
        @alert = alert
        @notice = notice
      end

      def view_template
        turbo_frame_tag "password_settings" do
          card do
            header
            notifications
            form_section
          end
        end
      end

      private

      def header
        h3(class: "text-lg font-medium text-base-content mb-4") { "Password Settings" }
      end

      def notifications
        if @notice
          div(class: "alert alert-success mb-4") { span { @notice } }
        end

        if @alert
          div(class: "alert alert-error mb-4") { span { @alert } }
        end
      end

      def form_section
        form_with(url: password_path, method: :patch, data: { turbo_frame: "password_settings" }) do |form|
          form_errors(@user) if @user.errors.any?
          form_fields(form)
        end
      end

      def form_fields(form)
        div(class: "space-y-4") do
          div do
            render Components::Label.new(for_id: "password_challenge", text: "Current password")
            div(class: "mt-1") do
              render Components::Input.new(
                type: "password",
                name: "password_challenge",
                id: "password_challenge",
                required: true,
                autocomplete: "current-password"
              )
            end
          end

          div do
            render Components::Label.new(for_id: "password", text: "New password")
            div(class: "mt-1") do
              render Components::Input.new(
                type: "password",
                name: "password",
                id: "password",
                required: true,
                autocomplete: "new-password"
              )
            end
            div(class: "text-sm text-base-content/70 mt-1") { "12 characters minimum." }
          end

          div do
            render Components::Label.new(for_id: "password_confirmation", text: "Confirm new password")
            div(class: "mt-1") do
              render Components::Input.new(
                type: "password",
                name: "password_confirmation",
                id: "password_confirmation",
                required: true,
                autocomplete: "new-password"
              )
            end
          end

          div do
            render Components::Button.new(type: "submit", variant: :primary) do
              "Update Password"
            end
          end
        end
      end
    end
  end
end
