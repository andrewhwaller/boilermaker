# frozen_string_literal: true

class Views::Passwords::Edit < Views::Base
  include Phlex::Rails::Helpers::FormWith

  def initialize(user:, alert: nil)
    @user = user
    @alert = alert
  end

  def view_template
    page_with_title("Change Password") do
      centered_container do
        card do
          if @alert
            div(class: "ui-alert ui-alert-destructive mb-6") { span { plain(@alert) } }
          end

          h1(class: "text-xl font-semibold text-base-content mb-6") { "Change your password" }

          form_errors(@user) if @user.errors.any?

          form_with(url: password_path, method: :patch, class: "space-y-4") do |form|
            div(class: "form-control w-full") do
              render Components::Label.new(for_id: "password_challenge", required: true) { "Current password" }
              render Components::Input.new(
                type: :password,
                name: "password_challenge",
                id: "password_challenge",
                required: true,
                autofocus: true,
                autocomplete: "current-password"
              )
            end

            div(class: "form-control w-full") do
              render Components::Label.new(for_id: "password", required: true) { "New password" }
              render Components::Input.new(
                type: :password,
                name: "password",
                id: "password",
                required: true,
                autocomplete: "new-password"
              )
              label(class: "label") do
                span(class: "label-text-alt text-sm text-base-content/70") { "12 characters minimum." }
              end
            end

            div(class: "form-control w-full") do
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

          div(class: "mt-6 text-center") do
            link_to("Back", root_path, class: "text-primary hover:underline")
          end
        end
      end
    end
  end

  private

  attr_reader :user, :alert
end
