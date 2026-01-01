# frozen_string_literal: true

class Components::Boilermaker::ActivityList < Components::Boilermaker::Base
  class Item < Components::Boilermaker::Base
    def initialize(time:, **attributes, &content_block)
      @time = time
      @attributes = attributes
      @content_block = content_block
    end

    def view_template(&block)
      div(class: item_classes, **filtered_attributes) do
        time_cell
        content_cell(&block)
      end
    end

    private

    def item_classes
      css_classes(
        "flex gap-3",
        "py-2 border-b border-border-light last:border-b-0"
      )
    end

    def time_cell
      span(class: "text-[11px] text-muted min-w-[70px] flex-shrink-0") { @time }
    end

    def content_cell(&block)
      span(class: "text-body text-xs") do
        if block_given?
          yield
        elsif @content_block
          @content_block.call
        end
      end
    end
  end

  def initialize(items: [], **attributes)
    @items = items
    @attributes = attributes
  end

  def view_template(&block)
    div(class: list_classes, **filtered_attributes) do
      if block_given?
        yield
      else
        @items.each do |item_attrs|
          content = item_attrs.delete(:content)
          render Item.new(**item_attrs) { content }
        end
      end
    end
  end

  private

  def list_classes
    css_classes("text-xs")
  end
end
