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

            # Dense user list
            if @users.any?
              div(class: "bg-base-200 rounded-box p-3") do
                div(class: "space-y-1") do
                  @users.each do |user|
                    div(class: "flex items-center justify-between py-2 px-3 rounded hover:bg-base-300 transition-colors") do
                      # User info section - denser layout
                      div(class: "flex items-center gap-3 flex-1 min-w-0") do
                        div(class: "avatar placeholder flex-shrink-0") do
                          div(class: "bg-primary text-primary-content w-8 h-8 rounded-full text-sm") do
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
                          div(class: "flex items-center gap-3 text-xs text-base-content/70") do
                            plain(time_ago_in_words(user.created_at) + " ago")
                            
                            # Inline status indicators
                            div(class: "flex gap-1") do
                              if user.verified?
                                span(class: "badge badge-success badge-xs") { "verified" }
                              else
                                span(class: "badge badge-warning badge-xs") { "pending" }
                              end
                              
                              if user.admin?
                                span(class: "badge badge-primary badge-xs") { "admin" }
                              end
                              
                              # Session count if available
                              if user.sessions.any?
                                span(class: "text-base-content/50") { "#{user.sessions.count} sessions" }
                              end
                            end
                          end
                        end
                      end

                      # Quick actions - more options visible
                      div(class: "flex gap-1 flex-shrink-0") do
                        if user.verified?
                          # Toggle admin status quickly
                          if user.admin? && user != Current.user
                            button_to("Remove Admin", account_admin_user_path(user),
                              method: :patch,
                              params: { user: { admin: false } },
                              class: "btn btn-warning btn-xs",
                              confirm: "Remove admin privileges?")
                          elsif !user.admin?
                            button_to("Make Admin", account_admin_user_path(user),
                              method: :patch,
                              params: { user: { admin: true } },
                              class: "btn btn-success btn-xs")
                          end
                          
                          link_to("Edit", edit_account_admin_user_path(user), 
                            class: "btn btn-ghost btn-xs")
                          link_to("View", account_admin_user_path(user), 
                            class: "btn btn-ghost btn-xs")
                        else
                          # Pending invitation actions
                          button_to("Resend", new_account_admin_invitation_path,
                            params: { email: user.email },
                            method: :get,
                            class: "btn btn-success btn-xs")
                          button_to("Cancel", account_admin_invitation_path(user), 
                            method: :delete,
                            class: "btn btn-error btn-xs",
                            confirm: "Cancel invitation?")
                          link_to("Edit", edit_account_admin_user_path(user), 
                            class: "btn btn-ghost btn-xs")
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