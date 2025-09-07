# frozen_string_literal: true

module Views
  module AccountAdmin
    module Dashboards
      class Show < Views::Base
        include Phlex::Rails::Helpers::LinkTo
        include Phlex::Rails::Helpers::Pluralize
        include Phlex::Rails::Helpers::TimeAgoInWords

        def initialize(account:, total_users:, admin_users:)
          @account = account
          @total_users = total_users
          @admin_users = admin_users
        end

        def view_template
          page_with_title("Account Admin") do
            # Compact header with inline stats and actions
            div(class: "flex items-start justify-between mb-4") do
              div do
                div(class: "flex items-center gap-4 mb-2") do
                  h1(class: "text-xl font-bold text-base-content") { @account.name || "Account Admin" }
                  div(class: "flex gap-3 text-sm") do
                    stat_inline("#{@total_users} users", @admin_users > 0 ? "text-primary" : "text-base-content")
                    stat_inline("#{@admin_users} admins", "text-primary") if @admin_users > 0
                  end
                end
              end
              
              div(class: "flex gap-2") do
                link_to("Users", account_admin_users_path, class: "btn btn-primary btn-sm")
                link_to("+ User", new_account_admin_invitation_path, class: "btn btn-success btn-sm")
                link_to("Settings", account_admin_settings_path, class: "btn btn-outline btn-sm")
              end
            end

            # Quick actions section
            div(class: "bg-base-200 rounded-box p-4") do
              h2(class: "font-semibold text-base-content mb-3") { "Quick Actions" }
              
              div(class: "grid grid-cols-2 gap-3") do
                link_to(account_admin_users_path, class: "flex items-center gap-3 p-3 rounded-box hover:bg-base-300 transition-colors") do
                  div(class: "flex items-center justify-center w-10 h-10 bg-primary text-primary-content rounded-box") do
                    span(class: "text-lg") { "👥" }
                  end
                  div do
                    div(class: "font-medium text-base-content") { "Manage Users" }
                    div(class: "text-sm text-base-content/70") { "#{@total_users} users" }
                  end
                end
                
                link_to(new_account_admin_invitation_path, class: "flex items-center gap-3 p-3 rounded-box hover:bg-base-300 transition-colors") do
                  div(class: "flex items-center justify-center w-10 h-10 bg-success text-success-content rounded-box") do
                    span(class: "text-lg") { "✉️" }
                  end
                  div do
                    div(class: "font-medium text-base-content") { "Invite Users" }
                    div(class: "text-sm text-base-content/70") { "Send invitations" }
                  end
                end
              end
            end

            # Quick stats and pending items
            if @account.users.unverified.any?
              div(class: "bg-warning/10 border border-warning/30 rounded-box p-3 mt-4") do
                div(class: "flex items-center justify-between") do
                  div do
                    div(class: "font-medium text-sm text-warning-content") { "Pending Invitations" }
                    div(class: "text-xs text-base-content/70") do
                      plain("#{pluralize(@account.users.unverified.count, "user")} waiting to verify")
                    end
                  end
                  link_to("Manage", account_admin_invitations_path, class: "btn btn-warning btn-xs")
                end
              end
            end
          end
        end

        private

        def stat_inline(text, color_class = "text-base-content")
          span(class: "#{color_class} font-medium") { text }
        end
      end
    end
  end
end