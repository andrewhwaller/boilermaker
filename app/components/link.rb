# frozen_string_literal: true

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

  def initialize(href, text = nil, variant: :default, uppercase: false, **attributes)
    @href = href
    @text = text
    @variant = variant
    @uppercase = uppercase
    @attributes = attributes
  end

  def view_template(&block)
    a(href: @href || "", class: link_classes, **filtered_attributes) do
      if block
        yield
      else
        @text.present? ? @text : @href
      end
    end
  end

  private

  def link_classes
    css_classes(
      VARIANTS[@variant] || VARIANTS[:default],
      (@uppercase ? "uppercase" : nil)
    )
  end
end
