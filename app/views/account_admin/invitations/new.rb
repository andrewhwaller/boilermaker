# frozen_string_literal: true

module Views
  module AccountAdmin
    module Invitations
      class New < Views::Base
        include Phlex::Rails::Helpers::LinkTo
        include Phlex::Rails::Helpers::FormWith

        def initialize(invitation: nil)
          @invitation = invitation || InvitationForm.new
        end

        def view_template
          page_with_title("Send Invitation") do
            div(class: "space-y-6") do
              # Header
              div(class: "flex items-center justify-between mb-6") do
                h1(class: "text-2xl font-bold text-base-content") { "Send Invitation" }
                div(class: "flex gap-2") do
                  link_to("View Invitations", account_admin_invitations_path, class: "btn btn-outline")
                  link_to("Back to Dashboard", account_admin_dashboard_path, class: "btn btn-ghost")
                end
              end

              # Invitation form
              card do
                h2(class: "text-lg font-semibold text-base-content mb-6") { "Invite New User" }

                form_errors(@invitation)

                form_with(model: @invitation, url: account_admin_invitations_path, local: true, class: "space-y-4") do |f|
                  # Email field
                  div do
                    f.label :email, "Email Address", class: "label"
                    f.email_field :email, 
                      class: "input input-bordered w-full", 
                      required: true,
                      placeholder: "user@example.com",
                      value: params[:email] # Pre-fill from resend action
                    helper_text("Enter the email address of the person you want to invite.")
                  end

                  # Admin privilege toggle
                  div do
                    label(class: "label cursor-pointer justify-start gap-3") do
                      f.check_box :admin, class: "checkbox checkbox-primary"
                      div do
                        span(class: "label-text font-medium") { "Grant Admin Privileges" }
                        div(class: "text-xs text-base-content/70") do
                          "Allow this user to manage account settings and invite other users"
                        end
                      end
                    end
                  end

                  # Custom message field
                  div do
                    f.label :message, "Custom Message (Optional)", class: "label"
                    f.text_area :message, 
                      class: "textarea textarea-bordered w-full h-24",
                      placeholder: "Add a personal message to the invitation email...",
                      maxlength: 500
                    helper_text("Add a personal message to include in the invitation email (max 500 characters).")
                  end

                  # Submit actions
                  div(class: "flex gap-3 pt-4") do
                    f.submit "Send Invitation", class: "btn btn-primary"
                    link_to("Cancel", account_admin_invitations_path, class: "btn btn-outline")
                  end
                end
              end

              # Info card
              card do
                h3(class: "text-lg font-semibold text-base-content mb-4") { "How Invitations Work" }
                div(class: "space-y-3 text-sm text-base-content/70") do
                  div(class: "flex gap-3") do
                    span(class: "badge badge-primary badge-sm flex-shrink-0") { "1" }
                    p { "An invitation email is sent to the specified address with a secure signup link" }
                  end
                  
                  div(class: "flex gap-3") do
                    span(class: "badge badge-primary badge-sm flex-shrink-0") { "2" }
                    p { "The recipient clicks the link and completes their account setup" }
                  end
                  
                  div(class: "flex gap-3") do
                    span(class: "badge badge-primary badge-sm flex-shrink-0") { "3" }
                    p { "Once verified, they gain access to the account with the specified privileges" }
                  end
                end
              end
            end
          end
        end

        private

        def helper_text(text)
          div(class: "text-xs text-base-content/70 mt-1") { text }
        end
      end
    end
  end
end