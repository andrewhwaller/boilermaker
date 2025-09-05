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
          page_with_title("Reset Password") do
            centered_container do
              card do
                h1(class: "text-xl font-semibold text-base-content mb-6") { "Reset your password" }

                form_errors(@user) if @user.errors.any?

                form_with(url: identity_password_reset_path, method: :patch, class: "space-y-4") do |form|
                  input(type: "hidden", name: "sid", value: @sid)

                  div do
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

                  div do
                    render Components::Label.new(for_id: "password_confirmation", required: true) { "Confirm new password" }
                    render Components::Input.new(
                      type: :password,
                      name: "password_confirmation",
                      id: "password_confirmation",
                      required: true,
                      autocomplete: "new-password"
                    )
                  end

                  div do
                    render Components::Button.new(type: "submit", variant: :primary) { "Save changes" }
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
