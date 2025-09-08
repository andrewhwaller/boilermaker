# frozen_string_literal: true

module Views
  module Account
    module Dashboards
      class Show < Views::Base
        include Phlex::Rails::Helpers::LinkTo
        include Phlex::Rails::Helpers::Pluralize
        include Phlex::Rails::Helpers::TimeAgoInWords

        def initialize(account:, recent_users:, recent_invitations:)
          @account = account
          @recent_users = recent_users
          @recent_invitations = recent_invitations
        end

        def view_template
          page_with_title("Account") do
            # Compact header with actions
            div(class: "flex items-start justify-between mb-4") do
              div do
                h1(class: "text-xl font-bold text-base-content") { @account.name || "Account" }
              end

              div(class: "flex gap-2") do
                link_to("Users", account_users_path, class: "btn btn-primary btn-sm")
                link_to("+ User", new_account_invitation_path, class: "btn btn-success btn-sm")
                link_to("Settings", account_settings_path, class: "btn btn-outline btn-sm")
              end
            end

            # Recent Users section
            if @recent_users.any?
              div do
                div(class: "flex items-center justify-between mb-2") do
                  h2(class: "font-semibold text-base-content") { "Users" }
                end

                render Components::Account::UserTable.new(
                  users: @recent_users,
                  compact: true
                )

                if @recent_users.count == 5
                  div(class: "text-center mt-2") do
                    link_to("View all users →", account_users_path,
                      class: "text-base text-primary hover:underline")
                  end
                end
              end
            end

            # Recent Invitations section
            if @recent_invitations.any?
              div(class: @recent_users.any? ? "mt-6" : "") do
                div(class: "flex items-center justify-between mb-2") do
                  h2(class: "font-semibold text-base-content") { "Pending Invitations" }
                end

                render Components::Account::InvitationTable.new(
                  invitations: @recent_invitations,
                  compact: true
                )

                if @recent_invitations.count == 5
                  div(class: "text-center mt-2") do
                    link_to("View all invitations →", account_users_path,
                      class: "text-base text-primary hover:underline")
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
