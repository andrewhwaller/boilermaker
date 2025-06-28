# Main application layout component
# Equivalent to layouts/application.html.erb but using Phlex
class Layouts::ApplicationLayout < Phlex::HTML
  def initialize(title: "Boilermaker", **attrs)
    @title = title
    @attrs = attrs
  end

  def view_template(&block)
    doctype
    html(lang: "en") do
      head do
        meta(charset: "utf-8")
        meta(name: "viewport", content: "width=device-width,initial-scale=1")

        title { @title }

        # CSRF meta tags
        csrf_meta_tags
        csp_meta_tag

        # Stylesheets
        stylesheet_link_tag "tailwind", "inter-font", "data-turbo-track": "reload"

        # PWA manifest
        tag(:link, rel: "manifest", href: "/pwa/manifest.json")

        # JavaScript
        javascript_importmap_tags
      end

      body(class: "bg-background text-foreground") do
        render_navigation

        main(&block)
      end
    end
  end

  private

  def render_navigation
    nav(class: "bg-nav border-b border-border") do
      div(class: "max-w-7xl mx-auto px-4 sm:px-6 lg:px-8") do
        div(class: "flex justify-between items-center h-16") do
          # Logo/Brand
          div(class: "flex-shrink-0") do
            a(href: "/", class: "text-xl font-bold text-primary") { "Boilermaker" }
          end

          # Navigation Links
          div(class: "hidden md:block") do
            div(class: "ml-10 flex items-baseline space-x-4") do
              # Add navigation items here as needed
            end
          end

          # User Menu
          if Current.user
            div(class: "flex items-center space-x-4") do
              span(class: "text-sm") { "Hello, #{Current.user.email}" }
              a(href: "/sessions", class: "btn-link", data: { "turbo-method": "delete" }) { "Sign out" }
            end
          else
            div(class: "flex items-center space-x-4") do
              a(href: "/sign_in", class: "btn-link") { "Sign in" }
              a(href: "/sign_up", class: "btn-link") { "Sign up" }
            end
          end
        end
      end
    end
  end
end
