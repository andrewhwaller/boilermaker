# frozen_string_literal: true

class Components::Table::Actions < Components::Base
  def initialize(items: [], align: :right, **attributes)
    @items = items
    @align = align
    @attributes = attributes
  end

  def view_template(&block)
    td(class: action_classes, **@attributes) do
      div(class: "flex items-center gap-1") do
        if block
          yield
        else
          render_default_actions
        end
      end
    end
  end

  private

  def action_classes
    base_classes = [ "whitespace-nowrap" ]

    case @align
    when :left
      base_classes << "text-left"
    when :center
      base_classes << "text-center"
    when :right
      base_classes << "text-right"
    end

    base_classes.join(" ")
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
    div(class: "dropdown dropdown-end") do
      button(class: "btn btn-ghost btn-xs", tabindex: "0") do
        "⋯"
      end
      ul(class: "dropdown-content menu p-2 shadow bg-base-100 rounded-box w-52", tabindex: "0") do
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
