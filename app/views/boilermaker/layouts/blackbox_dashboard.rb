# frozen_string_literal: true

module Views
  module Boilermaker
    module Layouts
      # Blackbox-themed dashboard layout
      # Pure grayscale, maximum density, tool energy
      # No decorations, no icons, text-only interface
      class BlackboxDashboard < DashboardBase
        def initialize(title: "Dashboard", user: nil, nav_items: nil, brand: "BLACKBOX")
          super(title: title)
          @user = user || "user@example.com"
          @nav_items = nav_items || default_nav_items
          @brand = brand
        end

        def theme_name = "blackbox"

        def polarity = "light"

        def header_content
          header(class: "pb-2 mb-3") {
            h1(class: "text-base font-semibold") { @title }
          }
        end

        def topbar_content
          div(class: "bb-topbar") {
            div(class: "bb-topbar-row text-xs justify-between") {
              div(class: "flex items-center gap-0") {
                a(href: "/", class: "bb-topbar-brand pr-4") { @brand }
                nav(class: "bb-menu") {
                  @nav_items.each do |item|
                    attrs = { href: item[:href], class: nav_link_classes(item) }
                    attrs[:aria] = { current: "page" } if item[:active]
                    a(**attrs) { item[:label] }
                  end
                }
              }
              div(class: "flex items-center gap-3", data: { controller: "theme" }) {
                button(
                  type: "button",
                  class: "text-muted cursor-pointer",
                  data: { action: "click->theme#toggle", "theme-target": "toggle" }
                ) { span { "LIGHT" } }
                span(class: "text-muted") { @user }
                a(href: "#", class: "text-muted") { "logout" }
              }
            }
          }
        end

        def footer_content
          footer(class: "mt-8 pt-2 border-t border-border-default text-xs text-muted") {
            plain @brand
          }
        end

        private

        def render_body(&block)
          body(class: "bg-surface text-body min-h-screen") {
            topbar_content
            div(class: "px-4 py-3") {
              header_content
              main { yield }
              footer_content
            }
          }
        end

        def default_nav_items
          [
            { label: "dashboard", href: "#", active: true },
            { label: "search", href: "#", active: false },
            { label: "settings", href: "#", active: false }
          ]
        end

        def nav_link_classes(item)
          base = "bb-menu-item"
          item[:active] ? "#{base} is-active" : base
        end
      end
    end
  end
end
