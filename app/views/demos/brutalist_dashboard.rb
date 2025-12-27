# frozen_string_literal: true

module Views
  module Demos
    class BrutalistDashboard < Views::Layouts::BrutalistDashboard
      def initialize
        super(title: "patentwatch")
      end

      def view_template
        super {
          render_stats
          render_alerts_section
          render_divider
          render_results_section
          render_divider
          render_log_section
        }
      end

      private

      def render_stats
        div(class: "text-xs mb-6") {
          span(class: "mr-6") {
            span(class: "font-semibold bg-inverse text-inverse px-1") { "47" }
            plain " new"
          }
          span(class: "mr-6") {
            span(class: "font-semibold") { "183" }
            plain " this week"
          }
          span(class: "mr-6") {
            span(class: "font-semibold") { "12" }
            plain " alerts"
          }
          span(class: "mr-6") {
            span(class: "font-semibold") { "18.4M" }
            plain " patents"
          }
          span { "synced 2m ago" }
        }
      end

      def render_alerts_section
        section(class: "mb-8") {
          h2(class: "text-[11px] uppercase tracking-wide text-muted mb-3") { "Active Alerts" }
          div(class: "text-xs") {
            alert_item(1, "Machine Learning — Image Recognition", "+23 new", "active", "2m ago")
            alert_item(2, "Battery Technology — Solid State", "+8 new", "active", "1h ago")
            alert_item(3, "Semiconductor — 3nm Process", "+12 new", "active", "1h ago")
            alert_item(4, "Quantum Computing — Error Correction", "+4 new", "active", "3h ago")
            alert_item(5, "Autonomous Vehicles — LIDAR", "0", "paused", "2d ago")
          }
        }
      end

      def render_results_section
        section(class: "mb-8") {
          h2(class: "text-[11px] uppercase tracking-wide text-muted mb-3") {
            "Latest: Machine Learning — Image Recognition (23 results)"
          }

          result_card("US20240401234A1", "94%", "Neural Network Architecture for Real-Time Object Detection in Autonomous Systems", "Google LLC", "2024-12-18", "G06N, G06T")
          result_card("US20240398765A1", "89%", "Convolutional Layer Optimization for Edge Device Deployment", "Apple Inc.", "2024-12-17", "G06N")
          result_card("US20240396543A1", "87%", "Multi-Modal Feature Extraction for Medical Imaging Analysis", "NVIDIA Corp", "2024-12-16", "G06T, G16H")
          result_card("US20240394321A1", "82%", "Attention Mechanism for Fine-Grained Image Classification", "Meta Platforms", "2024-12-15", "G06N")
          result_card("US20240392109A1", "78%", "Self-Supervised Learning for Unlabeled Image Datasets", "Microsoft Corp", "2024-12-14", "G06N")

          p(class: "mt-3 text-xs") {
            a(href: "#") { "→ view all 23 results" }
          }
        }
      end

      def render_log_section
        section(class: "mb-8") {
          h2(class: "text-[11px] uppercase tracking-wide text-muted mb-3") { "Log" }
          div(class: "text-[11px] bg-surface-alt p-3 overflow-x-auto") {
            log_line("14:32:01", "SYNC machine-learning-image-recognition: 23 new matches")
            log_line("13:00:00", "MAIL daily-digest sent to user@company.com (8 alerts)")
            log_line("11:45:23", "EDIT battery-technology-solid-state: keywords updated")
            log_line("09:15:00", "SYNC uspto-database: 14,293 patents indexed")
            log_line("YESTERDAY", "CREATE quantum-computing-error-correction")
            log_line("YESTERDAY", "PAUSE autonomous-vehicles-lidar")
          }
        }
      end

      def render_divider
        hr(class: "border-t border-border-default my-6")
      end

      # Helper methods
      def alert_item(idx, name, count, status, time)
        div(class: "flex gap-2 mb-1") {
          span(class: "text-muted min-w-[24px]") { "#{format('%02d', idx)}." }
          span(class: "flex-1") {
            a(href: "#") { name }
          }
          span(class: "min-w-[60px] #{count.start_with?('+') ? 'font-semibold' : ''}") { count }
          span(class: "min-w-[60px] text-muted") { status }
          span(class: "min-w-[70px] text-muted text-right") { time }
        }
      end

      def result_card(id, match, title, assignee, date, cpc)
        div(class: "mb-4 pl-4 border-l-2 border-border-light hover:border-border-default") {
          div(class: "text-xs font-semibold") {
            a(href: "#", class: "no-underline") { id }
            plain " — #{match} match"
          }
          div(class: "text-sm my-0.5") { title }
          div(class: "text-[11px] text-muted") {
            span(class: "mr-4") { assignee }
            span(class: "mr-4") { "filed #{date}" }
            span { cpc }
          }
        }
      end

      def log_line(time, message)
        div(class: "whitespace-nowrap") {
          span(class: "text-muted mr-3") { time }
          plain message
        }
      end
    end
  end
end
