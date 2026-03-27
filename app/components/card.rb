# frozen_string_literal: true

class Components::Card < Components::Base
  def initialize(title: nil, content_class: nil, **attrs)
    @title = title
    @content_class = content_class
    @attrs = attrs
  end

  def view_template(&block)
    div(class: css_classes("ui-card", @attrs.delete(:class)), **@attrs) do
      if @title.present?
        div(class: header_classes) do
          h3(class: "text-sm font-bold tracking-wide uppercase") { @title }
        end
      end

      div(class: css_classes("ui-card-content", @content_class)) do
        yield if block_given?
      end
    end
  end

  private

  def header_classes
    "ui-card-header"
  end
end
