# frozen_string_literal: true

module Views
  module Identity
    module Emails
      class Edit < Views::Base
        include Phlex::Rails::Helpers::FormWith
        include Phlex::Rails::Helpers::LinkTo
        include Phlex::Rails::Helpers::ButtonTo
        include Phlex::Rails::Helpers::Pluralize

        def initialize(user:, alert: nil)
          @user = user
          @alert = alert
        end

        def view_template
          if @alert
            p(class: "text-error") { plain(@alert) }
          end

          h1(class: "text-xl font-semibold mb-6") do
            if Current.user.verified?
              plain("Change your email")
            else
              plain("Verify your email")
            end
          end

          unless Current.user.verified?
            p { "We sent a verification email to the address below. Check that email and follow those instructions to confirm it's your email address." }
            p do
              render Components::Button.new(type: "submit", variant: :primary) do
                "Re-send verification email"
              end
            end
          end

          form_with(url: identity_email_path, method: :patch, data: { turbo: false }) do |form|
            if @user.errors.any?
              div(class: "text-red-600 dark:text-red-400 mb-4") do
                strong { "#{pluralize(@user.errors.count, "error")} prohibited this change from being saved:" }
                ul(class: "mt-2 pl-6 list-disc") do
                  @user.errors.each do |error|
                    li { error.full_message }
                  end
                end
              end
            end

            div(class: "space-y-6") do
              div do
                render Components::Label.new(for_id: "current_email", text: "Current email")
                div(class: "mt-1") do
                  render Components::Input.new(type: "email", name: "current_email", id: "current_email", value: Current.user.email, disabled: true)
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
                  "Change email"
                end
              end
            end
          end

          div(class: "mt-8") do
            link_to("Back", root_path, class: "btn-link")
          end
        end
      end
    end
  end
end
