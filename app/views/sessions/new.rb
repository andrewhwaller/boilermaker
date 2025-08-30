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
        page_with_title("Sign in") do
          centered_container do
            FormCard(title: "Sign in") do
              form_with(url: sign_in_path, class: "space-y-4") do |form|
                # Using shared EmailField component
                EmailField(
                  name: :email,
                  value: @email_hint,
                  autofocus: true
                )

                # Using shared PasswordField component
                PasswordField(
                  label_text: "Password",
                  name: :password
                )

                # Using shared SubmitButton component
                SubmitButton("Sign in")
              end

              # Using shared AuthLinks component
              AuthLinks(links: [
                { text: "Sign up", path: sign_up_path },
                { text: "Forgot your password?", path: new_identity_password_reset_path }
              ])
            end
          end
        end
      end

      private

      attr_reader :email_hint
    end
  end
end
