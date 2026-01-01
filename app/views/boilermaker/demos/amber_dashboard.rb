# frozen_string_literal: true

module Views
  module Boilermaker
    module Demos
      # Amber (DOS) theme demo page
      # Uses composition: renders the layout component rather than inheriting from it
      class AmberDashboard < Base
        def view_template
          render Views::Boilermaker::Layouts::AmberDashboard.new(title: "PATENTWATCH") {
            render_stats_box
            render_alerts_box
            render_results_box
            render_log_box
          }
        end

        private

        def render_stats_box
          render Components::Boilermaker::BoxPanel.new(title: "SYSTEM STATUS") {
            div(class: "flex justify-around text-center py-2") {
              sample_stats.each do |stat|
                stat_display(stat.value, stat.label, highlight: stat.highlight)
              end
            }
          }
        end

        def render_alerts_box
          render Components::Boilermaker::BoxPanel.new(title: "ACTIVE ALERTS") {
            # Header
            div(class: "flex border-b border-accent pb-1 mb-1 text-[11px] text-accent") {
              span(class: "w-[30px]") { "#" }
              span(class: "flex-1") { "ALERT NAME" }
              span(class: "w-[70px] text-right") { "NEW" }
              span(class: "w-[80px] text-center") { "STATUS" }
              span(class: "w-[80px] text-right") { "UPDATED" }
            }

            # Rows
            sample_alerts.each_with_index do |alert, idx|
              alert_row(idx + 1, alert.name, alert.count, alert.status, alert.time, selected: idx == 0)
            end
          }
        end

        def render_results_box
          render Components::Boilermaker::BoxPanel.new(title: "RESULTS: MACHINE LEARNING — IMAGE RECOGNITION (23)") {
            sample_patents.first(3).each do |patent|
              result_item(
                "#{patent.id}A1",
                "#{patent.match}%",
                patent.title,
                patent.assignee,
                patent.date,
                patent.cpc
              )
            end
          }
        end

        def render_log_box
          render Components::Boilermaker::BoxPanel.new(title: "SYSTEM LOG") {
            div(class: "h-[120px] overflow-y-auto bg-[rgba(0,0,0,0.3)] p-2 text-xs") {
              sample_log_entries.each do |entry|
                log_line(entry.time, entry.type, entry.message)
              end
            }
          }
        end

        # Helper methods
        def stat_display(value, label, highlight: false)
          div(class: "px-4") {
            div(class: "text-2xl font-bold text-accent #{highlight ? 'animate-pulse' : ''}") { value }
            div(class: "demo-label-wide") { label }
          }
        end

        def alert_row(idx, name, count, status, time, selected: false)
          div(class: "flex py-1 border-b border-dotted border-muted text-[13px] #{selected ? 'bg-accent text-surface' : 'demo-row-hover'}") {
            span(class: "w-[30px] text-muted") { sprintf("%02d", idx) }
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
          div(class: "py-2 border-b border-muted demo-row-hover") {
            div(class: "flex justify-between mb-1") {
              span(class: "text-accent font-semibold") {
                a(href: "#", class: "hover:underline") { id }
              }
              span(class: "text-accent") { "MATCH: #{match}" }
            }
            div(class: "text-[13px] mb-1") { title }
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
end
