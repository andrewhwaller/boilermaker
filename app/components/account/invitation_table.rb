# frozen_string_literal: true

class Components::Account::InvitationTable < Components::Base
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::ButtonTo

  def initialize(invitations:, compact: false)
    @invitations = invitations
    @compact = compact
  end

  def view_template
    if @invitations.any?
      div(class: "overflow-x-auto") do
        table(class: "w-full") do
          thead do
            tr(class: "border-b border-base-300/30") do
              th(class: "text-left py-2 px-3 font-medium uppercase tracking-wide text-base-content/60") { "Email" }
              th(class: "text-right py-2 px-2 font-medium uppercase tracking-wide text-base-content/60") { "Sent" }
              th(class: "text-right py-2 px-2 font-medium uppercase tracking-wide text-base-content/60") { "Actions" }
            end
          end

          tbody do
            @invitations.each do |invitation|
              tr(class: "hover:bg-base-200/30 border-b border-base-300/20") do
                # Email column
                td(class: "py-3 px-3 text-base-content/80") do
                  plain(invitation.email)
                end

                # Sent column
                td(class: "py-3 px-2 text-right font-mono text-base-content/70") { invitation.created_at.strftime("%m/%d/%Y") }

                # Actions column
                td(class: "py-3 px-2 text-right") do
                  div(class: "flex justify-end gap-3") do
                    button_to("RESEND", new_account_invitation_path,
                      params: { email: invitation.email },
                      method: :get,
                      class: "text-success hover:underline cursor-pointer")
                    button_to("CANCEL", account_invitation_path(invitation),
                      method: :delete,
                      class: "text-error hover:underline cursor-pointer",
                      confirm: "Cancel invitation?")
                  end
                end
              end
            end
          end
        end
      end
    else
      div(class: "text-center py-8 bg-base-200 rounded-box") do
        p(class: "text-base-content/70 mb-4") { "No pending invitations." }
      end
    end
  end
end
