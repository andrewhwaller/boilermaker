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
    "#{base_item_classes} #{INTERACTIVE_STATES}"
  end

 def base_item_classes
 text_size = @align == :bottom ? "" : "text-xs"
 "flex w-full items-center gap-2 justify-start text-left #{text_size} font-medium px-3 py-2 rounded-none transition duration-150 "
 end

 def dropdown_trigger_options(trigger_label)
 width_class = @align == :bottom ? "w-full" : ""
 text_size = @align == :bottom ? "" : "text-xs"
 {
 class: "#{width_class} justify-between gap-2 rounded-none border-0 hover:bg-base-200",
 content: -> {
 span(class: "truncate #{text_size} font-medium ") { trigger_label }
 }
 }
 end
 end
 end
end
