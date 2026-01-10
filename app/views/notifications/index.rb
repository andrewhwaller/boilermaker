# frozen_string_literal: true

module Views
  module Notifications
    class Index < Views::Base
      include Phlex::Rails::Helpers::LinkTo
      include Phlex::Rails::Helpers::ButtonTo

      def initialize(notifications:)
        @notifications = notifications
      end

      def view_template
        page_with_title("Notifications") do
          div(class: "max-w-2xl") do
            render_header
            render_notifications
          end
        end
      end

      private

      def render_header
        div(class: "flex items-center justify-between mb-6") do
          h1(class: "text-2xl font-bold") { "Notifications" }
          if @notifications.any?(&:unread?)
            button_to "Mark all read", mark_all_read_notifications_path,
                      method: :post,
                      class: "ui-button ui-button-outline ui-button-sm"
          end
        end
      end

      def render_notifications
        if @notifications.empty?
          div(class: "text-center py-12 text-base-content/60") do
            p { "No notifications yet" }
          end
        else
          div(class: "space-y-2") do
            @notifications.each do |notification|
              render Components::NotificationItem.new(notification: notification)
            end
          end
        end
      end
    end
  end
end
