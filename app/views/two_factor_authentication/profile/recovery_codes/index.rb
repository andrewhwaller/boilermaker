# frozen_string_literal: true

module Views
  module TwoFactorAuthentication
    module Profile
      module RecoveryCodes
        class Index < Views::Base
          include Phlex::Rails::Helpers::LinkTo
          include Phlex::Rails::Helpers::ButtonTo

          def initialize(recovery_codes:)
            @recovery_codes = recovery_codes
          end

          def view_template
            page_with_title("Two-factor recovery codes") do
              wide_container(class: "max-w-2xl space-y-6") do
                card(class: "space-y-6") do
                  div(class: "space-y-3") do
                    h1(class: "text-xl font-semibold text-base-content") { "Keep these codes safe" }
                    p(class: "text-sm text-base-content/80") do
                      "Recovery codes let you sign in if you lose access to your authenticator app. Store them somewhere secure before leaving this page."
                    end
                  end

                  div(class: "space-y-3") do
                    h2(class: "text-xs font-semibold uppercase tracking-wide text-base-content/60") { "Your recovery codes" }
                    div(class: "rounded-box border border-dashed border-base-300 bg-base-100 p-4") do
                      ul(class: "grid grid-cols-1 gap-3 list-none p-0 m-0 sm:grid-cols-2") do
                        recovery_codes.each do |code|
                          render Components::TwoFactorAuthentication::Profile::RecoveryCodes::RecoveryCode.new(recovery_code: code)
                        end
                      end

                      p(class: "mt-4 text-xs text-base-content/60") do
                        "Each code works only once. Consider printing this page or saving the codes in a password manager."
                      end
                    end
                  end

                  div(class: "flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between") do
                    span(class: "text-sm text-base-content/70") { "Finished copying them? You can head back to the dashboard." }
                    link_to("OK, I'm done", root_path, class: "btn btn-secondary w-full sm:w-auto")
                  end
                end

                card(class: "space-y-4") do
                  h2(class: "text-lg font-semibold text-base-content") { "Need new recovery codes?" }
                  p(class: "text-sm text-base-content/80") do
                    "Generate a fresh set if you suspect these codes have been compromised. Your current codes will stop working immediately."
                  end

                  button_to(
                    "Generate new recovery codes",
                    two_factor_authentication_profile_recovery_codes_path,
                    method: :post,
                    class: "btn btn-primary w-full sm:w-auto",
                    data: { turbo_confirm: "Generate a new set of recovery codes? Your current codes will stop working." }
                  )
                end
              end
            end
          end

          private

          attr_reader :recovery_codes
        end
      end
    end
  end
end
