# frozen_string_literal: true

module Views
  module TwoFactorAuthentication
    module Challenge
      module Totps
        class New < Views::Base
          include Phlex::Rails::Helpers::FormWith
          include Phlex::Rails::Helpers::LinkTo

          def view_template
            if alert
              p(style: "color: red") { plain(alert) }
            end

            form_with(url: two_factor_authentication_challenge_totp_path) do |form|
              div do
                form.label(:code) do
                  h1 { "Next, open the 2FA authenticator app on your phone and type the six digit code below:" }
                end

                form.text_field(:code,
                  autofocus: true,
                  required: true,
                  autocomplete: :off
                )
              end

              div do
                form.submit("Verify")
              end
            end

            div do
              p { strong { "Don't have your phone?" } }
              div do
                link_to(
                  "Use a recovery code to access your account.",
                  new_two_factor_authentication_challenge_recovery_codes_path
                )
              end
            end
          end
        end
      end
    end
  end
end
