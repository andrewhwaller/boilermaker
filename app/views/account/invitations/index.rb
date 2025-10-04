# frozen_string_literal: true

module Views
  module Account
    module Invitations
      class Index < Views::Base
        include Phlex::Rails::Helpers::LinkTo
        include Phlex::Rails::Helpers::TimeAgoInWords
        include Phlex::Rails::Helpers::ButtonTo

        def initialize(pending_users:)
          @pending_users = pending_users
        end

        def view_template
          page_with_title("Invitations") do
            # Compact header
            div(class: "flex items-center justify-between mb-4") do
              div(class: "flex items-center gap-4") do
                link_to("← Dashboard", account_dashboard_path, class: "text-sm text-base-content/70 hover:text-primary")
                h1(class: "font-bold text-base-content") { "Invitations" }
              end
            end

            # Two-column layout: form on left, pending on right
            div(class: "grid grid-cols-1 lg:grid-cols-2 gap-6") do
              # Invitation form - left column
              div(class: "bg-base-200 rounded-box p-4") do
                h2(class: "font-semibold text-base-content mb-3") { "Send New Invitation" }

                # Use a simple form without the complex form object for now
                form_with(url: account_invitations_path, local: true, class: "space-y-3") do |f|
                  div(class: "form-control w-full") do
                    f.label :email, class: "label" do
                      span(class: "label-text text-sm font-medium") { "Email" }
                    end
                    f.email_field :email, class: "input input-bordered w-full",
                      placeholder: "user@example.com", required: true
                  end

                  div do
                    label(class: "label cursor-pointer justify-start gap-2") do
                      f.check_box :admin, class: "checkbox checkbox-primary checkbox-sm"
                      span(class: "label-text text-sm") { "Grant admin privileges" }
                    end
                  end

                  div(class: "form-control w-full") do
                    f.label :message, class: "label" do
                      span(class: "label-text text-sm font-medium") { "Message (optional)" }
                    end
                    f.text_area :message, class: "textarea textarea-sm textarea-bordered w-full",
                      rows: 2, placeholder: "Personal message...", maxlength: 500
                  end

                  f.submit "Send Invitation", class: "btn btn-primary w-full"
                end
              end

              # Pending invitations - right column
              div(class: "bg-base-200 rounded-box p-4") do
                div(class: "flex items-center justify-between mb-3") do
                  h2(class: "font-semibold text-base-content") { "Pending (#{@pending_users.count})" }
                  if @pending_users.any?
                    span(class: "text-xs text-base-content/70") { "waiting for verification" }
                  end
                end

                if @pending_users.any?
                  div(class: "space-y-1") do
                    @pending_users.each do |user|
                      div(class: "flex items-center justify-between py-2 px-2 rounded hover:bg-base-300 transition-colors") do
                        div(class: "flex items-center gap-2 flex-1 min-w-0") do
                          div(class: "avatar placeholder flex-shrink-0") do
                            div(class: "bg-warning text-warning-content w-6 h-6 rounded-full text-xs") do
                              span { user.email[0].upcase }
                            end
                          end
                          div(class: "min-w-0 flex-1") do
                            div(class: "font-medium text-sm truncate") { user.email }
                            div(class: "flex items-center gap-2 text-xs text-base-content/70") do
                              plain(time_ago_in_words(user.created_at) + " ago")
                              if user.account_admin_for?(Current.account)
                                span(class: "badge badge-primary badge-xs") { "admin" }
                              end
                            end
                          end
                        end

                        div(class: "flex gap-1 flex-shrink-0") do
                          button_to("↻", new_account_invitation_path,
                            params: { email: user.email },
                            method: :get,
                            class: "btn btn-ghost",
                            title: "Resend invitation")
                          button_to("✕", account_invitation_path(user),
                            method: :delete,
                            class: "btn btn-ghost text-error",
                            confirm: "Cancel invitation?",
                            title: "Cancel invitation")
                        end
                      end
                    end
                  end
                else
                  div(class: "text-center py-6 text-base-content/70") do
                    p(class: "text-sm") { "No pending invitations" }
                  end
                end
              end
            end

            # Quick stats at bottom
            if @pending_users.any?
              div(class: "mt-4 text-center text-xs text-base-content/70") do
                plain("#{pluralize(@pending_users.count, "invitation")} pending • ")
                plain("Invitations expire if not accepted within reasonable time")
              end
            end
          end
        end
      end
    end
  end
end
