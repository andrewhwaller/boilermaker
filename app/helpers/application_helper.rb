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
end
