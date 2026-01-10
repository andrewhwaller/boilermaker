# frozen_string_literal: true

module PaymentsFeature
  extend ActiveSupport::Concern

  included do
    before_action :require_payments_feature!
  end

  private

  def require_payments_feature!
    return if Boilermaker.config.feature_enabled?("payments")

    render plain: "Feature not available", status: :not_found
  end
end
