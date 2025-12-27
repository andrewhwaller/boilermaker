# frozen_string_literal: true

module Views
  module Demos
    # Industrial theme demo page
    # Uses composition: renders the layout component rather than inheriting from it
    class IndustrialDashboard < Base
      def view_template
        render Views::Layouts::IndustrialDashboard.new(
          title: "PATENTWATCH — Dashboard",
          sidebar_stats: build_sidebar_stats,
          sidebar_alerts: build_sidebar_alerts,
          activity_items: sample_activity_items
        ) {
          render_content_header
          render_results_panel
        }
      end

      private

      # Transform sample data for sidebar stats format
      def build_sidebar_stats
        sample_stats.map do |stat|
          { label: stat.label.gsub("_", " ").split.map(&:capitalize).join(" "), value: stat.value, highlight: stat.highlight }
        end
      end

      # Transform sample data for sidebar alerts format
      def build_sidebar_alerts
        sample_alerts.map.with_index do |alert, idx|
          {
            name: alert.name,
            status: alert.status,
            new_count: alert.count,
            selected: idx == 0
          }
        end
      end

      def render_content_header
        div(class: "flex justify-between items-start mb-8") {
          div {
            div(class: "demo-label-wide mb-2") { "Alert Results" }
            h1(class: "text-2xl font-bold tracking-tight") { "Machine Learning — Image Recognition" }
          }
          button(class: "bg-body text-surface px-6 py-3 text-[11px] uppercase tracking-[0.08em] flex items-center gap-2 hover:bg-accent transition-colors duration-150") {
            span(class: "text-[14px]") { "+" }
            plain "New Alert"
          }
        }
      end

      def render_results_panel
        div(class: "bg-surface-alt border-2 border-body") {
          render_results_header
          render_results_table
        }
      end

      def render_results_header
        div(class: "px-5 py-4 border-b-2 border-body flex justify-between items-center") {
          div(class: "font-semibold text-[12px]") { "23 New Patents Found" }
          div(class: "flex gap-2") {
            tool_button("Export CSV")
            tool_button("Filter")
            tool_button("Sort")
          }
        }
      end

      def tool_button(label)
        button(class: "bg-surface border border-body px-3 py-1.5 text-[10px] hover:bg-body hover:text-surface transition-colors duration-150") {
          label
        }
      end

      def render_results_table
        table(class: "w-full") {
          thead {
            tr(class: "bg-border-light") {
              table_header("Patent ID")
              table_header("Title")
              table_header("Assignee")
              table_header("Filed")
              table_header("Match")
            }
          }
          tbody {
            sample_patents.each do |patent|
              render_patent_row(patent)
            end
          }
        }
      end

      def table_header(label)
        th(class: "text-left px-4 py-3 text-[9px] uppercase tracking-[0.08em] text-muted border-b border-border-light") {
          label
        }
      end

      def render_patent_row(patent)
        tr(class: "demo-row-hover transition-colors duration-150") {
          td(class: "px-4 py-4 border-b border-border-light") {
            span(class: "font-semibold text-accent") { patent.id }
          }
          td(class: "px-4 py-4 border-b border-border-light text-[12px] max-w-[300px]") { patent.title }
          td(class: "px-4 py-4 border-b border-border-light text-[12px]") { patent.assignee }
          td(class: "px-4 py-4 border-b border-border-light text-[11px] text-muted") { patent.date }
          td(class: "px-4 py-4 border-b border-border-light") {
            render_match_score(patent.match)
          }
        }
      end

      def render_match_score(score)
        span(class: "flex items-center gap-2") {
          span(class: "w-10 h-1 bg-border-light relative") {
            span(class: "absolute left-0 top-0 h-full bg-success", style: "width: #{score}%") {}
          }
          span(class: "text-[11px]") { "#{score}%" }
        }
      end
    end
  end
end
