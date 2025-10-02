module Views
  module Accounts
    class New < ApplicationView
      def initialize(account:)
        @account = account
      end

      def view_template
        div(class: "container mx-auto px-4 py-8 max-w-2xl") do
          h1(class: "text-3xl font-bold mb-8") { "Create Team Account" }

          form_with(
            model: @account,
            url: accounts_path,
            class: "space-y-6"
          ) do |form|
            div(class: "form-control") do
              label(class: "label") do
                span(class: "label-text font-semibold") { "Team Name" }
              end
              input(
                type: "text",
                name: "account[name]",
                placeholder: "Acme Corp",
                class: "input input-bordered w-full",
                required: true,
                autofocus: true
              )
              if @account.errors[:name].any?
                label(class: "label") do
                  span(class: "label-text-alt text-error") { @account.errors[:name].first }
                end
              end
            end

            div(class: "flex gap-4") do
              button(type: "submit", class: "btn btn-primary") { "Create Team" }
              a(href: accounts_path, class: "btn btn-ghost") { "Cancel" }
            end
          end
        end
      end
    end
  end
end
