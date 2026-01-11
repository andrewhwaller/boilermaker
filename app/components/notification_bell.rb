# frozen_string_literal: true

module Components
  class NotificationBell < Components::Base
    include Phlex::Rails::Helpers::LinkTo

    def initialize(recipient:)
      @recipient = recipient
      @unread_count = recipient&.unread_notifications_count || 0
    end

    def view_template
      link_to notifications_path, class: "relative inline-flex items-center p-2 hover:bg-base-200 rounded-lg" do
        render_bell_icon
        render_badge if @unread_count > 0
      end
    end

    private

    def render_bell_icon
      svg(class: "w-6 h-6", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24") do |s|
        s.path(
          stroke_linecap: "round",
          stroke_linejoin: "round",
          stroke_width: "2",
          d: "M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"
        )
      end
    end

    def render_badge
      span(class: "absolute -top-1 -right-1 flex items-center justify-center min-w-5 h-5 px-1 text-xs font-bold text-white bg-error rounded-full") do
        @unread_count > 99 ? "99+" : @unread_count.to_s
      end
    end
  end
end
