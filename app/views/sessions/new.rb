# frozen_string_literal: true

module Views
  module Sessions
    class New < Views::Base
      include Phlex::Rails::Helpers::FormWith
      include Phlex::Rails::Helpers::LinkTo

      def initialize(email_hint: nil)
        @email_hint = email_hint
      end

      def view_template
        h1(class: "text-xl font-semibold mb-6") { "Sign in" }

        form_with(url: sign_in_path) do |form|
          div(class: "mb-4") do
            form.label(:email, class: "block mb-1 font-medium")
            form.email_field(:email,
              value: @email_hint,
              required: true,
              autofocus: true,
              autocomplete: "email",
              class: "w-full p-2 border border-border bg-input text-foreground"
            )
          end

          div(class: "mb-4") do
            form.label(:password, class: "block mb-1 font-medium")
            form.password_field(:password,
              required: true,
              autocomplete: "current-password",
              class: "w-full p-2 border border-border bg-input text-foreground"
            )
          end

          div(class: "mb-4") do
            render Components::Button.new(type: "submit", variant: :primary) { "Sign in" }
          end
        end

        div(class: "mt-8") do
          link_to("Sign up", sign_up_path, class: "btn-link")
          plain(" | ")
          link_to("Forgot your password?", new_identity_password_reset_path, class: "btn-link")
        end
      end

      private

      attr_reader :email_hint
    end
  end
end
