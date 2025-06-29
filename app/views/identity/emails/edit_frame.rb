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
          div(class: "p-6 border border-border bg-background") do
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
          div(class: "mb-4 p-3 bg-green-50 border border-green-200 text-green-800") do
            @notice
          end
        end

        if @alert
          div(class: "mb-4 p-3 bg-red-50 border border-red-200 text-red-800") do
            @alert
          end
        end
      end

      def form_section
        unless Current.user.verified?
          div(class: "mb-6 p-4 bg-yellow-50 border border-yellow-200") do
            p(class: "text-yellow-800 mb-2") { "Email verification required" }
            p(class: "text-sm text-yellow-700") { "We sent a verification email to your address. Check that email and follow the instructions to confirm it's yours." }
          end
        end

        form_with(url: identity_email_path, method: :patch, data: { turbo_frame: "profile_settings" }) do |form|
          form_errors if @user.errors.any?
          form_fields(form)
        end
      end

      def form_errors
        div(class: "mb-4 p-3 bg-red-50 border border-red-200") do
          strong(class: "text-red-800") { "#{pluralize(@user.errors.count, "error")} prohibited this change:" }
          ul(class: "mt-2 text-sm text-red-700 list-disc list-inside") do
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
            span(class: "inline-flex items-center px-2 py-1 text-xs font-medium bg-green-100 text-green-800 border border-green-200") do
              "✓ Verified"
            end
          else
            span(class: "inline-flex items-center px-2 py-1 text-xs font-medium bg-yellow-100 text-yellow-800 border border-yellow-200") do
              "⚠ Unverified"
            end
          end
        end
      end
    end
  end
end
