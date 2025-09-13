# frozen_string_literal: true

class Components::Table::Cell < Components::Base
  ALIGNMENTS = {
    left: "text-left",
    center: "text-center", 
    right: "text-right"
  }.freeze

  def initialize(align: :left, colspan: nil, rowspan: nil, **attributes)
    @align = align
    @colspan = colspan
    @rowspan = rowspan
    @attributes = attributes
  end

  def view_template(&block)
    cell_attributes = @attributes.dup
    cell_attributes[:colspan] = @colspan if @colspan
    cell_attributes[:rowspan] = @rowspan if @rowspan
    
    cell_classes = [
      ALIGNMENTS[@align]
    ].compact.reject(&:empty?).join(" ")

    cell_attributes[:class] = [cell_attributes[:class], cell_classes].compact.join(" ") unless cell_classes.empty?

    td(**cell_attributes) do
      yield if block
    end
  end
end