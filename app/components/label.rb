# frozen_string_literal: true

class Components::Label < Components::Base
  def initialize(**attrs)
    @attrs = attrs
  end

  def view_template(&block)
    label(**@attrs, class: "block text-sm font-medium text-gray-700 mb-1", &block)
  end
end
