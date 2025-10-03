# frozen_string_literal: true

class Components::DropdownMenu < Components::Base
  DEFAULT_TRIGGER_OPTIONS = {
    type: "button",
    class: "btn btn-ghost font-medium",
    data: { action: nil },
    tabindex: 0,
    role: "button"
  }.freeze

  DEFAULT_MENU_OPTIONS = {
    class: "dropdown-content p-0 menu menu-sm bg-base-200 border border-base-300 rounded-box z-50 w-48",
    tabindex: 0,
    data: {}
  }.freeze

  def initialize(trigger_text: nil, align: :end, trigger: {}, menu: {}, **attributes)
    @trigger_text = trigger_text
    @align = align
    trigger_options = trigger.dup
    @trigger_content = trigger_options.delete(:content)
    @trigger_options = build_trigger_options(trigger_options)
    @menu_options = build_menu_options(menu)
    @attributes = attributes
  end

  def view_template(&block)
    div(
      class: css_classes("dropdown", alignment_class),
      data: { controller: "dropdown" }.merge(@attributes.fetch(:data, {})),
      tabindex: @attributes.fetch(:tabindex, 0),
      **filtered_attributes(:class, :data, :tabindex)
    ) do
      trigger
      menu(&block)
    end
  end

  private

  def alignment_class
    case @align
    when :end then "dropdown-end"
    when :top then "dropdown-top"
    when :bottom then "dropdown-bottom"
    when :start then nil
    else
      @align
    end
  end

  def trigger
    options = @trigger_options.dup
    button_class = options.delete(:class)
    data_attributes = options.delete(:data) || {}

    button(**options.merge(class: button_class, data: data_attributes)) do
      if @trigger_content.respond_to?(:call)
        instance_exec(&@trigger_content)
      elsif @trigger_text
        plain(@trigger_text)
      end

      chevron
    end
  end

  def menu(&block)
    return unless block

    options = @menu_options.dup
    list_class = options.delete(:class)
    data_attributes = { dropdown_target: "menu" }.merge(options.delete(:data) || {})
    tabindex = options.delete(:tabindex)

    ul(class: list_class, data: data_attributes, tabindex: tabindex, **options, &block)
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

  def build_trigger_options(overrides)
    defaults = DEFAULT_TRIGGER_OPTIONS.deep_dup
    defaults[:class] = merge_classes(defaults[:class], overrides.delete(:class))
    defaults[:data] = defaults[:data].merge(overrides.delete(:data) || {})
    defaults.merge!(overrides)
    defaults
  end

  def build_menu_options(overrides)
    defaults = DEFAULT_MENU_OPTIONS.deep_dup
    defaults[:class] = merge_classes(defaults[:class], overrides.delete(:class))
    defaults[:data] = defaults[:data].merge(overrides.delete(:data) || {})
    defaults.merge!(overrides)
    defaults
  end

  def merge_classes(*values)
    values.flatten.compact.map(&:to_s).map(&:strip).reject(&:empty?).join(" ")
  end
end
