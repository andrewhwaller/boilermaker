# frozen_string_literal: true

module Views
  module Admin
    module Users
      class Index < Views::Base
        include Phlex::Rails::Helpers::LinkTo
        include Phlex::Rails::Helpers::Pluralize
        include Phlex::Rails::Helpers::TimeAgoInWords

        def initialize(users:)
          @users = users
        end

        def view_template
          page_with_title("Users") do
            div(class: "space-y-6") do
              div(class: "flex items-center justify-between mb-6") do
                div(class: "flex items-center gap-4") do
                  link_to("← Admin", admin_dashboards_path, class: "text-sm text-base-content/70 hover:text-primary")
                  h1(class: "text-2xl font-bold text-base-content") { "All Users (#{@users.count})" }
                end
              end

              if @users.any?
                card do
                  render Components::Table.new(variant: :zebra, size: :sm) do
                    thead do
                      tr do
                        th { "Email" }
                        th { "Status" }
                        th { "Admin" }
                        th { "Account" }
                        th { "Joined" }
                        th { "Actions" }
                      end
                    end

                    tbody do
                      @users.each do |user|
                        tr do
                          td { user.email }
                          td do
                            if user.verified?
                              span(class: "text-success font-medium uppercase text-xs") { "Verified" }
                            else
                              span(class: "text-warning font-medium uppercase text-xs") { "Unverified" }
                            end
                          end
                          td do
                            if user.admin?
                              span(class: "text-error font-medium uppercase text-xs") { "App Admin" }
                            else
                              span(class: "text-base-content/70 font-medium uppercase text-xs") { "User" }
                            end
                          end
                          td { user.account.name || "Default Account" }
                          td { "#{time_ago_in_words(user.created_at)} ago" }
                          td do
                            link_to("View", admin_user_path(user), class: "btn btn-ghost btn-xs")
                          end
                        end
                      end
                    end
                  end
                end
              else
                card do
                  div(class: "text-center py-12") do
                    h3(class: "text-lg font-semibold text-base-content mb-2") { "No users found" }
                    p(class: "text-base-content/70") { "There are no users in the system yet." }
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
