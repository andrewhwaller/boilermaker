# frozen_string_literal: true

class Views::Sessions::New < Views::Base
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::LinkTo

  def initialize(email_hint: nil)
    @email_hint = email_hint
  end

  def view_template
    h1(class: "text-xl font-semibold mb-6") { "Sign in" }

    form_with(url: sign_in_path) do |form|
      div(class: "mb-4") do
        render Components::Label.new(for: "email") { "Email" }
        render Components::Input.new(
          type: "email",
          name: "email",
          id: "email",
          value: @email_hint,
          required: true,
          autofocus: true,
          autocomplete: "email"
        )
      end

      div(class: "mb-4") do
        render Components::Label.new(for: "password") { "Password" }
        render Components::Input.new(
          type: "password",
          name: "password",
          id: "password",
          required: true,
          autocomplete: "current-password"
        )
      end

      div(class: "mb-4") do
        render Components::Button.new(type: "submit") { "Sign in" }
      end
    end

    div(class: "mt-8") do
      link_to("Sign up", sign_up_path, class: "btn-link")
      plain " | "
      link_to("Forgot your password?", new_identity_password_reset_path, class: "btn-link")
    end
  end
end
