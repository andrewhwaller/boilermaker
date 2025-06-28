# frozen_string_literal: true

class Components::Input < Components::Base
  def initialize(**attrs)
    @attrs = attrs
  end

  def view_template
    input(**@attrs, class: "px-2 py-1 border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500")
  end
end
