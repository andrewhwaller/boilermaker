module Components
  module Accounts
    class Switcher < Components::Base
      def initialize(current_account:, user:, &kwargs)
        @current_account = current_account
        @user = user
      end

      def view_template
        return unless @user.accounts.many?

        div(class: "dropdown dropdown-top", tabindex: "0") do
          button(
            type: "button",
            class: "btn gap-2 normal-case hover:bg-base-200 w-full justify-between tracking-wider rounded-none border-0"
          ) do
            span(class: "truncate uppercase") { @current_account&.name || "Select Account" }
            svg(
              xmlns: "http://www.w3.org/2000/svg",
              fill: "none",
              viewBox: "0 0 24 24",
              stroke_width: "1.5",
              stroke: "currentColor",
              class: "w-3 h-3 shrink-0"
            ) do |s|
              s.path(
                stroke_linecap: "round",
                stroke_linejoin: "round",
                d: "M8.25 15L12 18.75 15.75 15m-7.5-6L12 5.25 15.75 9"
              )
            end
          end

          ul(class: "dropdown-content menu bg-base-100 rounded-none z-[1] w-64 p-1 border border-base-300/50 mb-2") do
            @user.accounts.order(:name).each do |account|
              render_account_item(account)
            end
          end
        end
      end

      private

      def render_account_item(account)
        if account == @current_account
          li do
            a(class: "btn w-full justify-start normal-case tracking-wider border-0 rounded-none bg-base-300/50 hover:bg-base-300/50 cursor-default") do
              span(class: "tracking-wider uppercase") { account.name + " (current)" }
            end
          end
        else
          li do
            button(
              type: "submit",
              form: "switch_#{account.id}",
              class: "btn w-full justify-start normal-case font-mono tracking-wider border-0 rounded-none hover:bg-base-200"
            ) do
              span(class: "font-medium tracking-wider uppercase") { account.name }
            end
            form(
              id: "switch_#{account.id}",
              action: account_switches_path,
              method: "post",
              style: "display: none;"
            ) do
              input(type: "hidden", name: "account_id", value: account.id)
            end
          end
        end
      end
    end
  end
end
