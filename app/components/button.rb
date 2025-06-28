# frozen_string_literal: true

class Components::Button < Components::Base
  def initialize(**attrs)
    @attrs = attrs
  end

  def view_template(&block)
    button(**@attrs, class: "px-4 py-1 font-medium bg-button text-button-text border border-button hover:bg-button-hover focus:outline-none disabled:opacity-50 disabled:cursor-not-allowed", &block)
  end
end
