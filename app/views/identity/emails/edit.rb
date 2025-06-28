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

          if Current.user.verified?
            h1(class: "text-xl font-semibold mb-6") { "Change your email" }
          else
            h1(class: "text-xl font-semibold mb-6") { "Verify your email" }
            p { "We sent a verification email to the address below. Check that email and follow those instructions to confirm it's your email address." }
            p do
              button_to("Re-send verification email",
                identity_email_verification_path)
            end
          end

          form_with(url: identity_email_path, method: :patch) do |form|
            if @user.errors.any?
              div(class: "text-error mb-4") do
                h2 do
                  plain(pluralize(@user.errors.count, "error"))
                  plain(" prohibited this user from being saved:")
                end

                ul(class: "mt-2 pl-6 list-disc") do
                  @user.errors.each do |error|
                    li { plain(error.full_message) }
                  end
                end
              end
            end

            div(class: "mb-4") do
              render Components::Label.new(for_id: "email", required: true) { "New email" }
              render Components::Input.new(
                type: :email,
                name: "email",
                id: "email",
                required: true,
                autofocus: true
              )
            end

            div(class: "mb-4") do
              render Components::Label.new(for_id: "password_challenge", required: true) { "Current password" }
              render Components::Input.new(
                type: :password,
                name: "password_challenge",
                id: "password_challenge",
                required: true,
                autocomplete: "current-password"
              )
            end

            div(class: "mb-4") do
              render Components::Button.new(type: "submit", variant: :primary) { "Save changes" }
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
