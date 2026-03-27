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
                link_to("← Dashboard", account_dashboard_path, class: "text-sm text-muted hover:text-accent")
                h1(class: "font-bold") { "Invitations" }
              end
            end

            # Two-column layout: form on left, pending on right
            div(class: "grid grid-cols-1 lg:grid-cols-2 gap-6") do
              # Invitation form - left column
              render Components::Card.new(title: "Send New Invitation") do
                  form_with(url: account_invitations_path, local: true, class: "space-y-3") do |f|
                    div do
                      f.label :email, class: "block text-sm font-medium mb-1" do
                        plain "Email"
                      end
                      f.email_field :email, class: "ui-input",
                        placeholder: "user@example.com", required: true
                    end

                    div do
                      label(class: "inline-flex items-center cursor-pointer gap-2") do
                        f.check_box :admin, class: "ui-checkbox"
                        span(class: "text-sm") { "Grant admin privileges" }
                      end
                    end

                    div do
                      f.label :message, class: "block text-sm font-medium mb-1" do
                        plain "Message (optional)"
                      end
                      f.text_area :message, class: "ui-textarea",
                        rows: 2, placeholder: "Personal message...", maxlength: 500
                    end

                    f.submit "Send Invitation", class: "ui-button ui-button-primary w-full"
                  end
              end

              # Pending invitations - right column
              render Components::Card.new(title: "Pending (#{@pending_users.count})") do
                  if @pending_users.any?
                    div(class: "space-y-1") do
                      @pending_users.each do |user|
                        div(class: "flex items-center justify-between py-2 px-2 hover:bg-hover transition-colors") do
                          div(class: "flex items-center gap-2 flex-1 min-w-0") do
                            div(class: "flex-shrink-0") do
                              div(class: "bg-warning text-on-accent w-6 h-6 rounded-full text-xs flex items-center justify-center") do
                                span { user.email[0].upcase }
                              end
                            end
                            div(class: "min-w-0 flex-1") do
                              div(class: "font-medium text-sm truncate") { user.email }
                              div(class: "flex items-center gap-2 text-xs text-muted") do
                                plain(time_ago_in_words(user.created_at) + " ago")
                                if user.account_admin_for?(Current.account)
                                  span(class: "ui-badge ui-badge-primary ui-badge-xs") { "admin" }
                                end
                              end
                            end
                          end

                          div(class: "flex gap-1 flex-shrink-0") do
                            button_to("↻", new_account_invitation_path,
                              params: { email: user.email },
                              method: :get,
                              class: "ui-button ui-button-ghost",
                              title: "Resend invitation")
                            button_to("✕", account_invitation_path(user),
                              method: :delete,
                              class: "ui-button ui-button-ghost text-destructive",
                              confirm: "Cancel invitation?",
                              title: "Cancel invitation")
                          end
                        end
                      end
                    end
                  else
                    div(class: "text-center py-6 text-muted") do
                      p(class: "text-sm") { "No pending invitations" }
                    end
                  end
              end
            end

            # Quick stats at bottom
            if @pending_users.any?
              div(class: "mt-4 text-center text-xs text-muted") do
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
