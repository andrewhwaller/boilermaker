# frozen_string_literal: true

class Components::Table::Actions < Components::Base
  def initialize(items: [], align: :right, **attributes)
    @items = items
    @align = align
    @attributes = attributes
  end

  def view_template(&block)
    td(class: css_classes(*action_classes), **@attributes) do
      if block_given?
        div(class: "flex items-center gap-1", &block)
      else
        div(class: "flex items-center gap-1") { render_default_actions }
      end
    end
  end

  private

  def action_classes
    base = [ "whitespace-nowrap" ]
    base << case @align
    when :left then "text-left"
    when :center then "text-center"
    else "text-right"
    end
    base
  end

  def render_default_actions
    @items.each do |item|
      case item[:type]
      when :button
        render Components::Button.new(variant: :ghost, size: :xs, **item.fetch(:attributes, {})) { item[:text] }
      when :link
        render Components::Link.new(href: item[:href], variant: :ghost, size: :xs, **item.fetch(:attributes, {})) { item[:text] }
      when :dropdown
        render_action_dropdown(item)
      end
    end
  end

  def render_action_dropdown(item)
    div(class: "ui-dropdown") do
      render Components::Button.new(variant: :ghost, size: :xs, tabindex: "0") { "⋯" }
      ul(class: "ui-dropdown-content z-50 absolute w-52 p-2", tabindex: "0") do
        item[:items].each do |dropdown_item|
          li do
            case dropdown_item[:type]
            when :link
              a(href: dropdown_item[:href], class: "ui-menu-item", **dropdown_item.fetch(:attributes, {})) do
                dropdown_item[:text]
              end
            when :button
              button(class: "ui-menu-item", **dropdown_item.fetch(:attributes, {})) do
                dropdown_item[:text]
              end
            end
          end
        end
      end
    end
  end
end