# frozen_string_literal: true

# FormCard - A shared component for consistent form presentation
# Wraps forms in a card with proper spacing and optional title
class Components::FormCard < Components::Base
  def initialize(title: nil, header_color: :success, **card_attrs)
    @title = title
    @header_color = header_color
    @card_attrs = card_attrs
  end

  def view_template(&block)
    card_class = "bg-base-200 border border-base-300"
    card_class = [ card_class, @card_attrs.delete(:class) ].compact.join(" ")

    div(**@card_attrs.merge(class: card_class)) do
      if @title.present?
        div(class: "bg-#{@header_color}/20 border-b border-#{@header_color}/30 px-3 py-1") do
          h1(class: "card-title text-xs font-bold text-#{@header_color} tracking-wide") { @title }
        end
      end

      div(class: "p-6") do
        yield if block_given?
      end
    end
  end
end
