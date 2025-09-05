# frozen_string_literal: true

class Components::Navigation < Components::Base
  include ApplicationHelper
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::CurrentPage
  include Phlex::Rails::Helpers::ButtonTo

  def view_template
    nav(class: "navbar bg-base-100 border-b border-base-300") do
      div(class: "navbar-start") { branding if show_branding? }
      div(class: "navbar-end w-full") { navigation_links }
    end 
  end

  private

  def branding
    div do
      link_to(app_name, root_path, class: "btn btn-ghost normal-case text-xl")
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
    link_to("Dashboard", root_path, class: nav_link_class(root_path))

    # Development-only Boilermaker UI link
    if Rails.env.development?
      link_to("Boilermaker UI", "/boilermaker/settings", class: nav_link_class("/boilermaker/settings"))
    end

    div(class: "ml-auto flex items-center gap-4") do
      # Theme toggle
      render Components::ThemeToggle.new(show_label: false, position: :navbar)

      if show_account_dropdown?
        account_dropdown
      else
        button_to("Sign out", session_path(Current.session), method: :delete,
                 class: "btn btn-outline btn-sm")
      end
    end
  end

  def unauthenticated_links
    div(class: "ml-auto flex items-center gap-4") do
      # Theme toggle
      render Components::ThemeToggle.new(show_label: false, position: :navbar)

      if feature_enabled?("user_registration")
        link_to("Sign up", sign_up_path, class: nav_link_class(sign_up_path))
      end

      link_to("Sign in", sign_in_path, class: nav_link_class(sign_in_path))
    end
  end

  def account_dropdown
    render Components::DropdownMenu.new(trigger_text: current_user_display_name) do
      render Components::DropdownMenuItem.new("Settings", settings_path)

      if Rails.env.development?
        render Components::DropdownMenuItem.new("Email Preview", "/letter_opener", target: "_blank")
      end

      render Components::DropdownMenuItem.new("Sign out", session_path(Current.session), method: :delete, class: "text-error")
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
    if current_page?(path)
      "#{base_classes} text-primary"
    else
      "#{base_classes} text-base-content/70"
    end
  end
end
