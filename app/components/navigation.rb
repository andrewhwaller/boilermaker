# frozen_string_literal: true

class Components::Navigation < Components::Base
  include ApplicationHelper

  def view_template
    nav(class: "border-b border-border p-4 flex items-center justify-between") do
      # Brand/Logo
      div do
        link_to("Boilermaker", root_path, class: "font-semibold text-foreground hover:text-secondary")
      end

      # Navigation links
      div(class: "flex items-center gap-4") do
        if Current.user.present?
          # Authenticated navigation
          link_to("Dashboard", root_path, class: nav_link_class(root_path))
          link_to("Account", edit_identity_email_path, class: nav_link_class(edit_identity_email_path))

          # User info and sign out
          div(class: "flex items-center gap-2 border-l border-border pl-4") do
            span(class: "text-sm text-muted") { Current.user.email }
            button_to("Sign out", session_path(Current.session), method: :delete, class: "text-muted hover:text-error")
          end
        else
          # Guest navigation
          link_to("Sign in", sign_in_path, class: nav_link_class(sign_in_path))
          link_to("Sign up", sign_up_path, class: nav_link_class(sign_up_path))
        end
      end
    end
  end
end
