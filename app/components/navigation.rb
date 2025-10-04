# frozen_string_literal: true

class Components::Navigation < Components::Base
 include ApplicationHelper
 include NavigationHelpers
 include Phlex::Rails::Helpers::ButtonTo

 def initialize(request: nil)
 @request = request
 end

 def view_template
 nav(class: "bg-base-100 border-b border-base-300/50 px-4 py-1 text-sm", data_controller: "navigation") do
 # Desktop navigation
 div(class: "hidden md:flex items-center justify-between w-full") do
 div(class: "flex items-center gap-6") do
 branding if show_branding?
 navigation_section
 end
 controls_section
 end

 # Mobile navigation
 div(class: "md:hidden flex items-center justify-between w-full") do
 div(class: "flex items-center") { branding if show_branding? }
 mobile_menu_button
 end

 # Mobile menu (hidden by default)
 mobile_menu
 end
 end

 private

 def branding
 div(class: "flex items-center") do
 a(href: root_path, class: "flex items-center gap-2 text-base-content hover:text-primary transition-colors") do
 div(class: "w-1 h-6 bg-primary/70")
 span(class: "font-medium text-xs") { app_name }
 end
 end
 end

 def navigation_section
 if Current.user.present?
 authenticated_navigation
 end
 end

 def controls_section
 div(class: "flex items-center gap-4") do
 # Theme toggle
 render Components::ThemeToggle.new(show_label: true, position: :navbar)

 if Current.user.present? && Current.user.accounts&.many?
 render Components::Accounts::Switcher.new(current_account: Current.account, user: Current.user, align: :end)
 end

 if Current.user.present?
 authenticated_controls
 else
 unauthenticated_controls
 end
 end
 end

 def authenticated_navigation
 div(class: "flex items-center gap-1") do
 nav_item(root_path, "Dash")

 if Rails.env.development?
 nav_item("/components", "Showcase")
 nav_item("/boilermaker/settings", "Config")
 end
 end
 end

 def authenticated_controls
 if show_account_dropdown?
 account_dropdown
 else
 sign_out_button
 end
 end

 def unauthenticated_controls
 div(class: "flex items-center gap-1") do
 if feature_enabled?("user_registration")
 nav_item(sign_up_path, "Register")
 nav_separator
 end

 nav_item(sign_in_path, "Access")
 end
 end

 def account_dropdown
 render Components::DropdownMenu.new(trigger_text: current_user_display_name) do
 render Components::DropdownMenuItem.new(settings_path, "Settings")

 if (Current.account && Current.user&.account_admin_for?(Current.account)) || Current.user&.app_admin?
 render Components::DropdownMenuItem.new(account_dashboard_path, "Account", class: "text-primary")
 end

 if Current.user&.app_admin?
 render Components::DropdownMenuItem.new(admin_path, "Admin", class: "text-primary")
 end

 if Rails.env.development?
 render Components::DropdownMenuItem.new("/letter_opener", "Email Preview", target: "_blank")
 end

 render Components::DropdownMenuItem.new(session_path("current"), "Sign out", method: :delete, class: "text-error")
 end
 end


 def nav_link_class(path)
 base_classes = "link link-hover text-sm"
 # Avoid current_page? here to prevent requiring full Rails request context in tests
 "#{base_classes} text-base-content/70"
 end

 # Industrial-style navigation helpers
 def nav_item(path, label)
 a(href: path, class: nav_item_class(path)) do
 span(class: "text-xs font-medium ") { navigation_label(label) }
 end
 end


 def nav_separator
 div(class: "w-px h-4 bg-base-300/50")
 end

 def sign_out_button
 button_to session_path("current"),
 method: :delete,
 class: "btn btn-ghost btn-sm text-xs border-0 rounded-none text-error hover:bg-error/10" do
 navigation_label("Exit")
 end
 end

 # Mobile navigation methods
 def mobile_menu_button
 button(
 class: "btn btn-ghost btn-sm rounded-none border-base-300 hover:bg-base-200",
 type: "button",
 data_action: "click->navigation#toggleMobileMenu"
) do
 # Industrial-style hamburger menu
 div(class: "flex flex-col gap-1") do
 3.times { div(class: "w-4 h-px bg-base-content") }
 end
 end
 end

 def mobile_menu
 div(
 class: "hidden md:hidden absolute top-full left-0 right-0 bg-base-100 border-b border-base-300/50 z-50",
 data_navigation_target: "mobileMenu"
) do
 div(class: "px-4 py-3 space-y-3") do
 if Current.user.present?
 mobile_authenticated_links
 else
 mobile_unauthenticated_links
 end
 end
 end
 end

 def mobile_authenticated_links
 div(class: "space-y-2") do
 mobile_nav_item(root_path, "Dashboard")

 if Rails.env.development?
 mobile_nav_item("/boilermaker/settings", "Config")
 mobile_nav_item("/components", "Showcase")
 end
 end

 div(class: "pt-3 mt-3 border-t border-base-300/50 flex items-center justify-between") do
 render Components::ThemeToggle.new(show_label: false, position: :mobile)

 if show_account_dropdown?
 span(class: "text-xs text-base-content/70 ") { current_user_display_name }
 else
 button_to session_path("current"),
 method: :delete,
 class: "text-xs font-medium text-error border-0 bg-transparent" do
 navigation_label("Exit")
 end
 end
 end
 end

 def mobile_unauthenticated_links
 div(class: "space-y-2") do
 if feature_enabled?("user_registration")
 mobile_nav_item(sign_up_path, "Register")
 end

 mobile_nav_item(sign_in_path, "Access")
 end

 div(class: "pt-3 mt-3 border-t border-base-300/50") do
 render Components::ThemeToggle.new(show_label: false, position: :mobile)
 end
 end

 def mobile_nav_item(path, label)
 a(
 href: path,
 class: mobile_nav_item_class(path)
) do
 navigation_label(label)
 end
 end

 def mobile_nav_item_class(path)
 nav_item_class(path, base_classes: "btn btn-sm w-full justify-start text-xs border-0 rounded-none")
 end
end
