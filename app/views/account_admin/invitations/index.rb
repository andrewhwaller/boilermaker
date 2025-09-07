# frozen_string_literal: true

module Views
  module AccountAdmin
    module Invitations
      class Index < Views::Base
        include Phlex::Rails::Helpers::LinkTo
        include Phlex::Rails::Helpers::TimeAgoInWords
        include Phlex::Rails::Helpers::ButtonTo

        def initialize(pending_users:)
          @pending_users = pending_users
        end

        def view_template
          page_with_title("Manage Invitations") do
            div(class: "space-y-6") do
              # Header
              div(class: "flex items-center justify-between mb-6") do
                h1(class: "text-2xl font-bold text-base-content") { "Manage Invitations" }
                div(class: "flex gap-2") do
                  link_to("Send Invitation", new_account_admin_invitation_path, class: "btn btn-primary")
                  link_to("Back to Dashboard", account_admin_dashboard_path, class: "btn btn-outline")
                end
              end

              # Pending invitations
              card do
                h2(class: "text-lg font-semibold text-base-content mb-4") do
                  "Pending Invitations (#{@pending_users.count})"
                end

                if @pending_users.any?
                  div(class: "overflow-x-auto") do
                    table(class: "table w-full") do
                      thead do
                        tr do
                          th { "Email" }
                          th { "Role" }
                          th { "Invited" }
                          th(class: "text-right") { "Actions" }
                        end
                      end

                      tbody do
                        @pending_users.each do |user|
                          tr(class: "hover") do
                            td do
                              div(class: "flex items-center gap-3") do
                                div(class: "avatar placeholder") do
                                  div(class: "bg-warning text-warning-content w-8 rounded-full") do
                                    span(class: "text-xs") { user.email[0].upcase }
                                  end
                                end
                                div do
                                  div(class: "font-medium") { user.email }
                                  div(class: "text-sm text-warning") { "Invitation pending" }
                                end
                              end
                            end

                            td do
                              if user.admin?
                                span(class: "badge badge-primary badge-sm") { "Admin" }
                              else
                                span(class: "badge badge-ghost badge-sm") { "Member" }
                              end
                            end

                            td(class: "text-sm text-base-content/70") do
                              plain("#{time_ago_in_words(user.created_at)} ago")
                            end

                            td(class: "text-right") do
                              div(class: "flex justify-end gap-2") do
                                button_to("Resend", new_account_admin_invitation_path, 
                                  params: { email: user.email },
                                  method: :get,
                                  class: "btn btn-outline btn-xs")
                                button_to("Cancel", account_admin_invitation_path(user), 
                                  method: :delete,
                                  class: "btn btn-error btn-xs",
                                  confirm: "Are you sure you want to cancel this invitation?")
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                else
                  div(class: "text-center py-8") do
                    div(class: "text-base-content/70 mb-4") do
                      p(class: "text-lg") { "No pending invitations" }
                      p { "All users in your account have accepted their invitations." }
                    end
                    
                    link_to("Send New Invitation", new_account_admin_invitation_path, 
                      class: "btn btn-primary")
                  end
                end
              end

              # Help section
              card do
                h3(class: "text-lg font-semibold text-base-content mb-4") { "About Invitations" }
                div(class: "space-y-2 text-sm text-base-content/70") do
                  p { "• Invitations are sent via email and allow new users to join your account" }
                  p { "• Pending invitations show users who have been invited but haven't verified their email yet" }
                  p { "• You can cancel pending invitations or resend them if needed" }
                  p { "• Admin invitations grant account administration privileges to the new user" }
                end
              end
            end
          end
        end
      end
    end
  end
end