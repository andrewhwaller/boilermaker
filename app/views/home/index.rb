# frozen_string_literal: true

module Views
  module Home
    class Index < Views::Base
      include Phlex::Rails::Helpers::LinkTo
      include Phlex::Rails::Helpers::ButtonTo

      def initialize(notice: nil)
        @notice = notice
      end

      def view_template
        if @notice
          p(class: "text-success mb-4") { plain(@notice) }
        end

        div(class: "space-y-8") do
          # User info section
          div(class: "bg-surface-alt rounded-lg p-6") do
            p(class: "text-lg") do
              plain("Signed in as ")
              span(class: "font-semibold") { plain(Current.user.email) }
            end
          end

          # Account management section
          div(class: "bg-surface-alt rounded-lg p-6") do
            h2(class: "text-xl font-semibold mb-4") { "Account Management" }

            div(class: "space-y-3") do
              div do
                link_to("Change password", edit_password_path,
                  class: "text-primary hover:text-primary-hover transition-colors")
              end

              div do
                link_to("Change email address", edit_identity_email_path,
                  class: "text-primary hover:text-primary-hover transition-colors")
              end
            end
          end

          # Sign out button
          div(class: "mt-8") do
                        button_to("Sign out", session_path(Current.session),
              method: :delete,
              class: "btn btn-error")
          end
        end
      end
    end
  end
end
