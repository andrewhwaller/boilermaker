# frozen_string_literal: true

class NotificationsController < ApplicationController
  include NotificationsFeature

  before_action :require_authentication
  before_action :set_notification, only: [ :show, :mark_read ]

  # GET /notifications
  def index
    @notifications = current_recipient.notifications
                                      .includes(:event)
                                      .order(created_at: :desc)
                                      .limit(50)

    render Views::Notifications::Index.new(notifications: @notifications)
  end

  # GET /notifications/:id
  def show
    @notification.mark_as_read! unless @notification.read?
    redirect_to notification_url_for(@notification)
  end

  # POST /notifications/:id/mark_read
  def mark_read
    @notification.mark_as_read!

    respond_to do |format|
      format.html { redirect_back(fallback_location: notifications_path) }
      format.turbo_stream { head :ok }
    end
  end

  # POST /notifications/mark_all_read
  def mark_all_read
    current_recipient.mark_notifications_as_read!

    respond_to do |format|
      format.html { redirect_to notifications_path, notice: "All notifications marked as read" }
      format.turbo_stream { head :ok }
    end
  end

  private

  def set_notification
    @notification = current_recipient.notifications.find(params[:id])
  end

  def current_recipient
    Current.user
  end

  def notification_url_for(notification)
    notification.params[:url] || notifications_path
  end
end
