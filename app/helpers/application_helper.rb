module ApplicationHelper
  def user_signed_in?
    Current.user.present?
  end

  def default_url_options
    { host: "localhost", port: 3000 }
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

  # Determine the initial theme name for server render
  # Always returns a valid theme name so data-theme is never missing.
  def current_theme_name
    @initial_theme_name.presence || Boilermaker::Config.theme_light_name
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

  # Font configuration helpers
  def font_stylesheet_link_tag
    # Ensure configuration is loaded
    Boilermaker::Config.load! unless Boilermaker::Config.data

    font_name = Boilermaker::Config.font_name
    return nil if Boilermaker::FontConfiguration.local_font?(font_name)

    tags = []

    Boilermaker::FontConfiguration.preconnect_urls(font_name).each do |link|
      options = { rel: "preconnect", href: link[:href] }
      options[:crossorigin] = link[:crossorigin] if link.key?(:crossorigin)
      tags << tag(:link, **options)
    end

    Boilermaker::FontConfiguration.preload_links(font_name).each do |link|
      options = { rel: "preload", href: link[:href] }
      options[:as] = link[:as] if link[:as]
      options[:type] = link[:type] if link[:type]
      options[:crossorigin] = link[:crossorigin] if link.key?(:crossorigin)
      tags << tag(:link, **options)
    end

    stylesheets = Boilermaker::FontConfiguration.stylesheet_urls(font_name)
    stylesheets.each do |url|
      tags << tag(:link, rel: "stylesheet", href: url)
    end

    Boilermaker::FontConfiguration.style_blocks(font_name).each do |css|
      next if css.blank?
      tags << "<style>#{css}</style>"
    end

    return nil if tags.empty?

    tags.map(&:to_s).join("\n").html_safe
  end

  alias_method :google_fonts_link_tag, :font_stylesheet_link_tag

  def app_font_family
    font_name = Boilermaker::Config.font_name
    Boilermaker::FontConfiguration.font_family_stack(font_name)
  end

  def app_font_style_tag
    font_stack = app_font_family
    fallback_fonts = extract_fallback_fonts(font_stack)

    <<~STYLE.html_safe
      <style>
        :root {
          --app-font-family: #{font_stack};
          --app-font-family-fallback: #{fallback_fonts};
          --app-text-transform: #{app_text_transform};
          --app-font-scale: #{app_base_font_size};
        }
      </style>
    STYLE
  end

  private

  def extract_fallback_fonts(font_stack)
    stack_parts = font_stack.gsub(/["']/, "").split(",").map(&:strip)
    stack_parts.drop(1).join(", ")
  end

  def app_text_transform
    Boilermaker::Config.ui_text_transform
  end

  def app_base_font_size
    if Boilermaker::Config.respond_to?(:font_size_multiplier)
      Boilermaker::Config.font_size_multiplier
    else
      size = Boilermaker::Config.get("ui.typography.size")
      case size.to_s.downcase
      when "dense" then 0.9
      when "expanded" then 1.12
      else
        1.0
      end
    end
  end
end
