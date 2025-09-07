# frozen_string_literal: true

module Views
  module AccountAdmin
    module Users
      class Index < Views::Base
        include Phlex::Rails::Helpers::LinkTo
        include Phlex::Rails::Helpers::FormWith
        include Phlex::Rails::Helpers::Pluralize
        include Phlex::Rails::Helpers::TimeAgoInWords

        def initialize(users:, search: nil)
          @users = users
          @search = search
        end

        def view_template
          page_with_title("Users") do
            # Compact header with search and actions inline
            div(class: "flex items-center justify-between mb-4") do
              div(class: "flex items-center gap-4") do
                link_to("← Dashboard", account_admin_dashboard_path, class: "text-sm text-base-content/70 hover:text-primary")
                h1(class: "text-xl font-bold text-base-content") { "Users (#{@users.count})" }
              end
              
              div(class: "flex gap-2") do
                form_with(url: account_admin_users_path, method: :get, local: true, class: "flex gap-2") do |f|
                  f.text_field :search, placeholder: "Search...", 
                    value: @search,
                    class: "input input-sm input-bordered w-32"
                  f.submit "Go", class: "btn btn-sm btn-outline"
                end
                link_to("+ User", new_account_admin_invitation_path, class: "btn btn-primary btn-sm")
              end
            end

            # Dense users table
            if @users.any?
              div(class: "overflow-x-auto -mx-2") do
                table(class: "table table-xs w-full") do
                  thead do
                    tr(class: "border-b border-base-300") do
                      th(class: "font-semibold text-base px-2") { "User" }
                      th(class: "font-semibold text-base px-1 text-center") { "Status" }
                      th(class: "font-semibold text-base px-1") { "Role" }
                      th(class: "font-semibold text-base px-1 text-center") { "Sessions" }
                      th(class: "font-semibold text-base px-1") { "Joined" }
                      th(class: "font-semibold text-base px-1 text-right") { "Actions" }
                    end
                  end
                  
                  tbody do
                    @users.each do |user|
                      tr(class: "hover:bg-base-200/50") do
                        td(class: "py-1") do
                          div(class: "flex items-center gap-2") do
                            div(class: "w-7 h-7 rounded-full bg-primary text-primary-content flex items-center justify-center text-base font-medium") do
                              user.email[0].upcase
                            end
                            div do
                              plain(user.email)
                              if user == Current.user
                                span(class: "text-base text-primary ml-1") { "(you)" }
                              end
                            end
                          end
                        end
                        td(class: "py-1 text-center") do
                          if user.verified?
                            span(class: "text-base text-success") { "✓" }
                          else
                            span(class: "text-base text-warning") { "⏳" }
                          end
                        end
                        td(class: "py-1") do
                          if user.admin?
                            span(class: "text-base text-primary font-medium") { "Admin" }
                          else
                            span(class: "text-base text-base-content/60") { "Member" }
                          end
                        end
                        td(class: "py-1 text-base text-base-content/70 text-center") { user.sessions.count }
                        td(class: "py-1 text-base text-base-content/70") { time_ago_in_words(user.created_at) }
                        td(class: "py-1 text-right") do
                          div(class: "flex justify-end gap-0.5") do
                            if user.verified?
                              if user != Current.user
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
                              end
                              link_to("E", edit_account_admin_user_path(user), 
                                class: "btn btn-xs btn-square btn-ghost",
                                title: "Edit user")
                            else
                              button_to("↻", new_account_admin_invitation_path,
                                params: { email: user.email },
                                method: :get,
                                class: "btn btn-xs btn-square btn-success",
                                title: "Resend invitation")
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
            else
              div(class: "text-center py-8 bg-base-200 rounded-box") do
                p(class: "text-base-content/70 mb-4") do
                  if @search.present?
                    "No users found matching \"#{@search}\""
                  else
                    "No users found."
                  end
                end
                
                if @search.present?
                  link_to("Clear search", account_admin_users_path, class: "btn btn-outline btn-sm")
                else
                  link_to("Send first invitation", new_account_admin_invitation_path, class: "btn btn-primary btn-sm")
                end
              end
            end

            # Bulk actions footer if multiple users
            if @users.count > 1
              div(class: "mt-4 text-xs text-base-content/70 text-center") do
                plain("#{pluralize(@users.where(verified: true).count, "verified user")}, ")
                plain("#{pluralize(@users.where(admin: true).count, "admin")}, ")
                plain("#{pluralize(@users.where(verified: false).count, "pending invitation")}")
              end
            end
          end
        end

      end
    end
  end
end