# frozen_string_literal: true

class Components::Table::Row < Components::Base
  VARIANTS = {
    active: "active"
  }.freeze

  def initialize(variant: nil, **attributes)
    @variant = variant
    @attributes = attributes
  end

  def view_template(&block)
    tr(class: css_classes(VARIANTS[@variant]), **@attributes, &block)
  end
end
