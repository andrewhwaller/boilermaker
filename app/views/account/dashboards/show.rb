# frozen_string_literal: true

module Views
  module Account
    module Dashboards
      class Show < Views::Base
        include Phlex::Rails::Helpers::LinkTo
        include Phlex::Rails::Helpers::Pluralize
        include Phlex::Rails::Helpers::TimeAgoInWords

        def initialize(account:, users:, invitations:)
          @account = account
          @users = users
          @invitations = invitations
        end

        def view_template
          page_with_title("Account") do
            div(class: "flex items-start justify-between mb-4") do
              div do
                h1(class: "font-bold text-base-content uppercase") { "Manage Account" }
              end
            end

            div(class: "flex flex-col gap-4") do
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
                          td { role_badge(user) }
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
          if user.account_admin_for?(Current.user.account)
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
