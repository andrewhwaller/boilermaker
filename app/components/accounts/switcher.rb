module Components
  module Accounts
    class Switcher < Components::Base
      include Phlex::Rails::Helpers::FormAuthenticityToken

      def initialize(current_account:, user:)
        @current_account = current_account
        @user = user
      end

      def view_template
        return unless @user.accounts.many?

        div(class: "dropdown dropdown-end", tabindex: "0") do
          button(
            type: "button",
            class: "btn btn-ghost gap-2"
          ) do
            span(class: "font-mono text-sm") { @current_account&.name || "Select Account" }
            svg(
              xmlns: "http://www.w3.org/2000/svg",
              fill: "none",
              viewBox: "0 0 24 24",
              stroke_width: "1.5",
              stroke: "currentColor",
              class: "w-4 h-4"
            ) do |s|
              s.path(
                stroke_linecap: "round",
                stroke_linejoin: "round",
                d: "M8.25 15L12 18.75 15.75 15m-7.5-6L12 5.25 15.75 9"
              )
            end
          end

          ul(class: "dropdown-content menu bg-base-200 rounded-box z-[1] w-64 p-2 shadow-lg mt-2") do
            if personal_accounts.any?
              li(class: "menu-title") do
                span { "Personal Accounts" }
              end
              personal_accounts.each do |account|
                render_account_item(account)
              end
              li(class: "my-1") { hr }
            end

            if team_accounts.any?
              li(class: "menu-title") do
                span { "Team Accounts" }
              end
              team_accounts.each do |account|
                render_account_item(account)
              end
              li(class: "my-1") { hr }
            end

            li do
              a(href: new_account_path, class: "gap-2") do
                svg(
                  xmlns: "http://www.w3.org/2000/svg",
                  fill: "none",
                  viewBox: "0 0 24 24",
                  stroke_width: "1.5",
                  stroke: "currentColor",
                  class: "w-4 h-4"
                ) do |s|
                  s.path(
                    stroke_linecap: "round",
                    stroke_linejoin: "round",
                    d: "M12 4.5v15m7.5-7.5h-15"
                  )
                end
                span { "Create Team" }
              end
            end

            li do
              a(href: accounts_path, class: "gap-2") do
                svg(
                  xmlns: "http://www.w3.org/2000/svg",
                  fill: "none",
                  viewBox: "0 0 24 24",
                  stroke_width: "1.5",
                  stroke: "currentColor",
                  class: "w-4 h-4"
                ) do |s|
                  s.path(
                    stroke_linecap: "round",
                    stroke_linejoin: "round",
                    d: "M9.594 3.94c.09-.542.56-.94 1.11-.94h2.593c.55 0 1.02.398 1.11.94l.213 1.281c.063.374.313.686.645.87.074.04.147.083.22.127.324.196.72.257 1.075.124l1.217-.456a1.125 1.125 0 011.37.49l1.296 2.247a1.125 1.125 0 01-.26 1.431l-1.003.827c-.293.24-.438.613-.431.992a6.759 6.759 0 010 .255c-.007.378.138.75.43.99l1.005.828c.424.35.534.954.26 1.43l-1.298 2.247a1.125 1.125 0 01-1.369.491l-1.217-.456c-.355-.133-.75-.072-1.076.124a6.57 6.57 0 01-.22.128c-.331.183-.581.495-.644.869l-.213 1.28c-.09.543-.56.941-1.11.941h-2.594c-.55 0-1.02-.398-1.11-.94l-.213-1.281c-.062-.374-.312-.686-.644-.87a6.52 6.52 0 01-.22-.127c-.325-.196-.72-.257-1.076-.124l-1.217.456a1.125 1.125 0 01-1.369-.49l-1.297-2.247a1.125 1.125 0 01.26-1.431l1.004-.827c.292-.24.437-.613.43-.992a6.932 6.932 0 010-.255c.007-.378-.138-.75-.43-.99l-1.004-.828a1.125 1.125 0 01-.26-1.43l1.297-2.247a1.125 1.125 0 011.37-.491l1.216.456c.356.133.751.072 1.076-.124.072-.044.146-.087.22-.128.332-.183.582-.495.644-.869l.214-1.281z"
                  )
                  s.path(
                    stroke_linecap: "round",
                    stroke_linejoin: "round",
                    d: "M15 12a3 3 0 11-6 0 3 3 0 016 0z"
                  )
                end
                span { "Manage Accounts" }
              end
            end
          end
        end
      end

      private

      def personal_accounts
        @personal_accounts ||= @user.accounts.personal.order(:name)
      end

      def team_accounts
        @team_accounts ||= @user.accounts.team.order(:name)
      end

      def render_account_item(account)
        if account == @current_account
          li(class: "disabled") do
            a(class: "active gap-2") do
              span(class: "font-mono") { account.name }
              span(class: "badge badge-sm badge-primary") { "CURRENT" }
            end
          end
        else
          li do
            form(
              action: account_switches_path,
              method: "post",
              class: "w-full"
            ) do
              input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
              input(type: "hidden", name: "account_id", value: account.id)
              button(
                type: "submit",
                class: "w-full text-left font-mono"
              ) do
                account.name
              end
            end
          end
        end
      end
    end
  end
end
