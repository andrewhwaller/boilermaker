# frozen_string_literal: true

module Views
  module TwoFactorAuthentication
    module Profile
      module Totps
        class New < Views::Base
          include Phlex::Rails::Helpers::FormWith
          include Phlex::Rails::Helpers::ButtonTo
          include Phlex::Rails::Helpers::LinkTo
          include Phlex::Rails::Helpers::ImageTag

          def view_template
            if alert
              p(style: "color: red") { plain(alert) }
            end

            if Current.user.otp_required_for_sign_in?
              h1 { "Want to replace your existing 2FA setup?" }

              p { "Your account is already protected with two-factor authentication. You can replace that setup if you want to switch to a new phone or authenticator app." }

              p do
                strong { "Do you want to continue? Your existing 2FA setup will no longer work." }
              end

              button_to(
                "Yes, replace my 2FA setup",
                two_factor_authentication_profile_totp_path,
                method: :patch
              )

              hr
            end

            h1 { "Upgrade your security with 2FA" }

            h2 { "Step 1: Get an Authenticator App" }
            p do
              plain("First, you'll need a 2FA authenticator app on your phone. ")
              strong { "If you already have one, skip to step 2." }
            end
            p do
              strong { "If you don't have one, or you aren't sure, we recommend Microsoft Authenticator" }
              plain(". You can download it free on the Apple App Store for iPhone, or Google Play Store for Android. Please grab your phone, search the store, and install it now.")
            end

            h2 { "Step 2: Scan + Enter the Code" }
            p { "Next, open the authenticator app, tap \"Scan QR code\" or \"+\", and, when it asks, point your phone's camera at this QR code picture below." }

            figure do
              image_tag(@qr_code.as_png(resize_exactly_to: 200).to_data_url)
              figcaption { "Point your camera here" }
            end

            form_with(url: two_factor_authentication_profile_totp_path) do |form|
              div do
                form.label(:code,
                  "After scanning with your camera, the app will generate a six-digit code. Enter it here:",
                  style: "display: block"
                )
                form.text_field(:code,
                  required: true,
                  autofocus: true,
                  autocomplete: :off
                )
              end

              div do
                form.submit("Verify and activate")
              end
            end

            br

            div do
              link_to("Back", root_path)
            end
          end
        end
      end
    end
  end
end
