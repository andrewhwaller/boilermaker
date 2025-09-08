# frozen_string_literal: true

module Views
  module Admin
    module Accounts
      class Show < Views::Base
        include Phlex::Rails::Helpers::LinkTo
        include Phlex::Rails::Helpers::Pluralize

        def initialize(account:, members: [])
          @account = account
          @members = members
        end

        def view_template
          page_with_title("Account") do
            div(class: "flex items-center justify-between mb-4") do
              h1(class: "text-xl font-bold") { @account.name || "(unnamed)" }
              link_to("All Accounts", admin_accounts_path, class: "btn btn-sm")
            end

            div(class: "bg-base-200 rounded-box p-4 mb-4") do
              div { "ID: #{@account.id}" }
              div { "Users: #{pluralize(@account.users.count, 'user')}" }
            end

            h2(class: "font-semibold mb-2") { "Members" }
            if @members.any?
              ul(class: "menu bg-base-200 rounded-box p-2") do
                @members.each do |user|
                  li { link_to(user.email, admin_user_path(user)) }
                end
              end
            else
              div(class: "text-base-content/70") { "No members." }
            end
          end
        end
      end
    end
  end
end
