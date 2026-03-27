module Views
  module Accounts
    class Edit < Views::Base
      def initialize(account:)
        @account = account
      end

      def view_template
        div(class: "container mx-auto px-4 py-8 max-w-2xl") do
          h1(class: "text-3xl font-bold mb-8") { "Edit Account" }

          form_with(
            model: @account,
            url: account_path(@account),
            method: :patch,
            class: "space-y-6"
          ) do |form|
            div(class: "space-y-1") do
              label(class: "label") do
                span(class: "text-sm font-medium font-semibold") { "Account Name" }
              end
              input(
                type: "text",
                name: "account[name]",
                value: @account.name,
                class: "ui-input",
                required: true,
                autofocus: true
              )
              if @account.errors[:name].any?
                label(class: "label") do
                  span(class: "text-xs text-muted text-destructive") { @account.errors[:name].first }
                end
              end
            end

            div(class: "flex gap-4") do
              button(type: "submit", class: "ui-button ui-button-primary") { "Update Account" }
              a(href: account_path(@account), class: "ui-button ui-button-ghost") { "Cancel" }
            end
          end
        end
      end
    end
  end
end
