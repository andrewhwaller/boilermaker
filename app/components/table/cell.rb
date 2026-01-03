# frozen_string_literal: true

class Components::Table::Cell < Components::Base
  ALIGNMENTS = {
    left: "text-left",
    center: "text-center",
    right: "text-right"
  }.freeze

  def initialize(align: :left, colspan: nil, rowspan: nil, actions: false, **attributes)
    @align = align
    @colspan = colspan
    @rowspan = rowspan
    @actions = actions
    @attributes = attributes
  end

  def view_template(&block)
    attrs = @attributes
    attrs[:colspan] = @colspan if @colspan
    attrs[:rowspan] = @rowspan if @rowspan

    td(class: css_classes(ALIGNMENTS[@align], (@actions ? "table-actions" : nil)), **attrs, &block)
  end
end
