# frozen_string_literal: true

class ApplicationNotifier < Noticed::Event
  deliver_by :database

  notification_methods do
    def message
      params[:message] || "New notification"
    end

    def url
      params[:url]
    end
  end
end
