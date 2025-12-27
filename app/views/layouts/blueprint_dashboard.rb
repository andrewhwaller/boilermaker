# frozen_string_literal: true

module Views
  module Layouts
    # Blueprint-themed dashboard layout
    # Technical drawing aesthetic with title block and tabbed navigation
    class BlueprintDashboard < DashboardBase
      def initialize(title: "Dashboard", description: nil, user: nil, tabs: nil)
        super(title: title)
        @description = description
        @user = user
        @tabs = tabs || default_tabs
      end

      def theme_name = "blueprint"
      def polarity = "light"

      private

      def render_body(&block)
        body(class: "bg-surface text-body min-h-screen") {
          div(class: "page-container max-w-[900px] mx-auto min-h-screen pl-14 pr-10 py-10") {
            render Components::TitleBlock.new(
              title: @title.upcase,
              description: @description || "System Dashboard",
              user: @user || "user@company",
              date: Time.current.strftime("%Y-%m-%d"),
              revision: "1.0"
            )
            render Components::TabbedNav.new(tabs: @tabs) if @tabs.any?
            yield
            render_footer
          }
        }
      end

      def render_footer
        footer(class: "mt-10 pt-4 border-t-2 border-accent") {
          div(class: "flex justify-between text-[9px] text-muted") {
            div(class: "flex gap-4") {
              span {
                span(class: "text-accent") { "● " }
                plain "USPTO CONNECTION ESTABLISHED"
              }
              span { "LAST SYNC: 2 MIN AGO" }
              span { "DB: 18.4M RECORDS" }
            }
            span { "#{@title.upcase} v1.0 // SHEET 1 OF 1" }
          }
        }
      end

      def default_tabs
        [
          { label: "Dashboard", href: "/", active: true },
          { label: "Alerts", href: "/alerts" },
          { label: "Search", href: "/search" },
          { label: "Reports", href: "/reports" },
          { label: "Settings", href: "/settings" }
        ]
      end
    end
  end
end
