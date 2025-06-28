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
end
