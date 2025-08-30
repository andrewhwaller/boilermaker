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
        page_with_title("Send Invitation") do
          centered_container do
            card do
              h1(class: "text-xl font-bold text-foreground mb-6") { "Send invitation" }

              form_errors(@user) if @user&.errors&.any?

              form_with(url: invitation_path, method: :post, data: { turbo: false }, class: "space-y-4") do |form|
                div do
                  render Components::Label.new(for_id: "email") { "Email address" }
                  render Components::Input.new(type: "email", name: "email", id: "email", required: true, autofocus: true)
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
end
