module Components
  module Accounts
    class Switcher < Components::Base
      include Phlex::Rails::Helpers::ButtonTo

      def initialize(current_account:, user:, align: :top)
        @current_account = current_account
        @user = user
        @align = align
      end

      def view_template
        accounts = @user.accounts.order(:name)
        return unless accounts.many?

        trigger_label = @current_account&.name || "Select Account"

        render Components::DropdownMenu.new(
          align: @align,
          class: "dropdown w-full",
          trigger_text: trigger_label,
          menu_options: { class: "min-w-full w-auto" }
        ) do
          accounts.each do |account|
            render_account_item(account)
          end
        end
      end

      private

      def render_account_item(account)
        current = account == @current_account

        li(class: "rounded-none") do
          if current
            button(class: "#{item_classes} cursor-default", type: "button", disabled: true) { item_content(account, current: true) }
          else
            button_to(
              account_switches_path,
              params: { account_id: account.id },
              method: :post,
              class: item_classes,
              form_class: "contents"
            ) { item_content(account) }
          end
        end
      end

      def item_content(account, current: false)
        span(class: "flex items-center gap-2 w-full") do
          if current
            span(class: "w-2 h-2 bg-primary rounded-sm shrink-0")
          end
          span(class: "truncate flex-1 text-left") { account.name }
        end
      end

      def item_classes
        text_size = @align == :bottom ? "" : "text-xs"
        "flex w-full items-center gap-2 justify-start text-left #{text_size} font-medium px-3 py-2 rounded-none transition duration-150 hover:bg-muted/40 focus-visible:bg-muted/40 focus-visible:outline-none"
      end
    end
  end
end