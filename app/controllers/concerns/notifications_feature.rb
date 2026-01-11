# frozen_string_literal: true

module NotificationsFeature
  extend ActiveSupport::Concern

  included do
    before_action :require_notifications_feature!
  end

  private

  def require_notifications_feature!
    return if Boilermaker.config.feature_enabled?("notifications")

    render plain: "Feature not available", status: :not_found
  end
end
