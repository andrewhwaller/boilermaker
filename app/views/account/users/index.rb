# frozen_string_literal: true

module Views
  module Account
    module Users
      class Index < Views::Base
        include Phlex::Rails::Helpers::LinkTo
        include Phlex::Rails::Helpers::FormWith
        include Phlex::Rails::Helpers::Pluralize
        include Phlex::Rails::Helpers::TimeAgoInWords

        def initialize(users:, invitations:)
          @users = users
          @invitations = invitations
        end

        def view_template
          page_with_title("Users") do
            # Compact header
            div(class: "flex items-center justify-between mb-4") do
              div(class: "flex items-center gap-4") do
                link_to("← Dashboard", account_path, class: "text-sm text-base-content/70 hover:text-primary")
                h1(class: "text-xl font-bold text-base-content") { "Users (#{@users.count})" }
              end

              link_to("+ User", new_account_invitation_path, class: "btn btn-primary")
            end

            # Verified Users section
            if @users.any?
              div do
                h2(class: "text-lg font-semibold mb-3") { "Users" }
                render Components::Account::UserTable.new(
                  users: @users,
                  compact: false
                )
              end
            end

            # Pending Invitations section
            if @invitations.any?
              div(class: @users.any? ? "mt-8" : "") do
                h2(class: "text-lg font-semibold mb-3") { "Pending Invitations" }
                render Components::Account::InvitationTable.new(
                  invitations: @invitations,
                  compact: false
                )
              end
            end

            # Empty state
            if @users.empty? && @invitations.empty?
              div(class: "text-center py-8 bg-base-200 rounded-box") do
                p(class: "text-base-content/70 mb-4") { "No users or invitations yet." }
                link_to("Send first invitation", new_account_invitation_path, class: "btn btn-primary")
              end
            end
          end
        end
      end
    end
  end
end
