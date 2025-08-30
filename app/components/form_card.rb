# frozen_string_literal: true

# FormCard - A shared component for consistent form presentation
# Wraps forms in a card with proper spacing and optional title
class Components::FormCard < Components::Base
  def initialize(title: nil, **card_attrs)
    @title = title
    @card_attrs = card_attrs
  end

  def view_template(&block)
    # Implement card styling directly
    card_class = "bg-surface border border-border rounded-lg p-6 shadow-sm"
    card_class = [ card_class, @card_attrs.delete(:class) ].compact.join(" ")

    div(**@card_attrs.merge(class: card_class)) do
      if @title.present?
        h1(class: "text-2xl font-bold text-foreground mb-6") { @title }
      end

      yield if block_given?
    end
  end
end
