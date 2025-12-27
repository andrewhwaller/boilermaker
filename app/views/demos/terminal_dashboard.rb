# frozen_string_literal: true

module Views
  module Demos
    class TerminalDashboard < Views::Layouts::TerminalDashboard
      def initialize
        super(title: "PATENTWATCH", version: "v1.0.0")
      end

      def view_template
        super {
          render_prompt_command
          render_stats_bar
          render_alerts_section
          render_results_section
          render_log_section
        }
      end

      private

      def render_prompt_command
        div(class: "text-[11px] text-muted mb-1") {
          span(class: "text-accent") { "$ " }
          plain "patentwatch --list-alerts --with-stats"
        }
      end

      def render_stats_bar
        div(class: "flex gap-8 py-3 border-y border-border-light mb-6 text-sm") {
          stat_item("47", "new matches", alert: true)
          stat_item("183", "this week")
          stat_item("12", "active alerts")
          stat_item("18.4M", "patents indexed")
        }
      end

      def render_alerts_section
        section(class: "mb-8") {
          render Components::CommentHeader.new(title: "ACTIVE ALERTS")
          div(class: "text-sm") {
            alert_row(1, "Machine Learning — Image Recognition", "+23 new", :active, "2m ago")
            alert_row(2, "Battery Technology — Solid State", "+8 new", :active, "1h ago")
            alert_row(3, "Semiconductor — 3nm Process", "+12 new", :active, "1h ago")
            alert_row(4, "Quantum Computing — Error Correction", "+4 new", :active, "3h ago")
            alert_row(5, "Autonomous Vehicles — LIDAR", "0 new", :paused, "2d ago")
          }
        }
      end

      def render_results_section
        section(class: "mb-8") {
          div(class: "text-[11px] text-muted mb-1") {
            span(class: "text-accent") { "$ " }
            plain 'patentwatch --query "ML Image Recognition" --limit 5'
          }
          render Components::CommentHeader.new(title: "LATEST RESULTS // MACHINE LEARNING")

          # Results header
          div(class: "grid grid-cols-[130px_1fr_100px_70px_50px] gap-3 py-1.5 border-b border-border-light text-muted text-[10px] uppercase tracking-wide") {
            span { "PATENT_ID" }
            span { "TITLE" }
            span { "ASSIGNEE" }
            span { "FILED" }
            span { "MATCH" }
          }

          # Results rows
          result_row("US20240401234", "Neural Network Architecture for Real-Time Object Detection in Autonomous Systems", "Google LLC", "2024-12-18", "94%")
          result_row("US20240398765", "Convolutional Layer Optimization for Edge Device Deployment", "Apple Inc.", "2024-12-17", "89%")
          result_row("US20240396543", "Multi-Modal Feature Extraction for Medical Imaging Analysis", "NVIDIA Corp", "2024-12-16", "87%")
          result_row("US20240394321", "Attention Mechanism for Fine-Grained Image Classification", "Meta Platforms", "2024-12-15", "82%")
          result_row("US20240392109", "Self-Supervised Learning for Unlabeled Image Datasets", "Microsoft", "2024-12-14", "78%")
        }
      end

      def render_log_section
        section(class: "mb-8") {
          render Components::CommentHeader.new(title: "SYSTEM LOG")
          div(class: "bg-surface-alt p-3 border border-border-light max-h-[200px] overflow-y-auto text-xs") {
            log_entry("[14:32:01]", "SYNC COMPLETE", "23 new matches", "for \"ML Image Recognition\"")
            log_entry("[13:00:00]", "DIGEST SENT", nil, "8 alerts delivered to user@company.com")
            log_entry("[11:45:23]", "CONFIG UPDATE", nil, "\"Battery Tech\" keywords modified")
            log_entry("[09:15:00]", "USPTO SYNC", "14,293 patents", "indexed")
            log_entry("[YESTERDAY]", "ALERT CREATED", nil, "\"Quantum Computing — Error Correction\"")
          }
        }
      end

      # Helper methods
      def stat_item(value, label, alert: false)
        span {
          span(class: "font-semibold #{alert ? 'text-accent-alt stat-highlight' : 'text-accent'}") { value }
          span(class: "text-muted ml-1.5") { label }
        }
      end

      def alert_row(idx, name, count, status, time)
        div(class: "grid grid-cols-[20px_1fr_80px_70px_90px] gap-4 py-1.5 border-b border-dotted border-border-light items-center hover:bg-[rgba(51,255,51,0.1)]") {
          span(class: "text-muted text-[11px]") { format("%02d", idx) }
          span(class: "text-accent") {
            a(href: "#", class: "hover:underline") { name }
          }
          span(class: count.start_with?("+") ? "text-accent-alt text-right" : "text-right") { count }
          span(class: "text-[11px] #{status == :active ? 'before:content-[\'●_\'] before:text-accent' : 'before:content-[\'○_\'] text-muted'}") {
            status == :active ? "ACTIVE" : "PAUSED"
          }
          span(class: "text-[11px] text-muted text-right") { time }
        }
      end

      def result_row(id, title, assignee, date, match)
        div(class: "grid grid-cols-[130px_1fr_100px_70px_50px] gap-3 py-2 border-b border-dotted border-border-light hover:bg-[rgba(51,255,51,0.1)]") {
          span(class: "text-accent-alt") {
            a(href: "#", class: "hover:underline") { id }
          }
          span(class: "text-accent leading-snug") { title }
          span(class: "text-muted") { assignee }
          span(class: "text-muted") { date }
          span(class: "text-accent font-semibold") { match }
        }
      end

      def log_entry(time, action, highlight, message)
        div(class: "py-0.5 flex gap-3") {
          span(class: "text-muted min-w-[80px]") { time }
          span(class: "text-accent") {
            plain "#{action} — "
            if highlight
              span(class: "text-accent-alt") { highlight }
              plain " "
            end
            plain message
          }
        }
      end
    end
  end
end
