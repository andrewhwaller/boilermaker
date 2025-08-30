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
            div(class: "space-y-6") do
              h1(class: "text-xl font-bold") { "Set up two-factor authentication" }

              p { "Two-factor authentication adds an extra layer of security to your account. In addition to your password, you'll need to enter a code from your phone to sign in." }

              div(class: "space-y-6") do
                form_with(url: two_factor_authentication_profile_totp_path, class: "space-y-6") do |form|
                  div(class: "space-y-6") do
                    div(class: "space-y-4") do
                      h2(class: "text-lg font-medium") { "1. Scan this QR code with your authenticator app" }

                      figure(class: "flex flex-col items-center space-y-2") do
                        img(src: @qr_code, alt: "QR Code", class: "h-48 w-48")
                        figcaption { "Point your camera here" }
                      end
                    end

                    div(class: "space-y-4") do
                      h2(class: "text-lg font-medium") { "2. Enter the code from your authenticator app" }

                      div(class: "space-y-2") do
                        form.text_field(:code,
                          class: "block w-full rounded-lg border-input-border shadow-sm focus:border-accent focus:ring-accent sm:text-sm",
                          autocomplete: "one-time-code",
                          required: true)
                      end
                    end
                  end

                  div(class: "flex items-center justify-between") do
                    button(class: "button", variant: :primary) { "Enable two-factor authentication" }
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
