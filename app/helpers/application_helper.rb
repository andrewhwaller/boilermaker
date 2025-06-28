module ApplicationHelper
  def nav_link_class(path)
    current_page?(path) ? "text-primary" : "text-muted hover:text-foreground"
  end

  def user_signed_in?
    Current.user.present?
  end

  def default_url_options
    { host: "localhost", port: 3000 }
  end

  def flash_class(type)
    base_classes = "p-4 mb-4"
    type_classes = case type.to_sym
    when :notice, :success
      "bg-success/10 text-success"
    when :alert, :error
      "bg-error/10 text-error"
    else
      "bg-muted/10 text-muted"
    end
    "#{base_classes} #{type_classes}"
  end

  # Boilermaker configuration helpers
  def boilermaker_config
    Boilermaker.config
  end

  def app_name
    Boilermaker.config.app_name
  end

  def app_version
    Boilermaker.config.app_version
  end

  def feature_enabled?(feature_name)
    Boilermaker.config.feature_enabled?(feature_name)
  end

  def primary_color
    Boilermaker.config.primary_color
  end

  def secondary_color
    Boilermaker.config.secondary_color
  end

  # Helper to conditionally render content if feature is enabled
  def if_feature_enabled(feature_name, &block)
    if feature_enabled?(feature_name)
      yield if block_given?
    end
  end

  # Page title helpers
  def page_title(title = nil)
    if title.present?
      "#{title} | #{app_name}"
    elsif content_for?(:title)
      "#{content_for(:title)} | #{app_name}"
    else
      app_name
    end
  end

  def set_title(title)
    content_for :title, title
  end
end
