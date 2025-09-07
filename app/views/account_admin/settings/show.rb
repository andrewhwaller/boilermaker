# frozen_string_literal: true

module Views
  module AccountAdmin
    module Settings
      class Show < Views::Base
        include Phlex::Rails::Helpers::LinkTo
        include Phlex::Rails::Helpers::Pluralize

        def initialize(account:)
          @account = account
        end

        def view_template
          page_with_title("Account Settings") do
            div(class: "space-y-6") do
              # Header
              div(class: "flex items-center justify-between mb-6") do
                h1(class: "text-2xl font-bold text-base-content") { "Account Settings" }
                div(class: "flex gap-2") do
                  link_to("Edit Settings", edit_account_admin_settings_path, class: "btn btn-primary")
                  link_to("Back to Dashboard", account_admin_dashboard_path, class: "btn btn-outline")
                end
              end

              # Account information
              card do
                h2(class: "text-lg font-semibold text-base-content mb-4") { "Account Information" }
                
                div(class: "grid grid-cols-1 md:grid-cols-2 gap-6") do
                  div do
                    div(class: "text-sm text-base-content/70 mb-1") { "Account Name" }
                    div(class: "text-lg font-medium") { @account.name || "Not set" }
                  end

                  div do
                    div(class: "text-sm text-base-content/70 mb-1") { "Total Users" }
                    div(class: "text-lg font-medium") do
                      plain(pluralize(@account.users.count, "user"))
                    end
                  end

                  div do
                    div(class: "text-sm text-base-content/70 mb-1") { "Admin Users" }
                    div(class: "text-lg font-medium") do
                      plain(pluralize(@account.users.where(admin: true).count, "admin"))
                    end
                  end

                  div do
                    div(class: "text-sm text-base-content/70 mb-1") { "Created" }
                    div(class: "text-lg font-medium") do
                      plain(@account.created_at.strftime("%B %d, %Y"))
                    end
                  end
                end
              end

              # User management stats
              card do
                h3(class: "text-lg font-semibold text-base-content mb-4") { "User Statistics" }
                
                div(class: "grid grid-cols-2 md:grid-cols-4 gap-4") do
                  stat_card("Active Users", @account.users.where(verified: true).count, "text-success")
                  stat_card("Pending Invitations", @account.users.where(verified: false).count, "text-warning")
                  stat_card("Admin Users", @account.users.where(admin: true).count, "text-primary")
                  stat_card("Total Users", @account.users.count, "text-base-content")
                end
              end

              # Quick actions
              card do
                h3(class: "text-lg font-semibold text-base-content mb-4") { "Quick Actions" }
                
                div(class: "grid grid-cols-1 md:grid-cols-3 gap-4") do
                  action_link("Manage Users", "View and edit user accounts", account_admin_users_path)
                  action_link("Send Invitations", "Invite new users to your account", new_account_admin_invitation_path)
                  action_link("View Invitations", "Manage pending invitations", account_admin_invitations_path)
                end
              end
            end
          end
        end

        private

        def stat_card(title, value, color_class = "text-base-content")
          div(class: "text-center") do
            div(class: "text-2xl font-bold #{color_class} mb-1") { value.to_s }
            div(class: "text-sm text-base-content/70") { title }
          end
        end

        def action_link(title, description, path)
          link_to(path, class: "block p-4 border border-base-300 rounded-box hover:bg-base-200 transition-colors") do
            div(class: "font-medium text-base-content mb-1") { title }
            div(class: "text-sm text-base-content/70") { description }
          end
        end
      end
    end
  end
end