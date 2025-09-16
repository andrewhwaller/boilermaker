# frozen_string_literal: true

module NavigationHelpers
  extend ActiveSupport::Concern

  private

  def current_user_display_name
    Current.user&.email&.split("@")&.first&.capitalize || "User"
  end

  def current_route?(path)
    return false unless @request

    # Handle root path specially
    if path == root_path || path == "/"
      @request.path == "/" || @request.path == root_path
    else
      @request.path.start_with?(path)
    end
  end

  def show_branding?
    boilermaker_config.get("ui.navigation.show_branding") != false
  end

  def show_account_dropdown?
    boilermaker_config.get("ui.navigation.show_account_dropdown") != false
  end

  def nav_item_class(path, base_classes: "btn btn-sm")
    if current_route?(path)
      "#{base_classes} btn-secondary"
    else
      "#{base_classes} btn-ghost"
    end
  end
end
