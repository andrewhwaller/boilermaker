# frozen_string_literal: true

class Components::Card < Components::Base
  def initialize(title: nil, header_color: :primary, **attrs)
    @title = title
    @header_color = header_color
    @attrs = attrs
  end

  def view_template(&block)
    card_class = "bg-base-200 border border-base-300"
    card_class = [ card_class, @attrs.delete(:class) ].compact.join(" ")

    div(**@attrs.merge(class: card_class)) do
      if @title.present?
        div(class: "bg-#{@header_color}/20 border-b border-#{@header_color}/30 px-3 py-1") do
          h3(class: "text-xs font-bold text-#{@header_color} uppercase tracking-wide font-mono") { @title }
        end
      end

      div(class: "p-6") do
        yield if block_given?
      end
    end
  end
end
