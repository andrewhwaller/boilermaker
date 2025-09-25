# frozen_string_literal: true

class Components::Table::Actions < Components::Base
  def initialize(items: [], align: :right, **attributes)
    @items = items
    @align = align
    @attributes = attributes
  end

  def view_template(&block)
    td(class: css_classes(*action_classes), **filtered_attributes) do
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
        render_action_button(item)
      when :link
        render_action_link(item)
      when :dropdown
        render_action_dropdown(item)
      end
    end
  end

  def render_action_button(item)
    button(
      class: "btn btn-ghost btn-xs",
      **item.fetch(:attributes, {})
    ) do
      item[:text]
    end
  end

  def render_action_link(item)
    a(
      href: item[:href],
      class: "btn btn-ghost btn-xs",
      **item.fetch(:attributes, {})
    ) do
      item[:text]
    end
  end

  def render_action_dropdown(item)
    div(class: "dropdown dropdown-end", style: "position: static;") do
      button(class: "btn btn-ghost btn-xs", tabindex: "0") do
        "⋯"
      end
      ul(class: "dropdown-content menu p-2 shadow bg-base-100 rounded-box w-52",
         style: "z-index: 9999 !important; position: absolute;",
         tabindex: "0") do
        item[:items].each do |dropdown_item|
          li do
            case dropdown_item[:type]
            when :link
              a(href: dropdown_item[:href], **dropdown_item.fetch(:attributes, {})) do
                dropdown_item[:text]
              end
            when :button
              button(**dropdown_item.fetch(:attributes, {})) do
                dropdown_item[:text]
              end
            end
          end
        end
      end
    end
  end
end
