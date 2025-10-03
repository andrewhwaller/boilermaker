module Components
  module Accounts
    class Switcher < Components::Base
      include Phlex::Rails::Helpers::ButtonTo

      INTERACTIVE_STATES = "hover:bg-base-300/40 focus-visible:bg-base-300/40 focus-visible:outline-none".freeze

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
          trigger: dropdown_trigger_options(trigger_label),
          menu: { class: "min-w-full w-auto" }
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
            span(class: item_classes(current: true)) { item_content(account, current: true) }
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
        span(class: "truncate flex-1 text-left") { account.name }
        indicator_classes = current ? "flex items-center justify-center w-4 h-4 text-primary" : "flex items-center justify-center w-4 h-4 opacity-0"

        span(class: indicator_classes, aria_hidden: true) do
          indicator_icon if current
        end
      end

      def item_classes(current: false)
        base = base_item_classes
        current ? "#{base} cursor-default" : "#{base} #{INTERACTIVE_STATES}"
      end

      def base_item_classes
        text_size = @align == :bottom ? "" : "text-xs"
        "flex w-full items-center gap-2 justify-start text-left #{text_size} font-medium px-3 py-2 rounded-none transition duration-150 tracking-wider uppercase"
      end

      def indicator_icon
        svg(viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_width: "1.5", class: "h-3 w-3") do |s|
          s.path(d: "M4.5 12.75l6 6 9-13.5", stroke_linecap: "round", stroke_linejoin: "round")
        end
      end

      def dropdown_trigger_options(trigger_label)
        width_class = @align == :bottom ? "w-full" : ""
        text_size = @align == :bottom ? "" : "text-xs"
        {
          class: "#{width_class} justify-between gap-2 normal-case tracking-wider rounded-none border-0 hover:bg-base-200",
          content: -> {
            span(class: "truncate uppercase #{text_size} font-medium") { trigger_label }
          }
        }
      end
    end
  end
end
