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

            # Compact users table
            div do
              div(class: "flex items-center justify-between mb-2") do
                h2(class: "font-semibold text-base-content") { "Users" }
                form_with(url: account_admin_users_path, method: :get, local: true, class: "flex gap-1") do |f|
                  f.text_field :search, placeholder: "Search...", class: "input input-xs input-bordered w-24"
                  f.submit "Go", class: "btn btn-xs btn-outline"
                end
              end

              if @recent_users.any?
                div(class: "overflow-x-auto -mx-2") do
                  table(class: "table table-xs w-full") do
                    tbody do
                      @recent_users.each do |user|
                        tr(class: "hover:bg-base-200/50 border-0") do
                          td(class: "py-1 px-2") do
                            div(class: "flex items-center gap-2") do
                              div(class: "w-4 h-4 rounded-full bg-primary text-primary-content flex items-center justify-center text-xs") do
                                user.email[0].upcase
                              end
                              div(class: "text-sm truncate max-w-48") do
                                plain(user.email)
                                if user == Current.user
                                  span(class: "text-xs text-primary ml-1") { "(you)" }
                                end
                              end
                            end
                          end
                          td(class: "py-1 px-1 text-xs text-base-content/70") do
                            if user.admin?
                              span(class: "text-primary") { "Admin" }
                            elsif !user.verified?
                              span(class: "text-warning") { "Pending" }
                            else
                              span(class: "text-base-content/50") { "Member" }
                            end
                          end
                          td(class: "py-1 px-1 text-xs text-base-content/70") { time_ago_in_words(user.created_at) }
                          td(class: "py-1 px-1 text-right") do
                            div(class: "flex justify-end gap-0.5") do
                              if user.verified? && user != Current.user
                                if user.admin?
                                  button_to("−", account_admin_user_path(user),
                                    method: :patch,
                                    params: { user: { admin: false } },
                                    class: "btn btn-xs btn-square btn-warning",
                                    confirm: "Remove admin?",
                                    title: "Remove admin")
                                else
                                  button_to("+", account_admin_user_path(user),
                                    method: :patch,
                                    params: { user: { admin: true } },
                                    class: "btn btn-xs btn-square btn-success",
                                    title: "Make admin")
                                end
                              elsif !user.verified?
                                button_to("✕", account_admin_invitation_path(user), 
                                  method: :delete,
                                  class: "btn btn-xs btn-square btn-error",
                                  confirm: "Cancel?",
                                  title: "Cancel invitation")
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
                
                if @total_users > 5
                  div(class: "text-center mt-2") do
                    link_to("View all #{@total_users} users →", account_admin_users_path, 
                      class: "text-xs text-primary hover:underline")
                  end
                end
              else
                div(class: "text-center py-4 text-base-content/70") do
                  p(class: "text-sm mb-2") { "No users yet" }
                  link_to("Send first invitation", new_account_admin_invitation_path, 
                    class: "btn btn-primary btn-xs")
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