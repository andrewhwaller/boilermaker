# frozen_string_literal: true

module Views
  module Demos
    class DosDashboard < Views::Layouts::DosDashboard
      def initialize
        super(title: "PATENTWATCH")
      end

      def view_template
        super {
          render_stats_box
          render_alerts_box
          render_results_box
          render_log_box
        }
      end

      private

      def render_stats_box
        render Components::BoxPanel.new(title: "SYSTEM STATUS") {
          div(class: "flex justify-around text-center py-2") {
            stat("47", "New Matches", alert: true)
            stat("183", "This Week")
            stat("12", "Active Alerts")
            stat("18.4M", "Patents")
          }
        }
      end

      def render_alerts_box
        render Components::BoxPanel.new(title: "ACTIVE ALERTS") {
          # Header
          div(class: "flex border-b border-accent pb-1 mb-1 text-[11px] text-accent") {
            span(class: "w-[30px]") { "#" }
            span(class: "flex-1") { "ALERT NAME" }
            span(class: "w-[70px] text-right") { "NEW" }
            span(class: "w-[80px] text-center") { "STATUS" }
            span(class: "w-[80px] text-right") { "UPDATED" }
          }

          # Rows
          alert_row(1, "Machine Learning — Image Recognition", 23, :active, "2m ago", selected: true)
          alert_row(2, "Battery Technology — Solid State", 8, :active, "1h ago")
          alert_row(3, "Semiconductor — 3nm Process", 12, :active, "1h ago")
          alert_row(4, "Quantum Computing — Error Correction", 4, :active, "3h ago")
          alert_row(5, "Autonomous Vehicles — LIDAR", 0, :paused, "2d ago")
        }
      end

      def render_results_box
        render Components::BoxPanel.new(title: "RESULTS: MACHINE LEARNING — IMAGE RECOGNITION (23)") {
          result_item("US20240401234A1", "94%", "Neural Network Architecture for Real-Time Object Detection in Autonomous Systems", "Google LLC", "2024-12-18", "G06N, G06T")
          result_item("US20240398765A1", "89%", "Convolutional Layer Optimization for Edge Device Deployment", "Apple Inc.", "2024-12-17", "G06N")
          result_item("US20240396543A1", "87%", "Multi-Modal Feature Extraction for Medical Imaging Analysis", "NVIDIA Corp", "2024-12-16", "G06T, G16H")
        }
      end

      def render_log_box
        render Components::BoxPanel.new(title: "SYSTEM LOG") {
          div(class: "h-[120px] overflow-y-auto bg-[rgba(0,0,0,0.3)] p-2 text-xs") {
            log_line("14:32:01", "SYNC", "ML-IMAGE-RECOGNITION: 23 new matches found")
            log_line("13:00:00", "MAIL", "Daily digest sent to user@company.com")
            log_line("11:45:23", "EDIT", "BATTERY-TECH: keywords configuration updated")
            log_line("09:15:00", "SYNC", "USPTO database: 14,293 new patents indexed")
            log_line("YESTERDAY", "NEW", "Alert created: QUANTUM-COMPUTING")
            log_line("YESTERDAY", "PAUSE", "Alert paused: AUTONOMOUS-VEHICLES")
          }
        }
      end

      # Helper methods
      def stat(value, label, alert: false)
        div(class: "px-4") {
          div(class: "text-2xl font-bold text-accent #{alert ? 'animate-pulse' : ''}") { value }
          div(class: "text-[10px] text-muted uppercase tracking-wide") { label }
        }
      end

      def alert_row(idx, name, count, status, time, selected: false)
        div(class: "flex py-1 border-b border-dotted border-muted text-sm #{selected ? 'bg-accent text-surface' : 'hover:bg-[rgba(255,176,0,0.1)]'}") {
          span(class: "w-[30px] text-muted") { format("%02d", idx) }
          span(class: "flex-1") {
            a(href: "#", class: selected ? "text-surface" : "text-accent hover:underline") { name }
          }
          span(class: "w-[70px] text-right #{count > 0 ? 'text-accent font-bold' : ''}") {
            count > 0 ? "+#{count}" : "0"
          }
          span(class: "w-[80px] text-center text-[11px]") {
            if status == :active
              span(class: "before:content-['●_']") { "ACTIVE" }
            else
              span(class: "before:content-['○_'] text-muted") { "PAUSED" }
            end
          }
          span(class: "w-[80px] text-right text-muted text-[11px]") { time }
        }
      end

      def result_item(id, match, title, assignee, date, cpc)
        div(class: "py-2 border-b border-muted hover:bg-[rgba(255,176,0,0.1)]") {
          div(class: "flex justify-between mb-1") {
            span(class: "text-accent font-semibold") {
              a(href: "#", class: "hover:underline") { id }
            }
            span(class: "text-accent") { "MATCH: #{match}" }
          }
          div(class: "text-sm mb-1") { title }
          div(class: "text-[11px] text-muted") {
            span(class: "mr-4") { assignee }
            span(class: "mr-4") { "Filed: #{date}" }
            span { "CPC: #{cpc}" }
          }
        }
      end

      def log_line(time, type, message)
        div(class: "mb-0.5") {
          span(class: "text-muted") { time }
          plain " "
          span(class: "text-accent") { "[#{type}]" }
          plain " #{message}"
        }
      end
    end
  end
end
