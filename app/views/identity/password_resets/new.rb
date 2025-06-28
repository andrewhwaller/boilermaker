# frozen_string_literal: true

module Views
  module Identity
    module PasswordResets
      class New < Views::Base
        include Phlex::Rails::Helpers::FormWith

        def initialize(alert: nil)
          @alert = alert
        end

        def view_template
          if @alert
            p(class: "text-error") { plain(@alert) }
          end

          h1(class: "text-xl font-semibold mb-6") { "Forgot your password?" }

          form_with(url: identity_password_reset_path) do |form|
            div(class: "mb-4") do
              render Components::Label.new(for_id: "email", required: true) { "Email" }
              render Components::Input.new(
                type: :email,
                name: "email",
                id: "email",
                required: true,
                autofocus: true
              )
            end

            div(class: "mb-4") do
              render Components::Button.new(type: "submit", variant: :primary) { "Send password reset email" }
            end
          end
        end
      end
    end
  end
end
