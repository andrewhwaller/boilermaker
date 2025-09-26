# frozen_string_literal: true

module Views
  module Account
    module Dashboards
      class Show < Views::Base
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
              h1(class: "font-bold text-base-content uppercase") { "Manage Account" }
            end

            div(class: "flex flex-col gap-6") do
              # Invite User Form
              card do
                div(class: "flex items-center justify-between mb-4") do
                  h2(class: "font-semibold text-base-content uppercase") { "Invite New User" }
                end

                form_with(url: account_invitations_path, local: true, class: "space-y-4") do |f|
                  div(class: "grid grid-cols-1 md:grid-cols-2 gap-4") do
                    div do
                      f.label :email, "Email Address", class: "label"
                      f.email_field :email, class: "input input-bordered w-full", placeholder: "user@example.com", required: true
                    end

                    div do
                      f.label :message, "Personal Message (Optional)", class: "label"
                      f.text_area :message, class: "textarea textarea-bordered w-full", rows: 2, placeholder: "Welcome to the team!"
                    end
                  end

                  div do
                    label(class: "label cursor-pointer justify-start gap-3") do
                      f.check_box :admin, class: "checkbox checkbox-primary"
                      span(class: "label-text") { "Grant admin privileges" }
                    end
                  end

                  div do
                    f.submit "Send Invitation", class: "btn btn-primary"
                  end
                end
              end

              # Users Section
              div do
                div do
                  div(class: "flex items-center justify-between mb-2") do
                    h2(class: "font-semibold text-base-content uppercase") { "Users" }
                  end

                  Table(variant: :zebra, size: :xs) do
                    thead do
                      tr do
                        th { "Name" }
                        th { "Email" }
                        th { "Status" }
                        th { "Role" }
                        th { "Joined" }
                        th(class: "text-right") { "Actions" }
                      end
                    end

                    tbody do
                      @users.each do |user|
                        tr do
                          td { plain(user_display_name(user)) }
                          td { user.email }
                          td { status_badge(user) }
                          td do
                            if user != Current.user
                              form_with(model: user, url: account_user_path(user), method: :patch, local: false, class: "inline-flex items-center gap-2", data: { controller: "auto-submit" }) do |f|
                                membership = user.membership_for(Current.user.account)
                                input(type: "hidden", name: "role", value: "member")
                                input(
                                  type: "checkbox",
                                  name: "role",
                                  value: "admin",
                                  checked: membership&.admin? || false,
                                  class: "peer toggle toggle-primary toggle-sm",
                                  data: { action: "change->auto-submit#submit" }
                                )
                                label(class: "text-xs text-base-content/70 uppercase peer-checked:text-primary peer-checked:font-medium") { "Admin" }
                              end
                            else
                              role_badge(user)
                            end
                          end
                          td { formatted_date(user.created_at) }
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
              end

              div do
                Components::Account::InvitationTable(
                  invitations: @invitations,
                  compact: true
                )
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

        def status_badge(user)
          if user.verified?
            span(class: "text-success font-medium uppercase text-xs") { "Verified" }
          else
            span(class: "text-warning font-medium uppercase text-xs") { "Pending" }
          end
        end

        def role_badge(user)
          membership = user.membership_for(Current.user.account)
          if membership&.admin?
            span(class: "text-primary font-medium uppercase text-xs") { "Admin" }
          else
            span(class: "text-base-content/60 uppercase text-xs") { "Member" }
          end
        end

        def formatted_date(value)
          value.strftime("%b %d %Y").upcase
        end
      end
    end
  end
end
