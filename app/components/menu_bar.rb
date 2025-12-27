# frozen_string_literal: true

# Menu bar with underlined hotkeys (DOS-style)
# Renders horizontal menu items with optional underlined hotkey characters
class Components::MenuBar < Components::Base
  Item = Data.define(:label, :hotkey_index, :href, :active) do
    def initialize(label:, hotkey_index: 0, href: "#", active: false) = super
  end

  def initialize(items:, **attributes)
    @items = items.map { |i| i.is_a?(Item) ? i : Item.new(**i) }
    @attributes = attributes
  end

  def view_template
    div(**@attributes, class: css_classes("flex bg-accent text-surface text-sm")) {
      @items.each { |item| render_item(item) }
    }
  end

  private

  def render_item(item)
    base_classes = "px-4 py-1"
    state_classes = item.active ? "bg-surface text-accent" : "hover:bg-surface hover:text-accent"

    a(href: item.href, class: "#{base_classes} #{state_classes}") {
      render_label_with_hotkey(item.label, item.hotkey_index)
    }
  end

  def render_label_with_hotkey(label, index)
    label.chars.each_with_index do |char, i|
      if i == index
        span(class: "underline") { char }
      else
        plain char
      end
    end
  end
end
