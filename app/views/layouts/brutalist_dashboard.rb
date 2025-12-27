# frozen_string_literal: true

module Views
  module Layouts
    # Brutalist-themed dashboard layout
    # Minimal, raw, maximum content. Stark black/white with inverted hovers.
    class BrutalistDashboard < DashboardBase
      def initialize(title: "patentwatch", user: nil, nav_items: nil, status_info: nil)
        super(title: title)
        @user = user
        @nav_items = nav_items || default_nav_items
        @status = status_info || default_status_info
      end

      def default_status_info
        Views::Demos::SampleData::StatusInfo.new
      end

      def theme_name = "brutalist"
      def polarity = "light"

      def header_content
        header(class: "mb-8") {
          h1(class: "text-sm uppercase tracking-[0.15em] mb-1") { @title }
          div(class: "text-xs text-muted") {
            plain "USPTO Patent Monitoring // #{@user || 'user@company.com'} // #{Time.current.strftime('%Y-%m-%d')}"
          }
          nav(class: "mt-4") {
            @nav_items.each do |item|
              a(href: item[:href], class: "mr-4 text-sm") { "[#{item[:label]}]" }
            end
          }
        }
      end

      def footer_content
        # Keyboard shortcuts
        div(class: "text-[11px] text-muted mt-8") {
          span(class: "mr-4") { render_kbd("/"); plain " search" }
          span(class: "mr-4") { render_kbd("n"); plain " new alert" }
          span(class: "mr-4") { render_kbd("j"); plain "/"; render_kbd("k"); plain " navigate" }
          span { render_kbd("?"); plain " help" }
        }

        # Command input
        div(class: "mt-8 p-3 bg-inverse text-inverse") {
          div(class: "flex items-center gap-2 text-[13px]") {
            span(class: "text-muted") { "patentwatch>" }
            input(
              type: "text",
              placeholder: "search patents or type command...",
              class: "flex-1 bg-transparent border-none outline-none placeholder:text-muted/50",
              autofocus: true
            )
          }
        }

        # Footer info
        footer(class: "mt-12 pt-4 border-t border-border-light text-[11px] text-muted") {
          plain "#{@title} v#{@status.version} // #{@status.connected ? 'connected to' : 'disconnected from'} #{@status.connection_name.downcase} // #{@status.db_size} patents indexed // synced #{@status.last_sync}"
        }
      end

      private

      def render_body(&block)
        body(class: "bg-surface text-body min-h-screen p-8 max-w-[72ch]") {
          header_content
          hr(class: "border-t border-border-default my-6")
          main { yield }
          footer_content
        }
      end

      def render_kbd(key)
        kbd(class: "font-mono text-[10px] bg-surface-alt border border-border-default px-1") { key }
      end

      def default_nav_items
        [
          { label: "alerts", href: "#" },
          { label: "search", href: "#" },
          { label: "collections", href: "#" },
          { label: "settings", href: "#" },
          { label: "help", href: "#" }
        ]
      end
    end
  end
end
