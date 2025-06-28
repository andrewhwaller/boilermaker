# frozen_string_literal: true

class Components::Label < Components::Base
  def initialize(for_id: nil, text: nil, required: false)
    @for_id = for_id
    @text = text
    @required = required
  end

  def view_template(&block)
    label_classes = "block text-sm font-medium text-foreground mb-2"

    label(for: @for_id, class: label_classes) do
      if block
        yield
      else
        plain @text
      end

      if @required
        span(class: "text-error ml-1") { "*" }
      end
    end
  end
end
