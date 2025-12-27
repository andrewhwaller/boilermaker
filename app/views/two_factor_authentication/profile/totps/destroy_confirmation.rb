module Views
  module TwoFactorAuthentication
    module Profile
      module Totps
        class DestroyConfirmation < Views::Base
          include Phlex::Rails::Helpers::FormWith
          include Phlex::Rails::Helpers::Routes
          include Phlex::Rails::Helpers::LinkTo

          def initialize
          end

          def view_template
            page_with_title("Disable Two-Factor Authentication") do
              div(class: "max-w-xl mx-auto space-y-6") do
                # Warning banner
                div(class: "bg-yellow-50 border border-yellow-200 rounded-lg p-4") do
                  div(class: "flex") do
                    div(class: "flex-shrink-0") do
                      svg(
                        class: "h-5 w-5 text-yellow-400",
                        xmlns: "http://www.w3.org/2000/svg",
                        viewBox: "0 0 20 20",
                        fill: "currentColor"
                      ) do |s|
                        s.path(
                          fill_rule: "evenodd",
                          d: "M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z",
                          clip_rule: "evenodd"
                        )
                      end
                    end
                    div(class: "ml-3") do
                      h3(class: "text-sm font-medium text-yellow-800") do
                        plain "Warning: This will reduce your account security"
                      end
                      div(class: "mt-2 text-sm text-yellow-700") do
                        p do
                          plain "Disabling two-factor authentication will make your account less secure. "
                          plain "Only your password will be required to sign in."
                        end
                      end
                    end
                  end
                end

                # Confirmation instructions
                div do
                  h2(class: "text-lg font-medium text-base-content") do
                    plain "Confirm by entering your current authentication code"
                  end
                  p(class: "mt-1 text-sm text-base-content/60") do
                    plain "Enter the 6-digit code from your authenticator app to confirm you want to disable two-factor authentication."
                  end
                end

                # Confirmation form
                form_with(
                  url: two_factor_authentication_profile_totp_path,
                  method: :delete,
                  class: "space-y-6"
                ) do |form|
                  div(class: "space-y-2") do
                    form.label :code, "Authentication Code", class: "block text-sm font-medium text-base-content"
                    form.text_field :code,
                                    class: "block w-full rounded-lg border-input-border shadow-sm focus:border-accent focus:ring-accent sm:text-sm",
                                    autocomplete: "one-time-code",
                                    required: true,
                                    autofocus: true,
                                    maxlength: 6,
                                    placeholder: "000000"
                  end

                  div(class: "flex items-center justify-between space-x-4") do
                    link_to "Cancel", settings_path, class: "ui-button ui-button-outline"
                    form.submit "Disable Two-Factor Authentication",
                                class: "ui-button ui-button-error"
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
