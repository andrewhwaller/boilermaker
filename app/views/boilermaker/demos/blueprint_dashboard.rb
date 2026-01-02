# frozen_string_literal: true

module Views
  module Boilermaker
    module Demos
      # Blueprint theme demo page
      # Uses composition: renders the layout component rather than inheriting from it
      class BlueprintDashboard < Base
        def view_template
          render Views::Boilermaker::Layouts::BlueprintDashboard.new(
            title: "PATENTWATCH",
            description: "USPTO Patent Monitoring System — Alert Dashboard",
            user: "user@company",
            tabs: [
              { label: "Dashboard", href: "/demos/blueprint", active: true },
              { label: "Alerts", href: "#alerts" },
              { label: "Search", href: "#search" },
              { label: "Reports", href: "#reports" },
              { label: "Settings", href: "#settings" }
            ]
          ) {
            render_section_a_stats
            render_section_b_alerts
            render_dimension_line
            render_section_c_results
            render_section_d_history
          }
        end

        private

        # Section A: System Status
        def render_section_a_stats
          render Components::Boilermaker::SectionMarker.new(
            letter: "A",
            title: "SYSTEM STATUS",
            ref: "REF: SYS-001"
          ) {
            div(class: "grid grid-cols-4 gap-0 border border-accent mb-8") {
              sample_stats.each do |stat|
                stat_cell(stat.label, stat.value, highlight: stat.highlight)
              end
            }
          }
        end

        # Section B: Alert Configuration
        def render_section_b_alerts
          render Components::Boilermaker::SectionMarker.new(
            letter: "B",
            title: "ALERT CONFIGURATION SCHEDULE",
            ref: "REF: ALT-012"
          ) {
            table(class: "w-full text-[11px] border-collapse") {
              thead {
                tr {
                  th(class: "demo-table-th", style: "width: 40px;") { "REF" }
                  th(class: "demo-table-th") { "Alert Name" }
                  th(class: "demo-table-th", style: "width: 80px;") { "New" }
                  th(class: "demo-table-th", style: "width: 70px;") { "Status" }
                  th(class: "demo-table-th", style: "width: 90px;") { "Last Sync" }
                }
              }
              tbody {
                sample_alerts.each_with_index do |alert, idx|
                  alert_row("B.#{idx + 1}", alert.name, alert.count, alert.status, alert.time)
                end
              }
            }
          }
        end

        # Dimension line divider
        def render_dimension_line
          div(class: "flex items-center gap-2 my-4") {
            div(class: "flex-1 h-px bg-accent") { }
            span(class: "demo-label-wide text-accent") { "Latest Results — Machine Learning (B.1)" }
            div(class: "flex-1 h-px bg-accent") { }
          }
        end

        # Section C: Patent Results
        def render_section_c_results
          render Components::Boilermaker::SectionMarker.new(
            letter: "C",
            title: "PATENT RESULTS DETAIL",
            ref: "REF: RES-B1-001"
          ) {
            div(class: "border border-accent") {
              sample_patents.first(4).each do |patent|
                # Format ID with newline for blueprint style
                formatted_id = "#{patent.id[0..5]}\n#{patent.id[6..]}"
                result_row(formatted_id, patent.title, patent.assignee, patent.date, "#{patent.match}%")
              end
            }
          }
        end

        # Section D: Revision History
        def render_section_d_history
          render Components::Boilermaker::SectionMarker.new(
            letter: "D",
            title: "REVISION HISTORY",
            ref: "REF: LOG-001"
          ) {
            div(class: "text-[10px]") {
              revision_row("2024-12-25", "SYNC", "23 new matches for", "B.1 ML Image Recognition")
              revision_row("2024-12-25", "DIGEST", "Daily report sent to user@company.com", nil)
              revision_row("2024-12-24", "CONFIG", "Keywords modified for", "B.2 Battery Tech")
              revision_row("2024-12-24", "CREATE", "New alert", "B.4 Quantum Computing")
            }
          }
        end

        # Helper methods
        def stat_cell(label, value, highlight: false)
          div(class: "p-3 border-r border-surface-alt last:border-r-0 text-center") {
            div(class: "text-[9px] uppercase tracking-[0.05em] text-muted mb-1") { label }
            div(class: "text-xl font-bold #{highlight ? 'text-accent-alt' : 'text-accent'}") { value }
          }
        end

        def alert_row(ref, name, count, status, time)
          tr(class: "demo-row-hover") {
            td(class: "p-2.5 border-b border-border-light font-bold text-accent text-[10px] align-top") { ref }
            td(class: "p-2.5 border-b border-border-light font-medium align-top") {
              a(href: "#", class: "no-underline hover:text-accent hover:underline") { name }
            }
            td(class: "p-2.5 border-b border-border-light align-top") {
              if count > 0
                span(class: "inline-block px-1.5 py-0.5 text-[10px] font-semibold bg-accent-alt text-white") { "+#{count}" }
              else
                span(class: "inline-block px-1.5 py-0.5 text-[10px] bg-border-light text-muted") { "0" }
              end
            }
            td(class: "p-2.5 border-b border-border-light align-top") {
              if status == :active
                span(class: "inline-flex items-center gap-1 text-[10px]") {
                  span(class: "w-1.5 h-1.5 rounded-full bg-accent") { }
                  plain "Active"
                }
              else
                span(class: "inline-flex items-center gap-1 text-[10px] text-muted") {
                  span(class: "w-1.5 h-1.5 rounded-full bg-muted") { }
                  plain "Paused"
                }
              end
            }
            td(class: "p-2.5 border-b border-border-light text-muted text-[10px] align-top") { time }
          }
        end

        def result_row(id, title, assignee, date, match)
          div(class: "grid grid-cols-[80px_1fr_100px_70px_50px] gap-3 p-3 border-b border-border-light last:border-b-0 demo-row-hover items-start") {
            span(class: "font-bold text-accent text-[10px] whitespace-pre-line") {
              a(href: "#", class: "hover:underline") { id }
            }
            span(class: "text-[11px] leading-snug") { title }
            span(class: "text-[10px] text-muted") { assignee }
            span(class: "text-[10px] text-muted") { date }
            span(class: "text-[11px] font-bold text-accent") { match }
          }
        end

        def revision_row(date, action, message, ref)
          div(class: "flex gap-4 py-1.5 border-b border-dotted border-border-light") {
            span(class: "text-muted min-w-[80px]") { date }
            span {
              plain "#{action} — #{message}"
              if ref
                plain " "
                span(class: "text-accent font-medium") { ref }
              end
            }
          }
        end
      end
    end
  end
end
