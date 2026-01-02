# frozen_string_literal: true

module Views
  module Boilermaker
    module Layouts
      # Terminal-themed dashboard layout
      # Green phosphor CRT aesthetic with scanlines and glow effects
      class TerminalDashboard < DashboardBase
        def initialize(title: "PATENTWATCH", version: "v1.0.0", user: nil, status_info: nil)
          super(title: title)
          @version = version
          @user = user
          @status = status_info || default_status_info
        end

        def default_status_info
          Views::Boilermaker::Demos::SampleData::StatusInfo.new(latency: "42ms")
        end

        def theme_name = "terminal"
        def polarity = "dark"

        def header_content
          header(class: "max-w-[900px] mx-auto px-6 pt-6 border-b border-border-light pb-4 mb-6") {
            div(class: "flex justify-between items-center") {
              div(class: "text-xs tracking-[0.15em]") {
                span(class: "text-accent") { @title }
                span(class: "text-muted") { " #{@version} // USPTO MONITOR" }
              }
              div(class: "text-[11px] text-muted") {
                plain @user || "user@company.com"
                plain " | SESSION "
                span(class: "text-accent") { "4a7f2" }
              }
            }
            nav(class: "flex gap-6 mt-3 text-xs") {
              nav_link("alerts", active: true)
              nav_link("search")
              nav_link("collections")
              nav_link("settings")
              nav_link("help")
            }
          }
        end

        def footer_content
          # Status bar
          div(class: "fixed bottom-12 left-6 right-6 flex justify-between text-[10px] text-muted") {
            span(class: "before:content-['●_'] before:text-accent") {
              "#{@status.connection_name} CONNECTION #{@status.connected ? 'ESTABLISHED' : 'DISCONNECTED'}"
            }
            status_parts = [ "LAST SYNC: #{@status.last_sync.upcase}", "DB: #{@status.db_size} RECORDS" ]
            status_parts << "LATENCY: #{@status.latency}" if @status.latency
            span { status_parts.join(" | ") }
          }

          # Command input bar
          div(class: "fixed bottom-0 left-0 right-0 bg-surface-alt border-t border-border-light") {
            div(class: "max-w-[900px] mx-auto px-6 py-3 flex items-center gap-2 text-[13px]") {
              span(class: "text-accent") { "patentwatch $" }
              input(
                type: "text",
                placeholder: "type command or search query...",
                class: "flex-1 bg-transparent border-none outline-none text-accent placeholder:text-muted"
              )
              span(class: "w-2 h-4 bg-accent animate-pulse") { }
            }
          }
        end

        private

          def render_body(&block)
            body(class: "bg-surface text-body min-h-screen pb-24") {
              header_content
              main(class: "max-w-[900px] mx-auto px-6") { yield }
              footer_content
            }
          end

          def nav_link(text, active: false)
            a(
              href: "#",
              class: active ? "text-accent before:content-['>_']" : "text-muted hover:text-accent"
            ) { text }
          end
      end
    end
  end
end
