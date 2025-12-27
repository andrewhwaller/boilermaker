# frozen_string_literal: true

module Views
  module Layouts
    # Industrial Minimal themed dashboard layout
    # 3-column layout with sidebar, main content, and activity panel
    # Inspired by US Graphics Company / Berkeley Mono aesthetic
    #
    # Uses "paper" color scheme intentionally - Industrial is a structural/layout
    # theme, not a color theme. It pairs well with paper's clean light aesthetic.
    #
    # Accepts sidebar_stats, sidebar_alerts, and activity_items as parameters
    # for proper dependency injection (composition over inheritance).
    class IndustrialDashboard < DashboardBase
      def initialize(title: "Dashboard", sidebar_stats: [], sidebar_alerts: [], activity_items: [], status_info: nil)
        super(title: title)
        @sidebar_stats = sidebar_stats
        @sidebar_alerts = sidebar_alerts
        @activity_items = activity_items
        @status = status_info || default_status_info
      end

      def default_status_info
        Views::Demos::SampleData::StatusInfo.new
      end

      def theme_name = "paper"
      def polarity = "light"

      def render_body(&block)
        body(class: "bg-surface text-body min-h-screen font-mono text-[13px] leading-relaxed pb-10") {
          render_header
          render_main_container(&block)
          render_footer_bar
        }
      end

      private

      def render_header
        header(class: "border-b-2 border-body grid grid-cols-[auto_1fr_auto]") {
          render_logo_block
          render_nav_main
          render_header_right
        }
      end

      def render_logo_block
        div(class: "border-r-2 border-body px-6 py-4 flex items-center gap-3") {
          div(class: "w-8 h-8 bg-body flex items-center justify-center text-surface font-bold text-[11px]") {
            "PW"
          }
          div {
            div(class: "text-[14px] font-bold uppercase tracking-[0.1em]") { "Patentwatch" }
            div(class: "text-[10px] text-muted tracking-[0.05em]") { "USPTO Alert System" }
          }
        }
      end

      def render_nav_main
        nav(class: "flex items-stretch") {
          nav_items.each do |item|
            a(
              href: item[:href],
              class: nav_item_classes(item[:active])
            ) { item[:label] }
          end
        }
      end

      def nav_item_classes(active)
        base = "px-6 py-4 border-r border-border-light text-[11px] uppercase tracking-[0.08em] no-underline transition-all duration-150"
        if active
          "#{base} bg-body text-surface"
        else
          "#{base} text-muted hover:bg-surface-alt hover:text-body"
        end
      end

      def nav_items
        [
          { label: "Dashboard", href: "#", active: true },
          { label: "Alerts", href: "#", active: false },
          { label: "Patents", href: "#", active: false },
          { label: "Analytics", href: "#", active: false },
          { label: "Settings", href: "#", active: false }
        ]
      end

      def render_header_right
        div(class: "border-l-2 border-body px-6 py-4 flex items-center gap-3") {
          div(class: "w-2 h-2 bg-success rounded-full") {}
          span(class: "text-[13px]") { "user@company.com" }
        }
      end

      def render_main_container(&block)
        div(class: "grid grid-cols-[280px_1fr_320px] min-h-[calc(100vh-66px)]") {
          render_sidebar
          main(class: "p-8 bg-surface") { yield if block_given? }
          render_activity_panel
        }
      end

      def render_sidebar
        aside(class: "border-r-2 border-body bg-surface-alt") {
          render_sidebar_header
          render_alert_list
        }
      end

      def render_sidebar_header
        div(class: "p-5 border-b border-border-light") {
          div(class: "text-[10px] uppercase tracking-[0.1em] text-muted mb-3") { "Overview" }
          div(class: "grid grid-cols-2 gap-3") {
            @sidebar_stats.each { |stat| render_stat_box(stat) }
          }
        }
      end

      def render_stat_box(stat)
        div(class: "bg-surface border border-body p-3") {
          div(class: "text-[9px] uppercase tracking-[0.08em] text-muted mb-1") { stat[:label] }
          div(class: stat[:highlight] ? "text-2xl font-bold text-accent" : "text-2xl font-bold") {
            stat[:value]
          }
        }
      end

      def render_alert_list
        div {
          div(class: "px-5 py-4 bg-border-light text-[10px] uppercase tracking-[0.1em] border-b border-border-light flex justify-between items-center") {
            span { "My Alerts" }
            span(class: "bg-body text-surface px-2 py-0.5 text-[9px]") { @sidebar_alerts.size.to_s }
          }
          @sidebar_alerts.each { |alert| render_alert_item(alert) }
        }
      end

      def render_alert_item(alert)
        selected_class = alert[:selected] ? "border-l-[3px] border-l-accent bg-surface" : ""
        div(
          class: "px-5 py-4 border-b border-border-light cursor-pointer transition-all duration-150 hover:bg-surface hover:pl-6 #{selected_class}"
        ) {
          div(class: "font-semibold text-[12px] mb-1") { alert[:name] }
          div(class: "text-[10px] text-muted flex gap-3") {
            span(class: "flex items-center gap-1") {
              dot_class = alert[:status] == :active ? "bg-success" : "bg-muted"
              span(class: "w-1.5 h-1.5 #{dot_class} rounded-full") {}
              plain(alert[:status] == :active ? "Active" : "Paused")
            }
            span { "#{alert[:new_count]} new" }
          }
        }
      end

      def render_activity_panel
        aside(class: "border-l-2 border-body bg-surface-alt") {
          div(class: "p-5 border-b-2 border-body bg-border-light") {
            div(class: "text-[11px] uppercase tracking-[0.1em] font-semibold") { "Recent Activity" }
          }
          div {
            @activity_items.each { |item| render_activity_item(item) }
          }
        }
      end

      def render_activity_item(item)
        div(class: "px-5 py-4 border-b border-border-light") {
          div(class: "text-[9px] uppercase tracking-[0.05em] text-muted mb-2") { item.time }
          p(class: "text-[12px] leading-relaxed") {
            item.parts.each do |part|
              if part.highlight
                span(class: "text-accent font-semibold") { part.text }
              else
                plain part.text
              end
            end
          }
          span(class: "inline-block mt-2 bg-surface border border-body px-2 py-0.5 text-[9px] uppercase") {
            item.tag
          }
        }
      end

      def render_footer_bar
        footer(
          class: "fixed bottom-0 left-0 right-0 bg-body text-surface px-6 py-2 text-[10px] flex justify-between items-center"
        ) {
          div(class: "flex items-center gap-4") {
            span(class: "flex items-center gap-2") {
              span(class: "w-1.5 h-1.5 #{@status.connected ? 'bg-success' : 'bg-error'} rounded-full #{@status.connected ? 'animate-pulse' : ''}") {}
              plain "#{@status.connection_name} #{@status.connected ? 'Connected' : 'Disconnected'}"
            }
            span { "Last sync: #{@status.last_sync}" }
            span { "Database: #{@status.db_size} patents" }
          }
          span(class: "text-muted") { "#{@title.split('—').first.strip.upcase} v#{@status.version}" }
        }
      end
    end
  end
end
