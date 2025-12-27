# frozen_string_literal: true

module Views
  module Demos
    class BlueprintDashboard < Views::Layouts::BlueprintDashboard
      def initialize
        super(
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
        )
      end

      def view_template
        super {
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
        render Components::SectionMarker.new(
          letter: "A",
          title: "SYSTEM STATUS",
          ref: "REF: SYS-001"
        ) {
          div(class: "grid grid-cols-4 gap-0 border border-accent mb-8") {
            stat_cell("New Matches", "47", alert: true)
            stat_cell("This Week", "183")
            stat_cell("Active Alerts", "12")
            stat_cell("Patents Indexed", "18.4M")
          }
        }
      end

      # Section B: Alert Configuration
      def render_section_b_alerts
        render Components::SectionMarker.new(
          letter: "B",
          title: "ALERT CONFIGURATION SCHEDULE",
          ref: "REF: ALT-012"
        ) {
          table(class: "w-full text-[11px] border-collapse") {
            thead {
              tr {
                th(class: "text-left px-2.5 py-2 text-[9px] uppercase tracking-[0.06em] text-accent font-semibold border-b-2 border-accent bg-surface-alt", style: "width: 40px;") { "REF" }
                th(class: "text-left px-2.5 py-2 text-[9px] uppercase tracking-[0.06em] text-accent font-semibold border-b-2 border-accent bg-surface-alt") { "Alert Name" }
                th(class: "text-left px-2.5 py-2 text-[9px] uppercase tracking-[0.06em] text-accent font-semibold border-b-2 border-accent bg-surface-alt", style: "width: 80px;") { "New" }
                th(class: "text-left px-2.5 py-2 text-[9px] uppercase tracking-[0.06em] text-accent font-semibold border-b-2 border-accent bg-surface-alt", style: "width: 70px;") { "Status" }
                th(class: "text-left px-2.5 py-2 text-[9px] uppercase tracking-[0.06em] text-accent font-semibold border-b-2 border-accent bg-surface-alt", style: "width: 90px;") { "Last Sync" }
              }
            }
            tbody {
              alert_row("B.1", "Machine Learning — Image Recognition", 23, :active, "2 min ago")
              alert_row("B.2", "Battery Technology — Solid State", 8, :active, "1 hr ago")
              alert_row("B.3", "Semiconductor — 3nm Process", 12, :active, "1 hr ago")
              alert_row("B.4", "Quantum Computing — Error Correction", 4, :active, "3 hr ago")
              alert_row("B.5", "Autonomous Vehicles — LIDAR", 0, :paused, "2 days ago")
            }
          }
        }
      end

      # Dimension line divider
      def render_dimension_line
        div(class: "flex items-center gap-2 my-4") {
          div(class: "flex-1 h-px bg-accent") {}
          span(class: "text-[10px] text-accent uppercase tracking-[0.1em]") { "Latest Results — Machine Learning (B.1)" }
          div(class: "flex-1 h-px bg-accent") {}
        }
      end

      # Section C: Patent Results
      def render_section_c_results
        render Components::SectionMarker.new(
          letter: "C",
          title: "PATENT RESULTS DETAIL",
          ref: "REF: RES-B1-001"
        ) {
          div(class: "border border-accent") {
            result_row("US2024\n0401234", "Neural Network Architecture for Real-Time Object Detection in Autonomous Systems", "Google LLC", "2024-12-18", "94%")
            result_row("US2024\n0398765", "Convolutional Layer Optimization for Edge Device Deployment", "Apple Inc.", "2024-12-17", "89%")
            result_row("US2024\n0396543", "Multi-Modal Feature Extraction for Medical Imaging Analysis", "NVIDIA Corp", "2024-12-16", "87%")
            result_row("US2024\n0394321", "Attention Mechanism for Fine-Grained Image Classification", "Meta Platforms", "2024-12-15", "82%")
          }
        }
      end

      # Section D: Revision History
      def render_section_d_history
        render Components::SectionMarker.new(
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
      def stat_cell(label, value, alert: false)
        div(class: "p-3 border-r border-surface-alt last:border-r-0 text-center") {
          div(class: "text-[9px] uppercase tracking-[0.05em] text-muted mb-1") { label }
          div(class: "text-xl font-bold #{alert ? 'text-accent-alt' : 'text-accent'}") { value }
        }
      end

      def alert_row(ref, name, count, status, time)
        tr(class: "hover:bg-surface-alt") {
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
                span(class: "w-1.5 h-1.5 rounded-full bg-accent") {}
                plain "Active"
              }
            else
              span(class: "inline-flex items-center gap-1 text-[10px] text-muted") {
                span(class: "w-1.5 h-1.5 rounded-full bg-muted") {}
                plain "Paused"
              }
            end
          }
          td(class: "p-2.5 border-b border-border-light text-muted text-[10px] align-top") { time }
        }
      end

      def result_row(id, title, assignee, date, match)
        div(class: "grid grid-cols-[80px_1fr_100px_70px_50px] gap-3 p-3 border-b border-border-light last:border-b-0 hover:bg-surface-alt items-start") {
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
