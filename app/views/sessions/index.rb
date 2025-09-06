module Views
  module Sessions
    class Index < Views::Base
      include Phlex::Rails::Helpers::FormWith
      include Phlex::Rails::Helpers::LinkTo
      include ActionView::Helpers::DateHelper

      def view_template
        div(class: "space-y-6") do
          h1(class: "text-xl font-bold") { "Active sessions" }

          div(class: "space-y-4") do
            h2(class: "text-lg font-semibold") { "Two-Factor Authentication" }

            div(class: "flex items-center justify-between p-4 bg-white shadow rounded-lg") do
              div do
                div(class: "font-medium") { "Status" }
                p(class: "text-sm text-base-content/70") do
                  if Current.user.otp_required_for_sign_in?
                    "enabled"
                  else
                    "not enabled"
                  end
                end
              end

              unless Current.user.otp_required_for_sign_in?
                link_to "Set up two-factor authentication", new_two_factor_authentication_profile_totp_path, class: "button"
              end
            end

            Current.user.sessions.each do |session|
              div(class: "flex items-center justify-between p-4 bg-white shadow rounded-lg") do
                div do
                  div(class: "font-medium") { session.user_agent }
                  div(class: "text-sm text-base-content/70") { "Last active #{time_ago_in_words(session.updated_at)} ago" }
                end

                unless session == Current.session
                  form_with(url: session_path(session), method: :delete) do
                    button(class: "button", variant: :danger) { "Sign out" }
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
