# frozen_string_literal: true

class Components::Navigation < Components::Base
  include ApplicationHelper
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::CurrentPage
  include Phlex::Rails::Helpers::ButtonTo

  def view_template
    nav(class: "border-b border-border p-4 flex items-center justify-between") do
      render_branding if show_branding?
      render_navigation_links
    end
  end

  private

  def render_branding
    div do
      link_to(app_name, root_path, class: "text-lg font-semibold text-foreground hover:text-secondary")
    end
  end

  def render_navigation_links
    div(class: "flex items-center gap-6") do
      if Current.user.present?
        render_authenticated_links
      else
        render_unauthenticated_links
      end
    end
  end

  def render_authenticated_links
    link_to("Dashboard", root_path, class: nav_link_class(root_path))

    if show_account_dropdown?
      link_to("Account", edit_identity_email_path, class: nav_link_class(edit_identity_email_path))
    end

    # Development-only Boilermaker UI link
    if Rails.env.development?
      link_to("Boilermaker UI", "/boilermaker/settings", class: nav_link_class("/boilermaker/settings"))
    end

    div(class: "ml-auto") do
      button_to("Sign out", session_path(Current.session), method: :delete)
    end
  end

  def render_unauthenticated_links
    if feature_enabled?("user_registration")
      link_to("Sign up", sign_up_path, class: nav_link_class(sign_up_path))
    end

    link_to("Sign in", sign_in_path, class: nav_link_class(sign_in_path))
  end

  # Configuration-based helper methods
  def show_branding?
    boilermaker_config.get("ui.navigation.show_branding") != false
  end

  def show_account_dropdown?
    boilermaker_config.get("ui.navigation.show_account_dropdown") != false
  end
end
