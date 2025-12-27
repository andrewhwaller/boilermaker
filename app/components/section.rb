# frozen_string_literal: true

class Components::Section < Components::Base
  def initialize(title:, action_text: nil, action_href: nil, **attributes)
    @title = title
    @action_text = action_text
    @action_href = action_href
    @attributes = attributes
  end

  def view_template(&block)
    section(class: section_classes, **filtered_attributes) do
      section_header
      yield if block_given?
    end
  end

  private

  def section_classes
    css_classes("mb-8")
  end

  def section_header
    div(class: header_classes) do
      span(class: title_classes) { @title }
      action_link if @action_text && @action_href
    end
  end

  def header_classes
    "flex justify-between items-center pb-2 border-b border-border-light mb-3"
  end

  def title_classes
    "text-[11px] uppercase tracking-widest text-muted"
  end

  def action_link
    a(href: @action_href, class: action_classes) { @action_text }
  end

  def action_classes
    "text-[11px] text-accent no-underline hover:underline"
  end
end
