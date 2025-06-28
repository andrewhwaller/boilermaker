module Views
  module UserMailer
    class EmailVerification < Base
      def initialize(user:, signed_id:)
        @user = user
        @signed_id = signed_id
      end

      def view_template
        div do
          h1 { "Verify your email" }
          
          p { "Thanks for signing up! Please verify your email address by clicking the link below:" }
          
          div(class: "button-container") do
            link_to "Verify Email", identity_email_verification_url(token: @signed_id), class: "button"
          end
          
          p { "If you didn't create an account, you can safely ignore this email." }

          footer
        end
      end
    end
  end
end
