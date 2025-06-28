module Views
  module UserMailer
    class PasswordReset < Base
      def initialize(user:, signed_id:)
        @user = user
        @signed_id = signed_id
      end

      def view_template
        p { "Hey there," }

        p do
          plain("Can't remember your password for ")
          strong { plain(@user.email) }
          plain("? That's OK, it happens. Just hit the link below to set a new one.")
        end

        p do
          link_to("Reset my password", edit_identity_password_reset_url(sid: @signed_id))
        end

        p { "If you did not request a password reset you can safely ignore this email, it expires in 20 minutes. Only someone with access to this email account can reset your password." }

        footer
      end
    end
  end
end
