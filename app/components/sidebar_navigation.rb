# frozen_string_literal: true

class Components::SidebarNavigation < Components::Base
  include ApplicationHelper
  include NavigationHelpers
  include Phlex::Rails::Helpers::ButtonTo

  def initialize(request: nil)
    @request = request
  end

  def view_template
    aside(class: "fixed left-0 top-0 h-screen w-64 bg-surface border-r border-border-light flex flex-col") do
      header_section if show_branding?

      nav(class: "flex-1 overflow-y-auto") do
        navigation_section
      end

      footer_section
    end
  end

  private

  def header_section
    div(class: "py-4 border-b border-border-light") do
      div(class: "flex items-center gap-3") do
        div(class: "w-2 h-8 bg-accent/70")
        div do
          h1(class: "font-bold text-sm text-body") { app_name }
          p(class: "text-xs text-muted ") { navigation_label("Control Panel") }
        end
      end
    end
  end

  def navigation_section
    div do
      if Current.user.present?
        authenticated_navigation
      else
        unauthenticated_navigation
      end
    end
  end

  def authenticated_navigation
    div do
      div(class: "py-4") do
        sidebar_nav_item(root_path, "Dashboard")

        if Rails.env.development?
          sidebar_nav_item("/components", "Showcase")
          sidebar_nav_item(boilermaker.edit_settings_path, "Config")
        end
      end

      div(class: "h-px bg-border-light")

      div(class: "py-4") do
        if Current.user.present? && Current.user.accounts&.many?
          render Components::Accounts::Switcher.new(current_account: Current.account, user: Current.user, align: :bottom)
        end

        sidebar_nav_item(settings_path, "Settings")

        if (Current.account && Current.user&.account_admin_for?(Current.account)) || Current.user&.app_admin?
          sidebar_nav_item(account_dashboard_path, "Account")
        end

        if Current.user&.app_admin?
          sidebar_nav_item(admin_path, "Admin")
        end
      end
    end
  end

  def unauthenticated_navigation
    div(class: "space-y-2") do
      if feature_enabled?("user_registration")
        sidebar_nav_item(sign_up_path, "Register")
      end

      sidebar_nav_item(sign_in_path, "Access")
    end
  end

  def footer_section
    div(class: "p-4 border-t border-border-light space-y-3") do
      div(class: "flex justify-center") do
        render Components::ThemeToggle.new(show_label: true, position: :sidebar)
      end

      if Current.user.present?
        button_to session_path("current"),
          method: :delete,
          class: "ui-button ui-button-ghost ui-button-sm text-xs text-destructive hover:bg-destructive/30 w-full text-center" do
          navigation_label("Exit System")
        end
      end
    end
  end

  def sidebar_nav_item(path, label)
    a(href: path, class: sidebar_nav_item_class(path)) { navigation_label(label) }
  end

  def sidebar_nav_item_class(path)
    nav_item_class(path, base_classes: "ui-button w-full justify-start border-0")
  end
end
