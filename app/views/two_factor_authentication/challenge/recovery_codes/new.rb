# frozen_string_literal: true

module Views
  module TwoFactorAuthentication
    module Challenge
      module RecoveryCodes
        class New < Views::Base
          include Phlex::Rails::Helpers::FormWith

          def initialize(alert: nil)
            @alert = alert
          end

          def view_template
            if @alert.present?
              p(style: "color: red") { @alert }
            end

            form_with(url: two_factor_authentication_challenge_recovery_codes_path) do |form|
              div do
                form.label(:code) do
                  h1 { "OK, enter one of your recovery codes below:" }
                end
                form.text_field(:code, 
                  autofocus: true, 
                  required: true, 
                  autocomplete: :off
                )
              end

              div do
                form.submit("Continue")
              end
            end

            div do
              p { "To access your account, enter one of the recovery codes (e.g., xxxxxxxxxx) you saved when you set up your two-factor authentication device." }
            end
          end

          private

          attr_reader :alert
        end
      end
    end
  end
end
