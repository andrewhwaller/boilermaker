module Views
  module UserMailer
    class InvitationInstructions < Base
      def initialize(user:, signed_id:)
        @user = user
        @signed_id = signed_id
      end

      def view_template
        div do
          h1 { "Welcome to #{Current.account.name}!" }

          p { "You've been invited to join #{Current.account.name}. To get started, you'll need to set up your password." }

          div(class: "button-container") do
            link_to "Set Your Password", edit_identity_password_reset_url(sid: @signed_id), class: "button"
          end

          p { "If you didn't request this invitation, you can safely ignore this email." }

          footer
        end
      end
    end
  end
end
