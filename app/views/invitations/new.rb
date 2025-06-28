# frozen_string_literal: true

module Views
  module Invitations
    class New < Views::Base
      include Phlex::Rails::Helpers::FormWith
      include Phlex::Rails::Helpers::Routes

      def initialize(user: nil)
        @user = user
      end

      def view_template
        div(class: "space-y-6") do
          h1(class: "text-xl font-bold") { "Send invitation" }

          form_with(url: invitation_path, method: :post, data: { turbo: false }) do |form|
            div(class: "space-y-6") do
              div do
                render Components::Label.new(for_id: "email", text: "Email address")
                div(class: "mt-1") do
                  render Components::Input.new(type: "email", name: "email", id: "email", required: true, autofocus: true)
                end

                if @user&.errors&.any?
                  div(style: "color: red") do
                    @user.errors.full_messages.each do |message|
                      div { message }
                    end
                  end
                end
              end

              div do
                render Components::Button.new(type: "submit", variant: :primary) do
                  "Send invitation"
                end
              end
            end
          end
        end
      end
    end
  end
end
