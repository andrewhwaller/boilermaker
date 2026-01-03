# frozen_string_literal: true

# Include this concern in models that can receive notifications
# Usage: include Notifiable
module Notifiable
  extend ActiveSupport::Concern

  included do
    has_many :notifications, as: :recipient, dependent: :destroy, class_name: "Noticed::Notification"
  end

  def unread_notifications
    notifications.unread
  end

  def unread_notifications_count
    unread_notifications.count
  end

  def mark_notifications_as_read!
    unread_notifications.update_all(read_at: Time.current)
  end
end
