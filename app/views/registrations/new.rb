# frozen_string_literal: true

class Views::Registrations::New < Views::Base
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::Pluralize

  def initialize(user:)
    @user = user
  end

  def view_template
    h1(class: "text-xl font-semibold mb-6") { "Sign up" }

    form_with(url: sign_up_path) do |form|
      if @user.errors.any?
        div(class: "text-red-600 dark:text-red-400 mb-4") do
          strong { "#{pluralize(@user.errors.count, "error")} prohibited this user from being saved:" }
          ul(class: "mt-2 pl-6 list-disc") do
            @user.errors.each do |error|
              li { error.full_message }
            end
          end
        end
      end

      div(class: "mb-4") do
        render Components::Label.new(for: "user_email", required: true) { "Email" }
        render Components::Input.new(
          type: :email,
          name: "user[email]",
          id: "user_email",
          value: @user.email,
          required: true,
          autofocus: true,
          autocomplete: "email"
        )
      end

      div(class: "mb-4") do
        render Components::Label.new(for: "user_password", required: true) { "Password" }
        render Components::Input.new(
          type: :password,
          name: "user[password]",
          id: "user_password",
          required: true,
          autocomplete: "new-password"
        )
        div(class: "text-sm text-muted mt-1") { "12 characters minimum." }
      end

      div(class: "mb-4") do
        render Components::Label.new(for: "user_password_confirmation", required: true) { "Password confirmation" }
        render Components::Input.new(
          type: :password,
          name: "user[password_confirmation]",
          id: "user_password_confirmation",
          required: true,
          autocomplete: "new-password"
        )
      end

      div(class: "mb-4") do
        render Components::Button.new(type: "submit") { "Sign up" }
      end
    end

    div(class: "mt-8") do
      link_to "Already have an account? Sign in", sign_in_path, class: "btn-link"
    end
  end

  private

  attr_reader :user
end
