# frozen_string_literal: true

module Components
  class NotificationItem < Components::Base
    include Phlex::Rails::Helpers::LinkTo
    include Phlex::Rails::Helpers::ButtonTo
    include ActionView::Helpers::DateHelper

    def initialize(notification:)
      @notification = notification
    end

    def view_template
      div(class: item_classes) do
        div(class: "flex-1 min-w-0") do
          render_message
          render_timestamp
        end
        render_actions
      end
    end

    private

    def item_classes
      base = "flex items-start gap-4 p-4 rounded-lg border"
      if @notification.read?
        "#{base} border-base-200 bg-base-100"
      else
        "#{base} border-primary/30 bg-primary/5"
      end
    end

    def render_message
      p(class: "font-medium") { message }
    end

    def message
      @notification.params[:message] || "New notification"
    end

    def render_timestamp
      p(class: "text-sm text-base-content/60 mt-1") do
        time_ago_in_words(@notification.created_at) + " ago"
      end
    end

    def render_actions
      div(class: "flex items-center gap-2") do
        unless @notification.read?
          button_to mark_read_notification_path(@notification),
                    method: :post,
                    class: "ui-button ui-button-ghost ui-button-sm",
                    title: "Mark as read" do
            svg(class: "w-4 h-4", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24") do |s|
              s.path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M5 13l4 4L19 7")
            end
          end
        end
      end
    end
  end
end
