# frozen_string_literal: true

module Views
  module Demos
    class PaperDashboard < Views::Layouts::PaperDashboard
      def initialize
        super(title: "Patent Monitor")
      end

      def view_template
        super {
          render_summary
          render_recent_alerts
          render_activity
        }
      end

      private

      def render_summary
        section(class: "mb-8") {
          h2(class: "text-lg font-serif mb-4") { "Summary" }
          div(class: "grid grid-cols-3 gap-6") {
            summary_card("Total Patents", "1,247", "Tracked across all alerts")
            summary_card("Active Alerts", "23", "Monitoring 5 technology areas")
            summary_card("This Week", "+156", "New patents discovered")
          }
        }
      end

      def render_recent_alerts
        section(class: "mb-8") {
          h2(class: "text-lg font-serif mb-4") { "Recent Alerts" }
          div(class: "space-y-3") {
            alert_item("Machine Learning", "23 new patents", "2 hours ago")
            alert_item("Battery Technology", "8 new patents", "Yesterday")
            alert_item("Autonomous Vehicles", "No new patents", "2 days ago")
          }
        }
      end

      def render_activity
        section {
          h2(class: "text-lg font-serif mb-4") { "Activity" }
          div(class: "text-sm text-muted space-y-2") {
            activity_item("Exported report", "machine-learning-patents-2024.pdf")
            activity_item("Created alert", "Quantum Computing")
            activity_item("Updated search", "Battery Technology")
          }
        }
      end

      def summary_card(title, value, description)
        div(class: "border border-border-light p-4") {
          div(class: "text-sm text-muted") { title }
          div(class: "text-2xl font-serif my-1") { value }
          div(class: "text-xs text-muted") { description }
        }
      end

      def alert_item(name, status, time)
        div(class: "flex justify-between items-center py-2 border-b border-border-light") {
          div {
            div(class: "font-medium") { name }
            div(class: "text-sm text-muted") { status }
          }
          span(class: "text-xs text-muted") { time }
        }
      end

      def activity_item(action, detail)
        div(class: "flex items-center gap-2") {
          span(class: "w-1 h-1 bg-muted rounded-full") {}
          span { action }
          span(class: "text-muted") { "—" }
          span { detail }
        }
      end
    end
  end
end
