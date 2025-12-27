# frozen_string_literal: true

class Components::Link < Components::Base
  VARIANTS = {
    default: "", # No longer adds "link" directly, it's added below
    primary: "link-primary",
    secondary: "link-secondary",
    accent: "link-accent",
    neutral: "link-neutral",
    success: "link-success",
    warning: "link-warning",
    error: "link-error",
    info: "link-info",
    button: "ui-button" # Apply base button style
  }.freeze

  def initialize(href:, text: nil, variant: :default, uppercase: nil, size: :md, external: false, **attributes)
    @href = href
    @text = text
    @variant = variant
    @uppercase = uppercase
    @size = size
    @external = external
    @attributes = attributes
  end

  def view_template(&block)
    a(href: @href || "", **link_attributes) do
      if block
        yield
      else
        @text.present? ? @text : @href
      end
    end
  end

  private

  def link_classes
    base_classes = []

    if @variant == :button
      base_classes << "ui-button"
      base_classes << Components::Button::VARIANTS[@variant] if Components::Button::VARIANTS[@variant]
      base_classes << Components::Button::SIZES[@size] if Components::Button::SIZES[@size]
    else
      base_classes << "link" # Always include the base "link" class
      base_classes << VARIANTS[@variant] if @variant != :default # Add variant specific class, but not "link" twice
    end

    css_classes(base_classes, link_casing_class)
  end

  def link_attributes
    attrs = @attributes.dup
    # Merge classes properly
    all_classes = link_classes
    if attrs[:class]
      all_classes += Array(attrs[:class])
      attrs.delete(:class)
    end

    attrs[:class] = all_classes
    attrs[:href] = @href || ""

    if @external
      attrs[:target] ||= "_blank"
      attrs[:rel] ||= "noopener noreferrer"
    end
    attrs
  end

  def link_casing_class
    return "uppercase" if @uppercase == true
    return "normal-case" if @uppercase == false

    nil
  end
end
