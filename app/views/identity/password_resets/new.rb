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
          page_with_title("Reset Password") do
            centered_container do
              card do
          if @alert
            div(class: "alert alert-error mb-6") { span { plain(@alert) } }
          end

                h1(class: "text-xl font-semibold text-base-content mb-6") { "Forgot your password?" }

                form_with(url: identity_password_reset_path, class: "space-y-4") do |form|
                  div do
                    render Components::Label.new(for_id: "email", required: true) { "Email" }
                    render Components::Input.new(
                      type: :email,
                      name: "email",
                      id: "email",
                      required: true,
                      autofocus: true
                    )
                  end

                  div do
                    render Components::Button.new(type: "submit", variant: :primary) { "Send password reset email" }
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
