# frozen_string_literal: true

class Components::SidebarNavigation < Components::Base
  include ApplicationHelper
  include NavigationHelpers

  def initialize(request: nil)
    @request = request
  end

  def view_template
    aside(class: "fixed left-0 top-0 h-screen w-64 bg-base-100 border-r border-base-300/50 font-mono text-sm flex flex-col") do
      # Header/Branding
      header_section if show_branding?

      # Navigation Links
      nav(class: "flex-1 overflow-y-auto") do
        navigation_section
      end

      # Footer Controls
      footer_section
    end
  end

  private

  def header_section
    div(class: "px-4 py-4 border-b border-base-300/50") do
      div(class: "flex items-center gap-3") do
        div(class: "w-2 h-8 bg-primary/70")
        div do
          h1(class: "font-mono font-bold tracking-wider uppercase text-sm text-base-content") { app_name }
          p(class: "text-xs text-base-content/60 tracking-wider") { "CONTROL PANEL" }
        end
      end
    end
  end

  def navigation_section
    div(class: "p-4") do
      if Current.user.present?
        authenticated_navigation
      else
        unauthenticated_navigation
      end
    end
  end

  def authenticated_navigation
    div(class: "space-y-2") do
      sidebar_nav_item(root_path, "DASHBOARD")

      if Rails.env.development?
        sidebar_nav_item("/components", "SHOWCASE")
        sidebar_nav_item("/boilermaker/settings", "CONFIG")
      end

      # Navigation separator
      div(class: "h-px bg-base-300/50 my-4")

      # User specific links
      sidebar_nav_item(settings_path, "SETTINGS")

      if Current.user&.account_admin_for? || Current.user&.admin?
        sidebar_nav_item(account_path, "ACCOUNT")
      end

      if Current.user&.admin?
        sidebar_nav_item(admin_path, "ADMIN")
      end
    end
  end

  def unauthenticated_navigation
    div(class: "space-y-2") do
      if feature_enabled?("user_registration")
        sidebar_nav_item(sign_up_path, "REGISTER")
      end

      sidebar_nav_item(sign_in_path, "ACCESS")
    end
  end

  def footer_section
    div(class: "p-4 border-t border-base-300/50 space-y-3") do
      # Theme toggle
      div(class: "flex justify-center") do
        render Components::ThemeToggle.new(show_label: true, position: :sidebar)
      end

      if Current.user.present?
        # User info and sign out
        div(class: "space-y-2") do
          div(class: "text-center") do
            p(class: "text-xs text-base-content/70 font-mono tracking-wider uppercase") { current_user_display_name }
          end

          if show_account_dropdown?
            # Show account info instead of dropdown in sidebar
            div(class: "text-center") do
              span(class: "text-xs text-base-content/50") { "ACCOUNT" }
            end
          end

          # Sign out button
          div(class: "flex justify-center") do
            a(href: session_path("current"),
              class: "btn btn-ghost btn-sm normal-case font-mono text-xs tracking-wider border-0 rounded-none text-error hover:bg-error/10 w-full text-center",
              data: { turbo_method: :delete }) do
              "EXIT SYSTEM"
            end
          end
        end
      end
    end
  end

  def sidebar_nav_item(path, label)
    a(href: path, class: sidebar_nav_item_class(path)) do
      span(class: "text-xs font-mono font-medium tracking-wider") { label }
    end
  end

  def sidebar_nav_item_class(path)
    nav_item_class(path, base_classes: "btn btn-sm w-full justify-start normal-case font-mono text-xs tracking-wider border-0 rounded-none")
  end
end
