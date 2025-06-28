# frozen_string_literal: true

class Views::Identity::PasswordResets::New < Views::Base
  include Phlex::Rails::Helpers::FormWith

  def initialize(alert: nil)
    @alert = alert
  end

  def view_template
    if @alert
      p(style: "color: red") { @alert }
    end

    h1(class: "text-xl font-semibold mb-6") { "Forgot your password?" }

    form_with(url: identity_password_reset_path) do |form|
      div(class: "mb-4") do
        render Components::Label.new(for: "email", required: true) { "Email" }
        render Components::Input.new(
          type: "email",
          name: "email",
          id: "email",
          required: true,
          autofocus: true,
          autocomplete: "email"
        )
      end

      div(class: "mb-4") do
        render Components::Button.new(type: "submit") { "Send password reset email" }
      end
    end
  end
end
