# frozen_string_literal: true

# Example notifier - customize or replace with your own
#
# Usage:
#   WelcomeNotifier.with(message: "Welcome to the app!").deliver(user)
#
class WelcomeNotifier < ApplicationNotifier
  deliver_by :database

  notification_methods do
    def message
      params[:message] || "Welcome to #{Boilermaker.config.app_name}!"
    end
  end
end
