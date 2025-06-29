module Boilermaker
  class ApplicationController < ActionController::Base
    # For development and testing, skip CSRF verification to make API testing easier
    # In production, this should be properly handled with valid tokens
    protect_from_forgery with: :exception, unless: -> { Rails.env.development? || Rails.env.test? }

    # Engine should be isolated from main app authentication
    # but can access main app's current_user if needed

    private

    def current_user
      # Try to access main app's current_user if available
      if defined?(super)
        super
      elsif defined?(Current) && Current.respond_to?(:user)
        Current.user
      else
        nil
      end
    end

    def authenticate_user!
      # Simple authentication check - override in specific controllers if needed
      unless current_user
        redirect_to main_app.root_path, alert: "Please sign in to access this feature."
      end
    end
  end
end
