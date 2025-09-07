# frozen_string_literal: true

module Views
  module AccountAdmin
    module Dashboards
      class Show < Views::Base
        include Phlex::Rails::Helpers::LinkTo
        include Phlex::Rails::Helpers::Pluralize
        include Phlex::Rails::Helpers::TimeAgoInWords

        def initialize(account:, total_users:, admin_users:, recent_users:)
          @account = account
          @total_users = total_users
          @admin_users = admin_users
          @recent_users = recent_users
        end

        def view_template
          page_with_title("Account Administration") do
            div(class: "space-y-6") do
              # Header section
              div(class: "flex items-center justify-between mb-6") do
                h1(class: "text-2xl font-bold text-base-content") { "Account Administration" }
                link_to("Manage Users", account_admin_users_path, 
                  class: "btn btn-primary")
              end

              # Stats cards
              div(class: "grid grid-cols-1 md:grid-cols-3 gap-6 mb-6") do
                stats_card("Total Users", @total_users, "users")
                stats_card("Admins", @admin_users, "shield-check")
                stats_card("Account", @account.name || "Default Account", "building")
              end

              # Recent users section
              card do
                h2(class: "text-lg font-semibold text-base-content mb-4") { "Recent Users" }
                
                if @recent_users.any?
                  div(class: "space-y-3") do
                    @recent_users.each do |user|
                      div(class: "flex items-center justify-between py-2 border-b border-base-300 last:border-b-0") do
                        div do
                          div(class: "font-medium text-base-content") { user.email }
                          div(class: "text-sm text-base-content/70") do
                            plain("Joined #{time_ago_in_words(user.created_at)} ago")
                            if user.admin?
                              span(class: "badge badge-primary badge-sm ml-2") { "Admin" }
                            end
                          end
                        end
                      end
                    end
                  end
                  
                  div(class: "mt-4 text-center") do
                    link_to("View All Users", account_admin_users_path, class: "link link-primary")
                  end
                else
                  p(class: "text-base-content/70") { "No users found." }
                end
              end

              # Quick actions section
              card do
                h2(class: "text-lg font-semibold text-base-content mb-4") { "Quick Actions" }
                div(class: "grid grid-cols-2 md:grid-cols-3 gap-4") do
                  action_card("Invite Users", "Send invitations to new users", account_admin_invitations_path, "user-plus")
                  action_card("Account Settings", "Manage account preferences", account_admin_settings_path, "cog")
                  action_card("User Management", "View and manage all users", account_admin_users_path, "users")
                end
              end
            end
          end
        end

        private

        def stats_card(title, value, icon)
          card(class: "text-center") do
            div(class: "text-2xl font-bold text-primary mb-1") { value.to_s }
            div(class: "text-sm text-base-content/70") { title }
          end
        end

        def action_card(title, description, path, icon)
          link_to(path, class: "block p-4 border border-base-300 rounded-box hover:bg-base-200 transition-colors") do
            div(class: "font-medium text-base-content mb-1") { title }
            div(class: "text-sm text-base-content/70") { description }
          end
        end
      end
    end
  end
end