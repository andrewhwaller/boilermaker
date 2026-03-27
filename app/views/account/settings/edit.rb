# frozen_string_literal: true

module Views
  module Account
    module Settings
      class Edit < Views::Base
        include Phlex::Rails::Helpers::LinkTo
        include Phlex::Rails::Helpers::FormWith

        def initialize(account:)
          @account = account
        end

        def view_template
          page_with_title("Edit Account Settings") do
            div(class: "space-y-6") do
              # Header
              div(class: "flex items-center justify-between mb-6") do
                h1(class: "font-bold text-body") { "Edit Account Settings" }
                div(class: "flex gap-2") do
                  link_to("View Settings", account_settings_path, class: "ui-button ui-button-outline")
                  link_to("Back to Dashboard", account_dashboard_path, class: "ui-button ui-button-ghost")
                end
              end

              # Settings form
              card do
                h2(class: "font-semibold text-body mb-6") { "Account Information" }

                form_errors(@account)

                form_with(model: @account, url: account_settings_path, local: true, class: "space-y-4") do |f|
                  # Account name field
                  div(class: "space-y-1") do
                    f.label :name, "Account Name", class: "label"
                    f.text_field :name,
                      class: "ui-input",
                      required: true,
                      placeholder: "Enter a name for this account"
                    helper_text("This name helps identify your account and appears in various places throughout the application.")
                  end

                  # Account information display
                  div(class: "bg-surface-alt p-4") do
                    h3(class: "font-semibold text-body mb-3") { "Account Information" }

                    div(class: "grid grid-cols-1 md:grid-cols-2 gap-4 text-sm") do
                      div do
                        span(class: "text-muted") { "Created: " }
                        span(class: "font-medium") { @account.created_at.strftime("%B %d, %Y") }
                      end

                      div do
                        span(class: "text-muted") { "Total Users: " }
                        span(class: "font-medium") { @account.members.count }
                      end

                      div do
                        span(class: "text-muted") { "Admin Users: " }
                        span(class: "font-medium") { @account.members.where(app_admin: true).count }
                      end

                      div do
                        span(class: "text-muted") { "Last Updated: " }
                        span(class: "font-medium") { @account.updated_at.strftime("%B %d, %Y") }
                      end
                    end
                  end

                  # Submit actions
                  div(class: "flex gap-3 pt-4") do
                    f.submit "Update Settings", class: "ui-button ui-button-primary"
                    link_to("Cancel", account_settings_path, class: "ui-button ui-button-outline")
                  end
                end
              end

              # Help section
              card do
                h3(class: "font-semibold text-body mb-4") { "About Account Settings" }
                div(class: "space-y-2 text-sm text-muted") do
                  p { "• Account Name: Used to identify your account throughout the application" }
                  p { "• Only account administrators can modify these settings" }
                  p { "• Changes to account settings affect all users in this account" }
                end
              end
            end
          end
        end

        private
      end
    end
  end
end
