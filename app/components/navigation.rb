# frozen_string_literal: true

module Components
  class Navigation < Base
    include Phlex::Rails::Helpers::LinkTo
    include Phlex::Rails::Helpers::ButtonTo

    def template
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
              button_to(
                "Sign out",
                session_path(Current.session),
                method: :delete,
                class: "text-muted hover:text-error"
              )
            end
          else
            # Guest navigation
            link_to("Sign in", sign_in_path, class: nav_link_class(sign_in_path))
            link_to("Sign up", sign_up_path, class: nav_link_class(sign_up_path))
          end
        end
      end

      script do
        plain(<<~JAVASCRIPT)
          // Simple mobile menu toggle
          document.addEventListener('DOMContentLoaded', function() {
            const toggle = document.getElementById('mobile-nav-toggle');
            const navLinks = document.getElementById('nav-links');
          #{'  '}
            if (toggle && navLinks) {
              toggle.addEventListener('click', function() {
                navLinks.classList.toggle('nav-links-open');
              });
            }
          });
        JAVASCRIPT
      end
    end

    private

    def nav_link_class(path)
      if request.path == path
        "text-foreground font-medium"
      else
        "text-muted hover:text-foreground"
      end
    end
  end
end
