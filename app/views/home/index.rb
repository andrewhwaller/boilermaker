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

        div do
          p do
            plain("Signed in as ")
            span { plain(Current.user.email) }
          end

          div(class: "mt-4") do
            link_to("Change password", edit_password_path)
            link_to("Change email address", edit_identity_email_path)
          end

          div(class: "mt-4") do
            button_to("Sign out", session_path(Current.session), method: :delete)
          end
        end
      end
    end
  end
end
