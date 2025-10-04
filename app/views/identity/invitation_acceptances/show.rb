# frozen_string_literal: true

module Views
  module Identity
    module InvitationAcceptances
      class Show < Views::Base
        include Phlex::Rails::Helpers::FormWith

        def initialize(user:, sid:)
          @user = user
          @sid = sid
        end

        def view_template
          page_with_title("Accept Invitation") do
            centered_container do
              card do
                if @user.verified?
                  render_existing_user_acceptance
                else
                  render_new_user_setup
                end
              end
            end
          end
        end

        private

        def render_existing_user_acceptance
          h1(class: "text-xl font-semibold text-base-content mb-4") { "You've been invited!" }

          p(class: "text-base-content mb-6") do
            plain "You've been invited to join a new account. Click below to accept the invitation."
          end

          form_with(url: identity_invitation_acceptance_path, method: :patch, class: "space-y-4") do |form|
            input(type: "hidden", name: "sid", value: @sid)

            div do
              render Components::Button.new(type: "submit", variant: :primary) { "Accept Invitation" }
            end
          end

          div(class: "mt-4 text-sm text-base-content/70") do
            plain "Already have an account? "
            a(href: sign_in_path, class: "link link-primary") { "Sign in here" }
          end
        end

        def render_new_user_setup
          h1(class: "text-xl font-semibold text-base-content mb-4") { "Welcome! Set your password" }

          p(class: "text-base-content mb-6") do
            plain "You've been invited to join. Set your password below to get started."
          end

          form_errors(@user) if @user.errors.any?

          form_with(url: identity_invitation_acceptance_path, method: :patch, model: @user, class: "space-y-4") do |form|
            input(type: "hidden", name: "sid", value: @sid)

            div(class: "form-control w-full") do
              render Components::Label.new(for_id: "user_password", required: true) { "Password" }
              render Components::Input.new(
                type: :password,
                name: "user[password]",
                id: "user_password",
                required: true,
                autofocus: true,
                autocomplete: "new-password"
              )
              label(class: "label") do
                span(class: "label-text-alt text-sm text-base-content/70") do
                  plain "Minimum #{Boilermaker.config.password_min_length} characters."
                end
              end
            end

            div(class: "form-control w-full") do
              render Components::Label.new(for_id: "user_password_confirmation", required: true) { "Confirm password" }
              render Components::Input.new(
                type: :password,
                name: "user[password_confirmation]",
                id: "user_password_confirmation",
                required: true,
                autocomplete: "new-password"
              )
            end

            div do
              render Components::Button.new(type: "submit", variant: :primary) { "Set password and join" }
            end
          end
        end
      end
    end
  end
end
