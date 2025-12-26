# frozen_string_literal: true

class Components::Card < Components::Base
  def initialize(title: nil, header_color: nil, **attrs)
    @title = title
    @header_color = header_color
    @attrs = attrs
  end

  def view_template(&block)
    div(class: css_classes("card", @attrs.delete(:class)), **@attrs) do
      if @title.present?
        div(class: header_classes) do
          h3(class: "text-sm font-bold tracking-wide uppercase") { @title }
        end
      end

      div(class: "card-content") do
        yield if block_given?
      end
    end
  end

  private

  def header_classes
    return "card-header" unless @header_color

    "card-header card-header-#{@header_color}"
  end
end
