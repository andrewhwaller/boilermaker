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
                  h1(class: "text-2xl font-bold text-base-content") { "All Users" }
                  span(class: "text-sm text-base-content/60 font-medium") { "#{@users.count} total" }
                end
              end

              if @users.any?
                div(class: "bg-base-200 border border-base-300 rounded-box overflow-hidden shadow-sm") do
                  div(class: "overflow-x-auto") do
                    Table(variant: :zebra, size: :sm) do
                    thead do
                      tr do
                        render Table::Header.new(class: "w-1/4 min-w-[200px]") { "Email" }
                        render Table::Header.new(class: "w-20 text-center") { "Status" }
                        render Table::Header.new(class: "w-20 text-center") { "Role" }
                        render Table::Header.new(class: "w-1/4 min-w-[150px]") { "Account" }
                        render Table::Header.new(class: "w-24") { "Joined" }
                        render Table::Header.new(class: "w-20 text-right") { "Actions" }
                      end
                    end

                    tbody do
                      @users.each do |user|
                        render Table::Row.new(variant: :hover) do
                          render Table::Cell.new(class: "font-medium") do
                            div(class: "truncate max-w-[200px] text-base-content") { user.email }
                          end
                          render Table::Cell.new(align: :center) do
                            if user.verified?
                              span(class: "inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-success/20 text-success border border-success/30") { "Verified" }
                            else
                              span(class: "inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-warning/20 text-warning border border-warning/30") { "Unverified" }
                            end
                          end
                          render Table::Cell.new(align: :center) do
                            if user.app_admin?
                              span(class: "inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-error/20 text-error border border-error/30") { "Admin" }
                            else
                              span(class: "inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-base-300/50 text-base-content/70 border border-base-300") { "User" }
                            end
                          end
                          render Table::Cell.new do
                            div(class: "truncate max-w-[150px] text-base-content/80") do
                              if user.accounts.any?
                                "#{user.accounts.count} account(s)"
                              else
                                "No accounts"
                              end
                            end
                          end
                          render Table::Cell.new do
                            span(class: "text-sm text-base-content/60 whitespace-nowrap") { "#{time_ago_in_words(user.created_at)} ago" }
                          end
                          render Table::Actions.new do
                            link_to("View", admin_user_path(user), class: "ui-button ui-button-ghost ui-button-xs")
                          end
                        end
                      end
                    end
                    end
                  end
                end
              else
                div(class: "bg-base-200 border border-base-300 rounded-box p-12 text-center shadow-sm") do
                  div(class: "max-w-sm mx-auto") do
                    h3(class: "text-lg font-semibold text-base-content mb-2") { "No users found" }
                    p(class: "text-base-content/60") { "There are no users in the system yet." }
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
