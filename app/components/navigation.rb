# frozen_string_literal: true

class Components::Navigation < Components::Base
  include ApplicationHelper

  def view_template
    nav(class: "navbar bg-base-100 border-b border-base-300") do
      div(class: "navbar-start") { branding if show_branding? }
      div(class: "navbar-end w-full") { navigation_links }
    end
  end

  private

  def branding
    div do
      # Use a static path here to avoid requiring Rails route context in tests
      a(href: "/", class: "btn btn-ghost normal-case text-xl") { app_name }
    end
  end

  def navigation_links
    div(class: "flex items-center gap-4 ml-auto") do
      if Current.user.present?
        authenticated_links
      else
        unauthenticated_links
      end
    end
  end

  def authenticated_links
    a(href: "/", class: nav_link_class("/")) { "Dashboard" }

    # Development-only Boilermaker UI link
    if Rails.env.development?
      a(href: "/boilermaker/settings", class: nav_link_class("/boilermaker/settings")) { "Boilermaker UI" }
    end

    div(class: "ml-auto flex items-center gap-4") do
      # Theme toggle
      render Components::ThemeToggle.new(show_label: true, position: :navbar)

      if show_account_dropdown?
        account_dropdown
      else
        button(class: "btn btn-outline", type: "button") { "Sign out" }
      end
    end
  end

  def unauthenticated_links
    div(class: "ml-auto flex items-center gap-4") do
      # Theme toggle
      render Components::ThemeToggle.new(show_label: false, position: :navbar)

      if feature_enabled?("user_registration")
        a(href: "/sign_up", class: nav_link_class("/sign_up")) { "Sign up" }
      end

      a(href: "/sign_in", class: nav_link_class("/sign_in")) { "Sign in" }
    end
  end

  def account_dropdown
    render Components::DropdownMenu.new(trigger_text: current_user_display_name) do
      render Components::DropdownMenuItem.new("/settings", "Settings")

      if Current.user&.account_admin_for? || Current.user&.admin?
        render Components::DropdownMenuItem.new("/account", "Account", class: "text-primary")
      end

      if Current.user&.admin?
        render Components::DropdownMenuItem.new("/admin", "Admin", class: "text-primary")
      end

      if Rails.env.development?
        render Components::DropdownMenuItem.new("/letter_opener", "Email Preview", target: "_blank")
      end

      render Components::DropdownMenuItem.new("/sessions/current", "Sign out", method: :delete, class: "text-error")
    end
  end

  def current_user_display_name
    Current.user&.email&.split("@")&.first&.capitalize || "Account"
  end

  # Configuration-based helper methods
  def show_branding?
    boilermaker_config.get("ui.navigation.show_branding") != false
  end

  def show_account_dropdown?
    boilermaker_config.get("ui.navigation.show_account_dropdown") != false
  end

  def nav_link_class(path)
    base_classes = "link link-hover text-sm"
    # Avoid current_page? here to prevent requiring full Rails request context in tests
    "#{base_classes} text-base-content/70"
  end
end
