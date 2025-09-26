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
                  link_to("← Admin", admin_path, class: "text-sm text-base-content/70 hover:text-primary")
                  h1(class: "font-bold text-base-content") { "All Users (#{@users.count})" }
                end
              end

              if @users.any?
                card do
                  Table(variant: :zebra, size: :sm) do
                    thead do
                      tr do
                        render Table::Header.new { "Email" }
                        render Table::Header.new { "Status" }
                        render Table::Header.new { "Admin" }
                        render Table::Header.new { "Account" }
                        render Table::Header.new { "Joined" }
                        render Table::Header.new { "Actions" }
                      end
                    end

                    tbody do
                      @users.each do |user|
                        render Table::Row.new(variant: :hover) do
                          render Table::Cell.new { user.email }
                          render Table::Cell.new do
                            if user.verified?
                              span(class: "text-success font-medium uppercase text-xs") { "Verified" }
                            else
                              span(class: "text-warning font-medium uppercase text-xs") { "Unverified" }
                            end
                          end
                          render Table::Cell.new do
                            if user.admin?
                              span(class: "text-error font-medium uppercase text-xs") { "App Admin" }
                            else
                              span(class: "text-base-content/70 font-medium uppercase text-xs") { "User" }
                            end
                          end
                          render Table::Cell.new { user.account.name || "Default Account" }
                          render Table::Cell.new { "#{time_ago_in_words(user.created_at)} ago" }
                          render Table::Actions.new do
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
                    h3(class: "font-semibold text-base-content mb-2") { "No users found" }
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
