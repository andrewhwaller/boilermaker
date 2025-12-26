# frozen_string_literal: true

class Components::DropdownMenu < Components::Base
  def initialize(trigger_text: nil, align: :end, trigger_options: {}, menu_options: {}, **attributes)
    @trigger_text = trigger_text
    @align = align
    @trigger_options = trigger_options
    @menu_options = menu_options
    @attributes = attributes
  end

  def view_template(&block)
    div(
      class: css_classes("dropdown", alignment_class, @attributes.delete(:class)),
      data: { controller: "dropdown" }.merge(@attributes.delete(:data) || {}),
      tabindex: @attributes.delete(:tabindex),
      **@attributes
    ) do
      trigger
      menu(&block)
    end
  end

  private

  def alignment_class
    case @align
    when :end then "dropdown-end" # This class will be applied to the dropdown-content
    when :top then "dropdown-top"
    when :bottom then "dropdown-bottom"
    when :start then "dropdown-start"
    else
      nil
    end
  end

  def trigger
    render Components::Button.new(
      type: @trigger_options.fetch(:type, :button),
      variant: @trigger_options.fetch(:variant, :ghost),
      size: @trigger_options.fetch(:size, :md),
      **@trigger_options.except(:type, :variant, :size, :content)
    ) do
      if @trigger_options[:content].respond_to?(:call)
        instance_exec(&@trigger_options[:content])
      elsif @trigger_text
        plain(@trigger_text)
      end
      chevron
    end
  end

  def menu(&block)
    return unless block

    ul_classes = css_classes("dropdown-content bg-card border border-border shadow-md z-50 w-48 p-2", alignment_class, @menu_options.delete(:class))
    ul(class: ul_classes, tabindex: 0, **@menu_options, &block)
  end

  def chevron
    svg(
      class: "ml-2 h-4 w-4",
      fill: "none",
      stroke: "currentColor",
      viewBox: "0 0 24 24"
    ) do |s|
      s.path(
        stroke_linecap: "round",
        stroke_linejoin: "round",
        stroke_width: "2",
        d: "M19 9l-7 7-7-7"
      )
    end
  end
end