# frozen_string_literal: true

class Components::Boilermaker::AlertList < Components::Boilermaker::Base
  class Item < Components::Boilermaker::Base
    STATUSES = {
      active: { dot_class: "bg-accent-alt", label: "Active" },
      paused: { dot_class: "bg-muted", label: "Paused" }
    }.freeze

    def initialize(name:, href:, count:, status:, updated:, has_new: false, **attributes)
      @name = name
      @href = href
      @count = count
      @status = status.to_sym
      @updated = updated
      @has_new = has_new
      @attributes = attributes
    end

    def view_template
      div(class: row_classes, **filtered_attributes) do
        name_cell
        count_cell
        status_cell
        updated_cell
      end
    end

    private

    def row_classes
      css_classes(
        "grid grid-cols-[1fr_auto_auto_auto] gap-6",
        "px-3.5 py-2.5",
        "border-b border-border-light last:border-b-0",
        "items-center text-[13px]",
        "hover:bg-surface-alt transition-colors"
      )
    end

    def name_cell
      div(class: "font-medium") do
        a(href: @href, class: "text-body no-underline hover:text-accent") { @name }
      end
    end

    def count_cell
      div(class: count_classes) { "#{@count} new" }
    end

    def count_classes
      base = "text-xs min-w-[60px]"
      @has_new ? "#{base} text-accent font-semibold" : "#{base} text-muted"
    end

    def status_cell
      status_config = STATUSES[@status] || STATUSES[:active]
      div(class: "text-[11px] text-muted flex items-center gap-1.5 min-w-[70px]") do
        span(class: "w-1.5 h-1.5 rounded-full #{status_config[:dot_class]}")
        plain status_config[:label]
      end
    end

    def updated_cell
      div(class: "text-[11px] text-muted min-w-[80px] text-right") { @updated }
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
        @items.each { |item_attrs| render Item.new(**item_attrs) }
      end
    end
  end

  private

  def list_classes
    css_classes("border border-border-default")
  end
end
