# frozen_string_literal: true

class Components::DropdownMenuItem < Components::Base
  def initialize(href: nil, text: nil, method: :get, **attributes)
    @href = href
    @text = text
    @method = method
    @attributes = attributes
  end

  def view_template
    li do
      a(href: @href || "#", class: link_classes, data: data_attributes, **@attributes.except(:class, :data)) do
        @text.present? ? @text : @href
      end
    end
  end

  private

  def link_classes
    css_classes("menu-item", @attributes.delete(:class))
  end

  def data_attributes
    base_data = @attributes.delete(:data) || {}
    base_data = base_data.merge(turbo_method: :delete) if @method == :delete
    base_data
  end
end