# frozen_string_literal: true

module Views
  module TwoFactorAuthentication
    module Profile
      module Totps
        class New < Views::Base
          include Phlex::Rails::Helpers::FormWith
          include Phlex::Rails::Helpers::LinkTo
          include Phlex::Rails::Helpers::ButtonTo
          include Phlex::Rails::Helpers::ImageTag

          def initialize(qr_code:, alert: nil)
            @qr_code = qr_code
            @alert = alert
          end

          def view_template
            if @alert
              p(class: "text-error") { plain(@alert) }
            end

            if Current.user.otp_required_for_sign_in?
              h1(class: "text-xl font-semibold mb-6") { "Want to replace your existing 2FA setup?" }

              p { "Your account is already protected with two-factor authentication. You can replace that setup if you want to switch to a new phone or authenticator app." }

              p do
                strong { "Do you want to continue? Your existing 2FA setup will no longer work." }
              end

              button_to("Yes, replace my 2FA setup",
                two_factor_authentication_profile_totp_path,
                method: :patch,
                class: "mb-8")

              hr
            end

            h1(class: "text-xl font-semibold mb-6") { "Upgrade your security with 2FA" }

            h2(class: "text-lg font-medium mb-4") { "Step 1: Get an Authenticator App" }
            p do
              plain("First, you'll need a 2FA authenticator app on your phone. ")
              strong { "If you already have one, skip to step 2." }
            end
            p do
              strong { "If you don't have one, or you aren't sure, we recommend Microsoft Authenticator" }
              plain(". You can download it free on the Apple App Store for iPhone, or Google Play Store for Android. Please grab your phone, search the store, and install it now.")
            end

            h2(class: "text-lg font-medium mb-4 mt-8") { "Step 2: Scan + Enter the Code" }
            p { "Next, open the authenticator app, tap \"Scan QR code\" or \"+\", and, when it asks, point your phone's camera at this QR code picture below." }

            figure(class: "my-8") do
              img(src: @qr_code.as_png(resize_exactly_to: 200).to_data_url, alt: "2FA QR Code")
              figcaption(class: "text-sm text-muted mt-2") { "Point your camera here" }
            end

            form_with(url: two_factor_authentication_profile_totp_path) do |form|
              div(class: "mb-4") do
                render Components::Label.new(for_id: "code", required: true) do
                  plain("After scanning with your camera, the app will generate a six-digit code. Enter it here:")
                end
                render Components::Input.new(
                  type: :text,
                  name: "code",
                  id: "code",
                  required: true,
                  autofocus: true,
                  autocomplete: :off
                )
              end

              div(class: "mb-4") do
                render Components::Button.new(type: "submit", variant: :primary) { "Verify and activate" }
              end
            end

            div(class: "mt-8") do
              link_to("Back", root_path, class: "btn-link")
            end
          end

          private

          attr_reader :qr_code, :alert
        end
      end
    end
  end
end
