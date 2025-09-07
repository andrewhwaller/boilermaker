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
                link_to("+ User", new_account_admin_invitation_path, class: "btn btn-primary btn-sm")
                link_to("Settings", account_admin_settings_path, class: "btn btn-outline btn-sm")
              end
            end

            # Dense user list with inline actions
            div(class: "bg-base-200 rounded-box p-4") do
              div(class: "flex items-center justify-between mb-3") do
                h2(class: "font-semibold text-base-content") { "Users" }
                form_with(url: account_admin_users_path, method: :get, local: true, class: "flex gap-2 flex-1 max-w-xs ml-4") do |f|
                  f.text_field :search, placeholder: "Search...", class: "input input-sm input-bordered flex-1"
                  f.submit "Go", class: "btn btn-sm btn-outline"
                end
              end

              if @recent_users.any?
                div(class: "space-y-1") do
                  @recent_users.each do |user|
                    div(class: "flex items-center justify-between py-2 px-3 rounded hover:bg-base-300 transition-colors") do
                      div(class: "flex items-center gap-3 flex-1 min-w-0") do
                        div(class: "avatar placeholder flex-shrink-0") do
                          div(class: "bg-primary text-primary-content w-6 h-6 rounded-full text-xs") do
                            span { user.email[0].upcase }
                          end
                        end
                        div(class: "min-w-0 flex-1") do
                          div(class: "font-medium text-sm truncate") do
                            plain(user.email)
                            if user == Current.user
                              span(class: "text-xs text-primary ml-2") { "(you)" }
                            end
                          end
                          div(class: "flex items-center gap-2 text-xs text-base-content/70") do
                            plain(time_ago_in_words(user.created_at) + " ago")
                            if user.admin?
                              span(class: "badge badge-primary badge-xs") { "admin" }
                            end
                            unless user.verified?
                              span(class: "badge badge-warning badge-xs") { "pending" }
                            end
                          end
                        end
                      end
                      div(class: "flex gap-1 flex-shrink-0") do
                        link_to("Edit", edit_account_admin_user_path(user), 
                          class: "btn btn-ghost btn-xs")
                        if user.verified?
                          link_to("View", account_admin_user_path(user), 
                            class: "btn btn-ghost btn-xs")
                        else
                          button_to("Cancel", account_admin_invitation_path(user), 
                            method: :delete,
                            class: "btn btn-error btn-xs",
                            confirm: "Cancel invitation?")
                        end
                      end
                    end
                  end
                end
                
                if @total_users > 5
                  div(class: "text-center mt-3 pt-3 border-t border-base-300") do
                    link_to("View all #{@total_users} users →", account_admin_users_path, 
                      class: "text-sm text-primary hover:underline")
                  end
                end
              else
                div(class: "text-center py-6 text-base-content/70") do
                  p(class: "text-sm mb-2") { "No users yet" }
                  link_to("Send first invitation", new_account_admin_invitation_path, 
                    class: "btn btn-primary btn-sm")
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