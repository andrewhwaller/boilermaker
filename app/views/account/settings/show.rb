# frozen_string_literal: true

module Views
  module Account
    module Settings
      class Show < Views::Base
        include Phlex::Rails::Helpers::LinkTo
        include Phlex::Rails::Helpers::Pluralize
        include Phlex::Rails::Helpers::TimeAgoInWords

        def initialize(account:)
          @account = account
        end

        def view_template
          page_with_title("Settings") do
            # Compact header with inline editing
            div(class: "flex items-center justify-between mb-4") do
              div(class: "flex items-center gap-4") do
                link_to("← Dashboard", account_path, class: "text-sm text-base-content/70 hover:text-primary")
                h1(class: "text-xl font-bold text-base-content") { "Account Settings" }
              end
              link_to("Edit", edit_account_settings_path, class: "btn btn-primary")
            end

            # Single dense information panel
            div(class: "bg-base-200 rounded-box p-4") do
              div(class: "grid grid-cols-2 md:grid-cols-4 gap-6 mb-4") do
                info_item("Account", @account.name || "Unnamed Account")
                info_item("Users", pluralize(@account.users.count, "user"))
                info_item("Admins", pluralize(AccountMembership.for_account(@account).with_role(:admin).count, "admin"))
                info_item("Created", @account.created_at.strftime("%b %Y"))
              end

              # Status indicators row
              div(class: "flex items-center justify-between pt-3 border-t border-base-300") do
                div(class: "flex items-center gap-4 text-sm") do
                  status_indicator("Active", @account.users.where(verified: true).count, "text-success")
                  status_indicator("Pending", @account.users.where(verified: false).count, "text-warning")
                  if @account.users.where(verified: false).any?
                    link_to("Manage Pending →", account_invitations_path,
                      class: "text-xs text-primary hover:underline")
                  end
                end

                # Quick action buttons
                div(class: "flex gap-2") do
                  link_to("Invitations", account_invitations_path, class: "btn btn-ghost")
                  link_to("+ User", new_account_invitation_path, class: "btn btn-primary")
                end
              end
            end

            # Quick reference section - ultra compact
            div(class: "mt-4 text-xs text-base-content/70 text-center space-y-1") do
              div { "Account ID: #{@account.id} • Last updated #{time_ago_in_words(@account.updated_at)} ago" }
              if @account.users.any?
                div do
                  plain("Recent users: ")
                  @account.users.order(created_at: :desc).limit(3).each_with_index do |user, i|
                    plain(", ") if i > 0
                    plain(user.email.split("@").first)
                  end
                  plain("...") if @account.users.count > 3
                end
              end
            end
          end
        end

        private

        def info_item(label, value)
          div(class: "text-center") do
            div(class: "text-sm text-base-content/70") { label }
            div(class: "font-semibold text-base-content") { value }
          end
        end

        def status_indicator(label, count, color_class)
          span(class: "#{color_class}") do
            plain("#{count} #{label.downcase}")
          end
        end
      end
    end
  end
end
