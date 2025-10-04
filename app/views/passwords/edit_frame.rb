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
          div do
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
          div(class: "form-control w-full") do
            render Components::Label.new(for_id: "password_challenge", text: "Current password")
            render Components::Input.new(
              type: "password",
              name: "password_challenge",
              id: "password_challenge",
              required: true,
              autocomplete: "current-password"
            )
          end

          div(class: "form-control w-full") do
            render Components::Label.new(for_id: "password", text: "New password")
            render Components::Input.new(
              type: "password",
              name: "password",
              id: "password",
              required: true,
              autocomplete: "new-password"
            )
            label(class: "label") do
              span(class: "label-text-alt text-sm text-base-content/70") { "12 characters minimum." }
            end
          end

          div(class: "form-control w-full") do
            render Components::Label.new(for_id: "password_confirmation", text: "Confirm new password")
            render Components::Input.new(
              type: "password",
              name: "password_confirmation",
              id: "password_confirmation",
              required: true,
              autocomplete: "new-password"
            )
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
