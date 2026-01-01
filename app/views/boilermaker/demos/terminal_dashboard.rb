# frozen_string_literal: true

module Views
  module Boilermaker
    module Demos
      # Terminal theme demo page
      # Uses composition: renders the layout component rather than inheriting from it
      class TerminalDashboard < Base
        def view_template
          render Views::Boilermaker::Layouts::TerminalDashboard.new(title: "PATENTWATCH", version: "v1.0.0") {
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
          div(class: "flex gap-8 py-3 border-y border-border-light mb-6 text-[13px]") {
            sample_stats.each do |stat|
              stat_item(stat.value, stat.label, highlight: stat.highlight)
            end
          }
        end

        def render_alerts_section
          section(class: "mb-8") {
            render Components::Boilermaker::CommentHeader.new(title: "ACTIVE ALERTS")
            div(class: "text-[13px]") {
              sample_alerts.each_with_index do |alert, idx|
                count_str = alert.count > 0 ? "+#{alert.count} new" : "0 new"
                alert_row(idx + 1, alert.name, count_str, alert.status, alert.time)
              end
            }
          }
        end

        def render_results_section
          section(class: "mb-8") {
            div(class: "text-[11px] text-muted mb-1") {
              span(class: "text-accent") { "$ " }
              plain 'patentwatch --query "ML Image Recognition" --limit 5'
            }
            render Components::Boilermaker::CommentHeader.new(title: "LATEST RESULTS // MACHINE LEARNING")

            # Results header
            div(class: "grid grid-cols-[130px_1fr_100px_70px_50px] gap-3 py-1.5 border-b border-border-light demo-label") {
              span { "PATENT_ID" }
              span { "TITLE" }
              span { "ASSIGNEE" }
              span { "FILED" }
              span { "MATCH" }
            }

            # Results rows
            sample_patents.each do |patent|
              result_row(patent.id, patent.title, patent.assignee, patent.date, "#{patent.match}%")
            end
          }
        end

        def render_log_section
          section(class: "mb-8") {
            render Components::Boilermaker::CommentHeader.new(title: "SYSTEM LOG")
            div(class: "bg-surface-alt p-3 border border-border-light max-h-[200px] overflow-y-auto text-xs") {
              sample_log_entries.each do |entry|
                log_entry("[#{entry.time}]", entry.type, entry.message)
              end
            }
          }
        end

        # Helper methods
        def stat_item(value, label, highlight: false)
          span {
            span(class: "font-semibold #{highlight ? 'text-accent-alt stat-highlight' : 'text-accent'}") { value }
            span(class: "text-muted ml-1.5") { label }
          }
        end

        def alert_row(idx, name, count, status, time)
          div(class: "grid grid-cols-[20px_1fr_80px_70px_90px] gap-4 py-1.5 border-b border-dotted border-border-light items-center demo-row-hover") {
            span(class: "text-muted text-[11px]") { sprintf("%02d", idx) }
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
          div(class: "grid grid-cols-[130px_1fr_100px_70px_50px] gap-3 py-2 border-b border-dotted border-border-light demo-row-hover text-xs") {
            span(class: "text-accent-alt") {
              a(href: "#", class: "hover:underline") { id }
            }
            span(class: "text-accent leading-snug") { title }
            span(class: "text-muted") { assignee }
            span(class: "text-muted") { date }
            span(class: "text-accent font-semibold") { match }
          }
        end

        def log_entry(time, action, message)
          div(class: "py-0.5 flex gap-3") {
            span(class: "text-muted min-w-[80px]") { time }
            span(class: "text-accent") {
              plain "#{action} — #{message}"
            }
          }
        end
      end
    end
  end
end
