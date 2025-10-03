module Views
  module Accounts
    class Show < Views::Base
      def initialize(account:)
        @account = account
      end

      def view_template
        div(class: "container mx-auto px-4 py-8") do
          div(class: "flex justify-between items-start mb-8") do
            div do
              h1(class: "text-3xl font-bold") { @account.name }
              div(class: "flex gap-2 mt-2") do
                if @account.personal?
                  span(class: "badge badge-primary") { "Personal" }
                else
                  span(class: "badge badge-secondary") { "Team" }
                end

                if @account.owner == Current.user
                  span(class: "badge badge-accent") { "Owner" }
                end
              end
            end

            if @account.owner == Current.user
              div(class: "flex gap-2") do
                a(href: edit_account_path(@account), class: "btn btn-primary") { "Edit" }
              end
            end
          end

          div(class: "grid gap-6") do
            # Account info card
            div(class: "card bg-base-200 shadow-md") do
              div(class: "card-body") do
                h2(class: "card-title") { "Account Information" }
                div(class: "space-y-2") do
                  p do
                    strong { "Owner: " }
                    span { @account.owner.email }
                  end
                  p do
                    strong { "Members: " }
                    span { @account.members.count }
                  end
                  p do
                    strong { "Type: " }
                    span { @account.personal? ? "Personal Account" : "Team Account" }
                  end
                end
              end
            end

            # Conversion options (only for owner)
            if @account.owner == Current.user
              div(class: "card bg-base-200 shadow-md") do
                div(class: "card-body") do
                  h2(class: "card-title") { "Account Type" }

                  if @account.personal?
                    p(class: "mb-4") { "Convert this personal account to a team account to invite members." }
                    form(action: account_conversion_to_team_path(@account), method: "post") do
                      button(
                        type: "submit",
                        class: "btn btn-primary",
                        data: { turbo_confirm: "Convert #{@account.name} to a team account?" }
                      ) { "Convert to Team" }
                    end
                  else
                    if @account.can_convert_to_personal?(Current.user)
                      p(class: "mb-4") { "Convert this team account to a personal account. This will prevent inviting new members." }
                      form(action: account_conversion_to_personal_path(@account), method: "post") do
                        button(
                          type: "submit",
                          class: "btn btn-warning",
                          data: { turbo_confirm: "Convert #{@account.name} to a personal account?" }
                        ) { "Convert to Personal" }
                      end
                    else
                      div(class: "alert alert-warning") do
                        span { "Cannot convert: remove all other members first (must be only member)." }
                      end
                    end
                  end
                end
              end

              div(class: "card bg-error text-error-content shadow-md") do
                div(class: "card-body") do
                  h2(class: "card-title") { "Danger Zone" }
                  p(class: "mb-4") { "Deleting this account is permanent and cannot be undone." }
                  form(action: account_path(@account), method: "post") do
                    input(type: "hidden", name: "_method", value: "delete")
                    button(
                      type: "submit",
                      class: "btn btn-outline btn-error",
                      data: { turbo_confirm: "Are you sure? This cannot be undone." }
                    ) { "Delete Account" }
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
