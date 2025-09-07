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
          page_with_title("User Management") do
            div(class: "space-y-6") do
              # Header section
              div(class: "flex items-center justify-between mb-6") do
                h1(class: "text-2xl font-bold text-base-content") { "User Management" }
                link_to("Back to Dashboard", account_admin_dashboard_path, class: "btn btn-outline")
              end

              # Search and actions bar
              div(class: "flex items-center justify-between gap-4 mb-6") do
                # Search form
                form_with(url: account_admin_users_path, method: :get, local: true, class: "flex gap-2") do |f|
                  f.text_field :search, placeholder: "Search users by email...",
                    value: @search,
                    class: "input input-bordered flex-1"
                  f.submit "Search", class: "btn btn-outline"
                end

                link_to("Invite User", new_account_admin_invitation_path, class: "btn btn-primary")
              end

              # Users table
              card do
                h2(class: "text-lg font-semibold text-base-content mb-4") do
                  "Users (#{@users.count})"
                end

                if @users.any?
                  div(class: "overflow-x-auto") do
                    table(class: "table w-full") do
                      thead do
                        tr do
                          th { "User" }
                          th { "Status" }
                          th { "Role" }
                          th { "Joined" }
                          th(class: "text-right") { "Actions" }
                        end
                      end

                      tbody do
                        @users.each do |user|
                          tr(class: "hover") do
                            td do
                              div(class: "flex items-center gap-3") do
                                div(class: "avatar placeholder") do
                                  div(class: "bg-primary text-primary-content w-8 rounded-full") do
                                    span(class: "text-xs") { user.email[0].upcase }
                                  end
                                end
                                div do
                                  div(class: "font-medium") { user.email }
                                  div(class: "text-sm text-base-content/70") do
                                    if user == Current.user
                                      span(class: "text-primary") { "(You)" }
                                    end
                                  end
                                end
                              end
                            end

                            td { user_status_badge(user) }
                            
                            td { user_role_badge(user) }

                            td(class: "text-sm text-base-content/70") do
                              plain(time_ago_in_words(user.created_at) + " ago")
                            end

                            td(class: "text-right") do
                              div(class: "flex justify-end gap-2") do
                                link_to("View", account_admin_user_path(user), 
                                  class: "btn btn-ghost btn-xs")
                                link_to("Edit", edit_account_admin_user_path(user), 
                                  class: "btn btn-outline btn-xs")
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                else
                  div(class: "text-center py-8") do
                    p(class: "text-base-content/70 mb-4") do
                      if @search.present?
                        "No users found matching \"#{@search}\""
                      else
                        "No users found."
                      end
                    end
                    
                    if @search.present?
                      link_to("Clear search", account_admin_users_path, class: "link link-primary")
                    end
                  end
                end
              end
            end
          end
        end

        private

        def user_status_badge(user)
          if user.verified?
            span(class: "badge badge-success badge-sm") { "Verified" }
          else
            span(class: "badge badge-warning badge-sm") { "Unverified" }
          end
        end

        def user_role_badge(user)
          if user.admin?
            span(class: "badge badge-primary badge-sm") { "Admin" }
          else
            span(class: "badge badge-ghost badge-sm") { "Member" }
          end
        end
      end
    end
  end
end