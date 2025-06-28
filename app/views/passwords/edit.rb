# frozen_string_literal: true

module Views
  module Passwords
    class Edit < Views::Base
      include Phlex::Rails::Helpers::FormWith
      include Phlex::Rails::Helpers::LinkTo
      include Phlex::Rails::Helpers::Pluralize

      def initialize(user:, alert: nil)
        @user = user
        @alert = alert
      end

      def view_template
        if @alert
          p(style: "color: red") { @alert }
        end

        h1(class: "text-xl font-semibold mb-6") { "Change your password" }

        form_with(url: password_path, method: :patch) do |form|
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
            render Components::Label.new(for_id: "password_challenge", required: true) { "Current password" }
            render Components::Input.new(
              type: "password",
              name: "password_challenge",
              id: "password_challenge",
              required: true,
              autofocus: true,
              autocomplete: "current-password"
            )
          end

          div(class: "mb-4") do
            render Components::Label.new(for_id: "password", required: true) { "New password" }
            render Components::Input.new(
              type: "password",
              name: "password",
              id: "password",
              required: true,
              autocomplete: "new-password"
            )
            div(class: "text-sm text-muted mt-1") { "12 characters minimum." }
          end

          div(class: "mb-4") do
            render Components::Label.new(for_id: "password_confirmation", required: true) { "Confirm new password" }
            render Components::Input.new(
              type: "password",
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

        div(class: "mt-8") do
          link_to("Back", root_path, class: "btn-link")
        end
      end
    end
  end
end
