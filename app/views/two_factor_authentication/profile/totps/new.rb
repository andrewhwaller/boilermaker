# frozen_string_literal: true

module Views
  module TwoFactorAuthentication
    module Profile
      module Totps
        class New < Views::Base
          include Phlex::Rails::Helpers::FormWith
          include Phlex::Rails::Helpers::Routes
          include Phlex::Rails::Helpers::ImageTag

          def initialize(totp:, qr_code:)
            @totp = totp
            @qr_code = qr_code
          end

          def view_template
            page_with_title("Set up two-factor authentication") do
              div(class: "space-y-6 max-w-xl") do
                FormCard(title: "Set up two-factor authentication", header_color: :primary) do
                  div(class: "space-y-6") do
                    div(class: "space-y-3 text-sm text-base-content/80") do
                      p do
                        plain "Two-factor authentication adds an extra layer of security to your account. "
                        plain "You will need both your password and a code from your authenticator app to sign in."
                      end
                      p { "Follow the steps below to finish setting up two-factor authentication." }
                    end

                    div(class: "space-y-6") do
                      div(class: "space-y-3") do
                        h2(class: "font-semibold text-base-content") { "1. Scan this QR code with your authenticator app." }

                        figure(class: "flex flex-col items-center gap-2") do
                          img(
                            src: @qr_code,
                            alt: "QR code for authenticator app setup",
                            class: "h-48 w-48 rounded-lg border border-base-300 bg-white"
                          )
                          figcaption(class: "text-xs text-base-content/60") { "Open your authenticator app and point your camera here." }
                        end
                      end

                      div(class: "space-y-3") do
                        h2(class: "font-semibold text-base-content") { "2. Enter the code from your authenticator app" }
                        p(class: "text-sm text-base-content/80") { "The code refreshes every 30 seconds, so type it in right away." }
                      end
                    end

                    form_with(url: two_factor_authentication_profile_totp_path, class: "space-y-4") do |form|
                      FormGroup(
                        label_text: "Authenticator code",
                        name: :code,
                        id: "totp_code",
                        input_type: :text,
                        required: true,
                        autocomplete: "one-time-code",
                        inputmode: "numeric",
                        pattern: "[0-9]*",
                        autofocus: true,
                        placeholder: "123456"
                      )

                      SubmitButton("Enable two-factor authentication")
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
