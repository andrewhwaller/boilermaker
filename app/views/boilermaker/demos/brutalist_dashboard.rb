# frozen_string_literal: true

module Views
  module Boilermaker
    module Demos
      # Brutalist theme demo page
      # Uses composition: renders the layout component rather than inheriting from it
      class BrutalistDashboard < Base
        def view_template
          render Views::Boilermaker::Layouts::BrutalistDashboard.new(title: "patentwatch") {
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
            sample_stats.each do |stat|
              span(class: "mr-6") {
                span(class: stat.highlight ? "font-semibold bg-inverse text-surface px-1" : "font-semibold") { stat.value }
                plain " #{stat.label}"
              }
            end
            span { "synced 2m ago" }
          }
        end

        def render_alerts_section
          section(class: "mb-8") {
            h2(class: "text-[11px] uppercase tracking-[0.08em] text-muted mb-3") { "Active Alerts" }
            div(class: "text-xs") {
              sample_alerts.each_with_index do |alert, idx|
                count_str = alert.count > 0 ? "+#{alert.count} new" : "0"
                alert_row(idx + 1, alert.name, count_str, alert.status.to_s, alert.time)
              end
            }
          }
        end

        def render_results_section
          section(class: "mb-8") {
            h2(class: "text-[11px] uppercase tracking-[0.08em] text-muted mb-3") {
              "Latest: Machine Learning — Image Recognition (23 results)"
            }

            sample_patents.each do |patent|
              result_card(
                "#{patent.id}A1",
                "#{patent.match}%",
                patent.title,
                patent.assignee,
                patent.date,
                patent.cpc
              )
            end

            p(class: "mt-3 text-xs") {
              a(href: "#") { "→ view all 23 results" }
            }
          }
        end

        def render_log_section
          section(class: "mb-8") {
            h2(class: "text-[11px] uppercase tracking-[0.08em] text-muted mb-3") { "Log" }
            div(class: "text-[11px] bg-surface-alt p-3 overflow-x-auto") {
              sample_log_entries.each do |entry|
                log_line(entry.time, format_log_message(entry.type, entry.message))
              end
            }
          }
        end

        def render_divider
          hr(class: "border-t border-border-default my-6")
        end

        # Helper methods
        def alert_row(idx, name, count, status, time)
          div(class: "flex gap-2 mb-1") {
            span(class: "text-muted min-w-[24px]") { "#{sprintf('%02d', idx)}." }
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
            div(class: "text-[13px] my-0.5") { title }
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

        # Format log message in brutalist style: "TYPE kebab-name: details"
        def format_log_message(type, message)
          # Split on colon to separate alert name from details
          if message.include?(":")
            parts = message.split(":", 2)
            alert_name = parts[0].strip.downcase.gsub(/\s+/, "-")
            details = parts[1].strip
            "#{type} #{alert_name}: #{details}"
          else
            # No colon - just kebab-case the whole message
            "#{type} #{message.downcase.gsub(/\s+/, "-")}"
          end
        end
      end
    end
  end
end
