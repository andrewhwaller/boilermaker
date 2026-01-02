# frozen_string_literal: true

module Views
  module Boilermaker
    module Layouts
      # Amber-themed dashboard layout
      # Amber monochrome with menu bar, status bar, and F-key footer
      class AmberDashboard < DashboardBase
        def initialize(title: "PATENTWATCH", menu_items: nil, fkey_actions: nil, status_info: nil)
          super(title: title)
          @menu_items = menu_items || default_menu_items
          @fkey_actions = fkey_actions || default_fkey_actions
          @status = status_info || default_status_info
        end

        def default_status_info
          Views::Boilermaker::Demos::SampleData::StatusInfo.new(latency: "42ms")
        end

        def theme_name = "amber"
        def polarity = "dark"

        def header_content
          div(class: "max-w-[80ch] mx-auto") {
            # ASCII art header
            header(class: "text-center py-4") {
              pre(class: "text-[11px] leading-tight text-accent") {
                plain ascii_header
              }
              div(class: "text-xs text-muted mt-2") {
                "Licensed to: user@company.com │ Session ID: 4A7F2"
              }
            }

            # Menu bar
            render Components::Boilermaker::MenuBar.new(items: @menu_items)

            # Status bar
            div(class: "flex justify-between py-1 px-2 bg-muted text-surface text-xs mt-0") {
              span { "#{@status.connected ? '●' : '○'} #{@status.connection_name} #{@status.connected ? 'CONNECTED' : 'DISCONNECTED'}" }
              span { "Last Sync: #{@status.last_sync}" }
              span { "DB: #{@status.db_size} records" }
              span { "Latency: #{@status.latency}" } if @status.latency
            }
          }
        end

        def footer_content
          div(class: "max-w-[80ch] mx-auto") {
            # F-key bar
            render Components::Boilermaker::FkeyBar.new(actions: @fkey_actions)

            # Command line
            div(class: "mt-4 p-2 border-2 border-accent flex items-center gap-2") {
              span(class: "text-accent font-bold") { "C:\\PATENTWATCH>" }
              input(
                type: "text",
                class: "flex-1 bg-transparent border-none outline-none text-accent",
                autofocus: true
              )
              span(class: "w-2.5 h-4 bg-accent animate-pulse") { }
            }
          }
        end

        private

          def render_body(&block)
            body(class: "bg-surface text-body min-h-screen p-4") {
              header_content
              main(class: "max-w-[80ch] mx-auto py-4") { yield }
              footer_content
            }
          end

          def ascii_header
            <<~ASCII
          ╔═══════════════════════════════════════╗
          ║     P A T E N T W A T C H   v1.0      ║
          ║     USPTO Monitoring System           ║
          ╚═══════════════════════════════════════╝
        ASCII
          end

          def default_menu_items
            [
              { label: "Alerts", hotkey_index: 0, href: "#", active: true },
              { label: "Search", hotkey_index: 0, href: "#" },
              { label: "Collections", hotkey_index: 0, href: "#" },
              { label: "Settings", hotkey_index: 2, href: "#" },
              { label: "Help", hotkey_index: 0, href: "#" }
            ]
          end

          def default_fkey_actions
            {
              f1: "Help",
              f2: "New",
              f3: "Edit",
              f4: "Delete",
              f5: "Refresh",
              f6: "Export",
              f10: "Quit"
            }
          end
      end
    end
  end
end
