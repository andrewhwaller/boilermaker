# frozen_string_literal: true

module Views
  module TwoFactorAuthentication
    module Profile
      module RecoveryCodes
        class Index < Views::Base
          include Phlex::Rails::Helpers::LinkTo
          include Phlex::Rails::Helpers::ButtonTo

          def view_template
            if notice
              p(style: "color: green") { plain(notice) }
            end

            h1 { "Two-factor recovery codes" }
            p { "Recovery codes provide a way to log in if you lose your phone (or don't have it with you). Save these and keep them somewhere safe." }

            ul do
              @recovery_codes.each do |code|
                render Components::TwoFactorAuthentication::Profile::RecoveryCodes::RecoveryCode.new(recovery_code: code)
              end
            end

            div do
              link_to("OK, I'm done", root_path)
            end

            hr

            h2 { "Need new recovery codes?" }

            p { "If you think your codes have fallen into the wrong hands, you can get a new set. Be sure to save the new ones because the old codes will stop working." }

            button_to(
              "Generate new recovery codes",
              two_factor_authentication_profile_recovery_codes_path)
          end
        end
      end
    end
  end
end
