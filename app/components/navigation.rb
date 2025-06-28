# frozen_string_literal: true

class Components::Navigation < Components::Base
  include ApplicationHelper
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::CurrentPage
  include Phlex::Rails::Helpers::ButtonTo

  def view_template
    nav(class: "border-b border-border p-4 flex items-center justify-between") do
      div do
        link_to("Boilermaker", root_path, class: "text-lg font-semibold text-foreground hover:text-secondary")
      end

      div(class: "flex items-center gap-6") do
        if Current.user.present?
          link_to("Dashboard", root_path, class: nav_link_class(root_path))
          link_to("Account", edit_identity_email_path, class: nav_link_class(edit_identity_email_path))

          div(class: "ml-auto") do
            button_to("Sign out", session_path(Current.session), method: :delete)
          end
        else
          link_to("Sign in", sign_in_path, class: nav_link_class(sign_in_path))
          link_to("Sign up", sign_up_path, class: nav_link_class(sign_up_path))
        end
      end
    end
  end
end
