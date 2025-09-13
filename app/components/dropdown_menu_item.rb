# frozen_string_literal: true

class Components::DropdownMenuItem < Components::Base
  def initialize(href, text = nil, method: :get, **attributes)
    @href = href
    @text = text
    @method = method
    @attributes = attributes
  end

  def view_template
    li do
      a(href: @href || "#", class: link_classes, data: data_attributes, **filtered_attributes(:data)) do
        @text.present? ? @text : @href
      end
    end
  end

  private

  def link_classes
    [ "justify-start text-sm", @attributes[:class] ]
  end

  def data_attributes
    base_data = @attributes[:data] || {}
    base_data = base_data.merge(turbo_method: :delete) if @method == :delete
    base_data
  end
end
