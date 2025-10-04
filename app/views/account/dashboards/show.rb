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
              h1(class: "font-bold text-base-content ") { "Manage Account" }
            end

            div(class: "flex flex-col gap-6 max-w-3xl") do
              render Components::Card.new(title: "Account Details", header_color: :primary) do
                form_with(model: @account, url: account_dashboard_path, method: :patch, local: true, class: "space-y-4") do |f|
                  div(class: "form-control w-full") do
                    f.label :name, "Account Name", class: "label"
                    f.text_field :name, class: "input input-bordered w-full", placeholder: "Enter account name", required: true
                    label(class: "label") do
                      span(class: "label-text-alt text-xs text-base-content/70") { "The display name for this account" }
                    end
                  end

                  div do
                    f.submit "Update", class: "btn btn-primary"
                  end
                end
              end

              render Components::Card.new(title: "Users", header_color: :primary, content_class: "p-0") do
                Table(variant: :zebra, class: "text-xs") do
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
                        td { plain(user_display_name(user)) }
                        td { user.email }
                        td do
                          if user != Current.user
                            form_with(model: user, url: account_user_path(user), method: :patch, local: false, class: "inline-flex items-center gap-2", data: { controller: "auto-submit" }) do |f|
                              membership = user.membership_for(Current.account)
                              input(type: "hidden", name: "role", value: "member")
                              input(
                                type: "checkbox",
                                name: "role",
                                value: "admin",
                                checked: membership&.admin? || false,
                                class: "peer toggle toggle-primary toggle-sm",
                                data: { action: "change->auto-submit#submit" }
                              )
                              label(class: "text-xs text-base-content/70 peer-checked:text-primary peer-checked:font-medium") { "Admin" }
                            end
                          else
                            role_badge(user)
                          end
                        end
                        td(class: "") { user.created_at.strftime("%b %d %Y") }
                        td(class: "text-right") do
                          div(class: "flex justify-end gap-3") do
                            link_to("EDIT", edit_account_user_path(user), class: "text-primary hover:underline cursor-pointer")
                          end
                        end
                      end
                    end
                  end
                end
              end

              render Components::Card.new(title: "Pending Invitations", header_color: :primary, content_class: "p-0") do
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
                        td(class: "") do
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
                              class: "text-error hover:underline cursor-pointer",
                              confirm: "Cancel invitation?")
                          end
                        end
                      end
                    end
                  end
                end
              end

              render Components::Card.new(title: "New Invitation", header_color: :primary) do
                form_with(url: account_invitations_path, local: true, class: "space-y-4") do |f|
                  div(class: "form-control w-full") do
                    f.label :email, "Email Address", class: "label"
                    f.email_field :email, class: "input input-bordered w-full", placeholder: "user@example.com", required: true
                  end

                  div(class: "form-control w-full") do
                    f.label :message, "Personal Message (Optional)", class: "label"
                    f.text_area :message, class: "textarea textarea-bordered w-full", rows: 3, placeholder: "Welcome to the team!"
                  end

                  div do
                    f.submit "Send Invitation", class: "btn btn-primary"
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
            span(class: "text-primary font-medium text-xs") { "Admin" }
          else
            span(class: "text-base-content/60 text-xs") { "Member" }
          end
        end
      end
    end
  end
end
