# frozen_string_literal: true

# Link - A standardized link component with consistent Daisy UI styling
# Provides various link variants with proper Rails routing integration
class Components::Link < Components::Base
  VARIANTS = {
    default: "link link-hover",
    primary: "link link-primary link-hover",
    secondary: "link link-secondary link-hover",
    accent: "link link-accent link-hover",
    neutral: "link link-neutral link-hover",
    success: "link link-success link-hover",
    warning: "link link-warning link-hover",
    error: "link link-error link-hover",
    info: "link link-info link-hover",
    button: "btn"
  }.freeze

  def initialize(href, text = nil, variant: :default, external: false, uppercase: false, **attributes, &block)
    @href = href
    @text = text
    @variant = variant
    @external = external
    @uppercase = uppercase
    @attributes = attributes
    @block = block
  end

  def view_template(&block)
    # Determine link classes based on variant
    link_classes = VARIANTS[@variant] || VARIANTS[:default]

    # Handle external links - add security attributes
    if external? || external_link?
      @attributes[:target] = "_blank" unless @attributes.key?(:target)
      @attributes[:rel] = "noopener noreferrer" unless @attributes.key?(:rel)
    end

    # Apply uppercase transform if requested
    link_classes = "#{link_classes} uppercase" if @uppercase

    # Merge classes properly
    if @attributes[:class]
      link_classes = "#{link_classes} #{@attributes[:class]}"
      @attributes = @attributes.except(:class)
    end

    # Render anchor tag directly to avoid Rails context issues in tests
    a(href: @href || "", class: link_classes, **@attributes) do
      if @block
        @block.call
      elsif block
        yield
      elsif @text.present?
        @text
      else
        @href
      end
    end
  end

  private

  # Check if link was explicitly marked as external
  def external?
    @external == true
  end

  # Auto-detect external links based on URL pattern
  def external_link?
    return false unless @href.is_a?(String) && @href.present?

    # Check for absolute URLs that are external
    @href.match?(/\Ahttps?:\/\//) && !internal_domain?
  end

  # Check if the URL belongs to the current application domain
  def internal_domain?
    return false unless @href.is_a?(String) && @href.present?

    # Extract domain from URL
    uri = URI.parse(@href) rescue nil
    return false unless uri&.host

    # In development/test, consider localhost internal
    # In production, this would check against the actual domain
    uri.host.in?([ "localhost", "127.0.0.1" ]) ||
      uri.host == (Rails.application.config.force_ssl ?
        Rails.application.routes.default_url_options[:host] :
        "localhost"
      )
  end
end
