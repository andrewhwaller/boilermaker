# frozen_string_literal: true

class Components::Account::InvitationTable < Components::Base
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::ButtonTo

  def initialize(invitations:, compact: false)
    @invitations = invitations
    @compact = compact
  end

  def view_template
    div(class: "flex items-center justify-between mb-2") do
      h2(class: "font-semibold text-base-content uppercase") { "Pending Invitations" }
    end

    if @invitations.any?
      Table(variant: :zebra, size: @compact ? :xs : :sm) do
        thead do
          tr do
            th { "Email" }
            th(class: "text-right") { "Sent" }
            th(class: "text-right") { "Actions" }
          end
        end

        tbody do
          @invitations.each do |invitation|
            tr do
              td { invitation.email }
              td(class: "text-right font-mono text-base-content/70") { formatted_date(invitation.created_at) }
              td(class: "text-right") do
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
    else
      div(class: "text-center py-3 bg-base-200 rounded-box") do
        p(class: "text-base-content/70 uppercase") { "None Found" }
      end
    end
  end

  private

  def formatted_date(value)
    value.strftime("%b %d %Y").sub("Sep", "Sept")
  end
end
