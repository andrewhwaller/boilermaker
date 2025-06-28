module Views
  module UserMailer
    class InvitationInstructions < Base
      def initialize(user:, signed_id:)
        @user = user
        @signed_id = signed_id
      end

      def view_template
        p { "Hey there," }

        p { "Someone has invited you to the application, you can accept it through the link below." }

        p do
          link_to("Accept invitation", edit_identity_password_reset_url(sid: @signed_id))
        end

        p { "If you don't want to accept the invitation, please ignore this email. Your account won't be created until you access the link above and set your password." }

        footer
      end
    end
  end
end
