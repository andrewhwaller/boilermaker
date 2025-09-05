# frozen_string_literal: true

# FormCard - A shared component for consistent form presentation
# Wraps forms in a card with proper spacing and optional title
class Components::FormCard < Components::Base
  def initialize(title: nil, **card_attrs)
    @title = title
    @card_attrs = card_attrs
  end

  def view_template(&block)
    card_class = "card bg-base-100 shadow-sm"
    card_class = [ card_class, @card_attrs.delete(:class) ].compact.join(" ")

    div(**@card_attrs.merge(class: card_class)) do
      div(class: "card-body") do
        if @title.present?
          h1(class: "card-title") { @title }
        end
        yield if block_given?
      end
    end
  end
end
