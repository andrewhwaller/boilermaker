# frozen_string_literal: true

module Views
  module Identity
    module PasswordResets
      class Edit < Views::Base
        include Phlex::Rails::Helpers::FormWith
        include Phlex::Rails::Helpers::Pluralize

        def initialize(user:, sid:)
          @user = user
          @sid = sid
        end

        def view_template
          h1(class: "text-xl font-semibold mb-6") { "Reset your password" }

          form_with(url: identity_password_reset_path, method: :patch) do |form|
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

            input(type: "hidden", name: "sid", value: @sid)

            div(class: "mb-4") do
              render Components::Label.new(for_id: "password", required: true) { "New password" }
              render Components::Input.new(
                type: :password,
                name: "password",
                id: "password",
                required: true,
                autofocus: true,
                autocomplete: "new-password"
              )
              div(class: "text-sm text-muted mt-1") { "12 characters minimum." }
            end

            div(class: "mb-4") do
              render Components::Label.new(for_id: "password_confirmation", required: true) { "Confirm new password" }
              render Components::Input.new(
                type: :password,
                name: "password_confirmation",
                id: "password_confirmation",
                required: true,
                autocomplete: "new-password"
              )
            end

            div(class: "mb-4") do
              render Components::Button.new(type: "submit", variant: :primary) { "Save changes" }
            end
          end
        end
      end
    end
  end
end
