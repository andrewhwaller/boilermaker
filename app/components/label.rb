# frozen_string_literal: true

class Components::Label < Components::Base
  def initialize(for_id: nil, text: nil, required: false)
    @for_id = for_id
    @text = text
    @required = required
  end

  def view_template(&block)
    label(for: @for_id, class: "label") do
      span(class: "label-text") do
        if block
          yield
        else
          plain @text
        end

        span(class: "text-error ml-1") { "*" } if @required
      end
    end
  end
end
