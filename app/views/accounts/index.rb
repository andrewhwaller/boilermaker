module Views
  module Accounts
    class Index < Views::Base
      def initialize(personal_accounts:, team_accounts:)
        @personal_accounts = personal_accounts
        @team_accounts = team_accounts
      end

      def view_template
        div(class: "container mx-auto px-4 py-8") do
          div(class: "flex justify-between items-center mb-8") do
            h1(class: "text-3xl font-bold") { "Your Accounts" }
            a(href: new_account_path, class: "ui-button ui-button-primary") { "Create Team" }
          end

          if @personal_accounts.any?
            section(class: "mb-8") do
              h2(class: "text-2xl font-semibold mb-4") { "Personal Accounts" }
              div(class: "grid gap-4") do
                @personal_accounts.each do |account|
                  render_account_card(account)
                end
              end
            end
          end

          if @team_accounts.any?
            section(class: "mb-8") do
              h2(class: "text-2xl font-semibold mb-4") { "Team Accounts" }
              div(class: "grid gap-4") do
                @team_accounts.each do |account|
                  render_account_card(account)
                end
              end
            end
          end

          if @personal_accounts.empty? && @team_accounts.empty?
            div(class: "ui-alert ui-alert-info") do
              span { "You don't belong to any accounts yet." }
            end
          end
        end
      end

      private

      def render_account_card(account)
        div(class: "ui-card bg-base-200 shadow-md") do
          div(class: "ui-card-content") do
            div(class: "flex justify-between items-start") do
              div do
                h3(class: "font-semibold text-lg") { account.name }
                if account.owner == Current.user
                  span(class: "ui-badge ui-badge-primary ui-badge-sm mt-2") { "Owner" }
                else
                  membership = Current.user.membership_for(account)
                  if membership&.admin?
                    span(class: "ui-badge ui-badge-secondary ui-badge-sm mt-2") { "Admin" }
                  else
                    span(class: "ui-badge ui-badge-ghost ui-badge-sm mt-2") { "Member" }
                  end
                end
              end
              div(class: "flex gap-2") do
                a(href: account_path(account), class: "ui-button ui-button-sm ui-button-ghost") { "View" }
              end
            end
          end
        end
      end
    end
  end
end
