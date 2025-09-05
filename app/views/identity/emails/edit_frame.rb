# frozen_string_literal: true

module Views
  module Identity
    module Emails
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
        turbo_frame_tag "profile_settings" do
          div(class: "p-6 border border-base-300 bg-base-100") do
            header
            notifications
            form_section
          end
        end
      end

      private

      def header
        h3(class: "text-lg font-medium mb-4") { "Email Settings" }
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
        unless Current.user.verified?
          div(class: "alert alert-warning mb-6") do
            p(class: "font-medium") { "Email verification required" }
            p(class: "text-sm") { "We sent a verification email to your address. Check that email and follow the instructions to confirm it's yours." }
          end
        end

        form_with(url: identity_email_path, method: :patch, data: { turbo_frame: "profile_settings" }) do |form|
          form_errors if @user.errors.any?
          form_fields(form)
        end
      end

      def form_errors
        div(class: "alert alert-error mb-4") do
          strong { "#{pluralize(@user.errors.count, "error")} prohibited this change:" }
          ul(class: "mt-2 text-sm list-disc list-inside") do
            @user.errors.each do |error|
              li { error.full_message }
            end
          end
        end
      end

      def form_fields(form)
        div(class: "space-y-4") do
          div do
            render Components::Label.new(for_id: "current_email", text: "Current email")
            div(class: "mt-1 flex items-center gap-2") do
              render Components::Input.new(
                type: "email",
                name: "current_email",
                id: "current_email",
                value: Current.user.email,
                disabled: true
              )
              verification_status
            end
          end

          div do
            render Components::Label.new(for_id: "email", text: "New email")
            div(class: "mt-1") do
              render Components::Input.new(type: "email", name: "email", id: "email", required: true)
            end
          end

          div do
            render Components::Label.new(for_id: "password_challenge", text: "Current password")
            div(class: "mt-1") do
              render Components::Input.new(type: "password", name: "password_challenge", id: "password_challenge", required: true)
            end
          end

          div do
            render Components::Button.new(type: "submit", variant: :primary) do
              "Update Email"
            end
          end
        end
      end

      def verification_status
          if Current.user.verified?
            span(class: "badge badge-success badge-sm") { "✓ Verified" }
          else
            span(class: "badge badge-warning badge-sm") { "⚠ Unverified" }
          end
        end
      end
    end
  end
end
