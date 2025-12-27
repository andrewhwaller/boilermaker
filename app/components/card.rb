# frozen_string_literal: true

class Components::Card < Components::Base
  def initialize(title: nil, header_color: nil, **attrs)
    @title = title
    @header_color = header_color
    @attrs = attrs
  end

  def view_template(&block)
    div(class: css_classes("ui-card", @attrs.delete(:class)), **@attrs) do
      if @title.present?
        div(class: header_classes) do
          h3(class: "text-sm font-bold tracking-wide uppercase") { @title }
        end
      end

      div(class: "ui-card-content") do
        yield if block_given?
      end
    end
  end

  private

  def header_classes
    return "ui-card-header" unless @header_color

    "ui-card-header ui-card-header-#{@header_color}"
  end
end
