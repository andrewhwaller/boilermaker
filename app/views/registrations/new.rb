# frozen_string_literal: true

module Views
  module Registrations
    class New < Views::Base
      include Phlex::Rails::Helpers::FormWith
      include Phlex::Rails::Helpers::LinkTo
      include Phlex::Rails::Helpers::Pluralize

      def initialize(user:)
        @user = user
      end

      def view_template
        page_with_title("Sign up") do
          centered_container do
            card do
              h1(class: "text-xl font-semibold text-base-content mb-6") { "Sign up" }

              form_errors(@user) if @user.errors.any?

              form_with(url: sign_up_path, class: "space-y-4") do |form|
                # Using shared EmailField component
                EmailField(
                  name: "user[email]",
                  id: "user_email",
                  value: @user.email,
                  autofocus: true
                )

                # Using shared PasswordField component with help text
                PasswordField(
                  label_text: "Password",
                  name: "user[password]",
                  id: "user_password",
                  help_text: "12 characters minimum."
                )

                # Using shared PasswordField component for confirmation
                PasswordField(
                  label_text: "Password confirmation",
                  name: "user[password_confirmation]",
                  id: "user_password_confirmation"
                )

                # Using shared SubmitButton component
                SubmitButton("Sign up")
              end

              # Using shared AuthLinks component
              AuthLinks(links: [
                { text: "Already have an account? Sign in", path: sign_in_path }
              ])
            end
          end
        end
      end

      private

      attr_reader :user
    end
  end
end
