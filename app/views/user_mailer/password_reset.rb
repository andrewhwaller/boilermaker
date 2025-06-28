module Views
  module UserMailer
    class PasswordReset < Base
      def initialize(user:, signed_id:)
        @user = user
        @signed_id = signed_id
      end

      def view_template
        div do
          h1 { "Reset your password" }

          p { "Someone requested a password reset for your account. If this was you, you can reset your password through the link below:" }

          div(class: "button-container") do
            link_to "Reset Password", edit_identity_password_reset_url(token: @signed_id), class: "button"
          end

          p { "If you didn't request this, you can safely ignore this email. Your password won't be changed until you access the link above and create a new one." }

          footer
        end
      end
    end
  end
end
