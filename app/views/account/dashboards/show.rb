# frozen_string_literal: true

module Views
  module Account
    module Dashboards
      class Show < Views::Base
        include Phlex::Rails::Helpers::ButtonTo
        include Phlex::Rails::Helpers::LinkTo
        include Phlex::Rails::Helpers::Pluralize
        include Phlex::Rails::Helpers::TimeAgoInWords
        include Phlex::Rails::Helpers::FormWith

        def initialize(account:, users:, invitations:)
          @account = account
          @users = users
          @invitations = invitations
        end

        def view_template
          page_with_title("Account") do
            div(class: "flex items-start justify-between mb-4") do
              h1(class: "font-bold text-body") { "Manage Account" }
            end

            div(class: "flex flex-col gap-6 max-w-3xl") do
              render Components::Card.new(title: "Account Details") do
                form_with(model: @account, url: account_dashboard_path, method: :patch, local: true, class: "space-y-4") do |f|
                  div(class: "space-y-1") do
                    f.label :name, "Account Name", class: "label"
                    f.text_field :name, class: "ui-input", placeholder: "Enter account name", required: true
                    label(class: "label") do
                      span(class: "text-xs text-muted") { "The display name for this account" }
                    end
                  end

                  div do
                    f.submit "Update", class: "ui-button ui-button-primary"
                  end
                end
              end

              render Components::Card.new(title: "Users", content_class: "p-0") do
                Table(variant: :zebra) do
                  thead do
                    tr do
                      th { "Name" }
                      th { "Email" }
                      th { "Role" }
                      th { "Added" }
                      th(class: "text-right") { "Actions" }
                    end
                  end

                  tbody do
                    @users.each do |user|
                      tr do
                        td(class: "whitespace-nowrap") { plain(user_display_name(user)) }
                        td { user.email }
                        td { role_badge(user) }
                        td(class: "whitespace-nowrap") { user.created_at.strftime("%b %d %Y") }
                        td(class: "text-right") do
                          link_to("Edit", edit_account_user_path(user), class: "text-xs")
                        end
                      end
                    end
                  end
                end
              end

              render Components::Card.new(title: "Pending Invitations", content_class: "p-0") do
                Table(variant: :zebra) do
                  thead do
                    tr do
                      th { "Email" }
                      th { "Sent" }
                      th(class: "text-right") { "Actions" }
                    end
                  end

                  tbody do
                    @invitations.each do |invitation|
                      tr do
                        td { invitation.email }
                        td do
                          invitation.created_at.strftime("%b %d %Y")
                        end
                        td(class: "text-right") do
                          div(class: "flex justify-end gap-3") do
                            button_to("RESEND", new_account_invitation_path,
                              params: { email: invitation.email },
                              method: :get,
                              class: "text-success hover:underline cursor-pointer")
                            button_to("CANCEL", account_invitation_path(invitation),
                              method: :delete,
                              class: "text-destructive hover:underline cursor-pointer",
                              confirm: "Cancel invitation?")
                          end
                        end
                      end
                    end
                  end
                end
              end

              render Components::Card.new(title: "New Invitation") do
                form_with(url: account_invitations_path, local: true, class: "space-y-4") do |f|
                  div(class: "space-y-1") do
                    f.label :email, "Email Address", class: "label"
                    f.email_field :email, class: "ui-input", placeholder: "user@example.com", required: true
                  end

                  div(class: "space-y-1") do
                    f.label :message, "Personal Message (Optional)", class: "label"
                    f.text_area :message, class: "ui-textarea", rows: 3, placeholder: "Welcome to the team!"
                  end

                  div do
                    f.submit "Send Invitation", class: "ui-button ui-button-primary"
                  end
                end
              end
            end
          end
        end

        private

        def user_display_name(user)
          name = [ user.first_name, user.last_name ].compact.join(" ").strip
          return name if name.present?

          "—"
        end

        def role_badge(user)
          membership = user.membership_for(Current.account)
          if membership&.admin?
            span(class: "text-accent font-medium text-xs") { "Admin" }
          else
            span(class: "text-muted text-xs") { "Member" }
          end
        end
      end
    end
  end
end
