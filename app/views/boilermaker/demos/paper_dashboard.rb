# frozen_string_literal: true

module Views
  module Boilermaker
    module Demos
      # Paper theme demo page
      # Uses composition: renders the layout component rather than inheriting from it
      class PaperDashboard < Base
        def view_template
          render Views::Boilermaker::Layouts::PaperDashboard.new(title: "PATENTWATCH") {
            render_stats_row
            render_alerts_section
            render_results_section
            render_activity_section
          }
        end

        private

        def render_stats_row
          div(class: "flex gap-8 py-3 mb-6 text-xs") {
            sample_stats.each do |stat|
              span {
                span(class: "font-bold text-sm #{stat.highlight ? 'text-accent' : ''}") { stat.value }
                span(class: "text-muted ml-1.5") { stat.label }
              }
            end
          }
        end

        def render_alerts_section
          section(class: "mb-8") {
            div(class: "flex justify-between items-center pb-2 border-b border-border-light mb-3") {
              span(class: "text-[11px] uppercase tracking-[0.08em] text-muted") { "Active Alerts" }
              a(href: "#", class: "text-[11px] text-accent hover:underline") { "+ New Alert" }
            }
            div(class: "border border-border-default") {
              sample_alerts.each_with_index do |alert, idx|
                alert_row(idx + 1, alert.name, alert.count, alert.status, alert.time)
              end
            }
          }
        end

        def render_results_section
          section(class: "mb-8") {
            div(class: "flex justify-between items-center pb-2 border-b border-border-light mb-3") {
              span(class: "text-[11px] uppercase tracking-[0.08em] text-muted") { "Latest Results — Machine Learning" }
              a(href: "#", class: "text-[11px] text-accent hover:underline") { "View All 23 →" }
            }
            div(class: "border border-border-default text-xs") {
              # Header
              div(class: "grid grid-cols-[110px_1fr_90px_60px_50px] gap-3 px-3 py-2 bg-surface-alt border-b border-border-default text-[10px] uppercase tracking-[0.06em] text-muted") {
                span { "Patent" }
                span { "Title" }
                span { "Assignee" }
                span { "Filed" }
                span { "Match" }
              }
              # Rows
              sample_patents.first(3).each do |patent|
                result_row(patent.id, patent.title, patent.assignee, patent.date, "#{patent.match}%")
              end
            }
          }
        end

        def render_activity_section
          section(class: "mb-8") {
            div(class: "pb-2 border-b border-border-light mb-3") {
              span(class: "text-[11px] uppercase tracking-[0.08em] text-muted") { "Recent Activity" }
            }
            div(class: "text-xs") {
              activity_row("2m ago", "ML Image Recognition", "23 new patents matched")
              activity_row("1h ago", nil, "Daily digest sent for 8 active alerts")
              activity_row("3h ago", "Battery Tech", "alert configuration updated")
            }
          }
        end

        # Helper methods
        def alert_row(idx, name, count, status, time)
          div(class: "grid grid-cols-[28px_1fr_70px_60px_80px] gap-4 px-3.5 py-2.5 border-b border-border-light last:border-b-0 items-center text-xs hover:bg-surface-alt") {
            span(class: "text-muted text-[11px]") { sprintf("%02d", idx) }
            span {
              a(href: "#", class: "hover:text-accent") { name }
            }
            span(class: "text-right text-[11px] #{count > 0 ? 'text-accent font-semibold' : ''}") {
              count > 0 ? "+#{count} new" : "0"
            }
            span(class: "flex items-center gap-1 text-[10px] text-muted") {
              span(class: "w-1.5 h-1.5 rounded-full #{status == :active ? 'bg-accent-alt' : 'bg-muted'}") { }
              plain status == :active ? "Active" : "Paused"
            }
            span(class: "text-[10px] text-muted text-right") { time }
          }
        end

        def result_row(id, title, assignee, date, match)
          div(class: "grid grid-cols-[110px_1fr_90px_60px_50px] gap-3 px-3 py-2.5 border-b border-border-light last:border-b-0 hover:bg-surface-alt") {
            span(class: "font-semibold text-accent") {
              a(href: "#", class: "hover:underline") { id }
            }
            span(class: "leading-snug") { title }
            span(class: "text-muted text-[11px]") { assignee }
            span(class: "text-muted text-[11px]") { date.split("-").last(2).join("-") }
            span(class: "font-semibold") { match }
          }
        end

        def activity_row(time, highlight, text)
          div(class: "flex gap-3 py-2 border-b border-border-light last:border-b-0") {
            span(class: "text-muted min-w-[70px] text-[11px]") { time }
            span {
              if highlight
                strong(class: "font-semibold") { highlight }
                plain " — #{text}"
              else
                plain text
              end
            }
          }
        end
      end
    end
  end
end
