# frozen_string_literal: true

# List with row indices (0, 1, 2...)
# Each row displays its index in a fixed-width column
class Components::IndexedList < Components::Base
  def initialize(items: [], start_index: 0, **attributes)
    @items = items
    @start_index = start_index
    @attributes = attributes
  end

  def view_template(&block)
    div(**@attributes, class: css_classes("text-sm")) {
      if @items.any?
        @items.each_with_index do |item, i|
          render_row(i, item, &block)
        end
      elsif block_given?
        yield
      end
    }
  end

  private

  def render_row(index, item, &block)
    div(class: "flex gap-4 py-1 border-b border-dotted border-border-light hover-glow") {
      span(class: "text-muted text-xs w-6 flex-shrink-0") { (@start_index + index).to_s }
      div(class: "flex-1") {
        yield(item) if block_given?
      }
    }
  end
end
