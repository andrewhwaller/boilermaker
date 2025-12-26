# frozen_string_literal: true

class Components::FormCard < Components::Card
  def initialize(title: nil, header_color: :success, **attrs)
    super(title: title, header_color: header_color, **attrs)
  end
end
