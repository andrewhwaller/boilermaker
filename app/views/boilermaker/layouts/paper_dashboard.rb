# frozen_string_literal: true

module Views
  module Boilermaker
    module Layouts
      # Paper-themed dashboard layout
      # Clean, minimal design similar to a printed document
      class PaperDashboard < DashboardBase
        def theme_name = "paper"
        def polarity = "light"

        def header_content
          header(class: "max-w-4xl mx-auto px-6 pt-6 mb-6") {
            div(class: "flex justify-between items-center border-b-2 border-border-default pb-3") {
              span(class: "font-bold text-sm tracking-[0.08em]") { @title }
              nav(class: "flex gap-6") {
                a(href: "#", class: "text-xs text-muted hover:text-body") { "Alerts" }
                a(href: "#", class: "text-xs text-muted hover:text-body") { "Search" }
                a(href: "#", class: "text-xs text-muted hover:text-body") { "Settings" }
              }
              span(class: "text-xs text-muted") { "user@company.com" }
            }
          }
        end

        def footer_content
          footer(class: "max-w-4xl mx-auto px-6 py-6 mt-8 border-t border-border-light text-[10px] text-muted flex justify-between") {
            div(class: "flex gap-4") {
              span(class: "flex items-center gap-1") {
                span(class: "w-1.5 h-1.5 bg-accent-alt rounded-full") { }
                plain "USPTO connected"
              }
              span { "Last sync: 2m ago" }
              span { "18.4M patents" }
            }
            span { "PATENTWATCH v1.0" }
          }
        end
      end
    end
  end
end
