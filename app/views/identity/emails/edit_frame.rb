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
          div(class: "p-6 border border-border bg-white dark:bg-gray-900") do
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
          div(class: "mb-4 p-3 bg-success-background border border-success text-success-text") do
            @notice
          end
        end

        if @alert
          div(class: "mb-4 p-3 bg-error-background border border-error text-error-text") do
            @alert
          end
        end
      end

      def form_section
        unless Current.user.verified?
          div(class: "mb-6 p-4 bg-warning-background border border-warning") do
            p(class: "text-warning-text mb-2") { "Email verification required" }
            p(class: "text-sm text-warning-text") { "We sent a verification email to your address. Check that email and follow the instructions to confirm it's yours." }
          end
        end

        form_with(url: identity_email_path, method: :patch, data: { turbo_frame: "profile_settings" }) do |form|
          form_errors if @user.errors.any?
          form_fields(form)
        end
      end

      def form_errors
        div(class: "mb-4 p-3 bg-error-background border border-error") do
          strong(class: "text-error-text") { "#{pluralize(@user.errors.count, "error")} prohibited this change:" }
          ul(class: "mt-2 text-sm text-error-text list-disc list-inside") do
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
            span(class: "inline-flex items-center px-2 py-1 text-xs font-medium bg-success-background text-success-text border border-success") do
              "✓ Verified"
            end
          else
            span(class: "inline-flex items-center px-2 py-1 text-xs font-medium bg-warning-background text-warning-text border border-warning") do
              "⚠ Unverified"
            end
          end
        end
      end
    end
  end
end
