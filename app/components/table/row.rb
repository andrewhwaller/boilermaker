# frozen_string_literal: true

class Components::Table::Row < Components::Base
  VARIANTS = {
    active: "active",
    hover: "hover"
  }.freeze

  def initialize(variant: nil, **attributes)
    @variant = variant
    @attributes = attributes
  end

  def view_template(&block)
    row_classes = [
      VARIANTS[@variant]
    ].compact.reject(&:empty?).join(" ")

    tr(class: row_classes.empty? ? nil : row_classes, **@attributes) do
      yield if block
    end
  end
end