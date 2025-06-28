module Views
  module UserMailer
    class EmailVerification < Base
      def initialize(user:, signed_id:)
        @user = user
        @signed_id = signed_id
      end

      def view_template
        p { "Hey there," }

        p do
          plain("This is to confirm that ")
          plain(@user.email)
          plain(" is the email you want to use on your account. If you ever lose your password, that's where we'll email a reset link.")
        end

        p do
          strong { "You must hit the link below to confirm that you received this email." }
        end

        p do
          link_to("Yes, use this email for my account", identity_email_verification_url(sid: @signed_id))
        end

        footer
      end
    end
  end
end
