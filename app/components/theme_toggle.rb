# frozen_string_literal: true

class Components::ThemeToggle < Components::Base
  include ApplicationHelper

  def initialize(show_label: true, position: :inline, light_theme: nil, dark_theme: nil)
    @show_label = show_label
    @position = position
    @light_theme = light_theme
    @dark_theme = dark_theme
  end

  def view_template
    div(
      class: container_classes,
      data: {
        controller: "theme",
        "theme-light-name-value": light_theme_name,
        "theme-dark-name-value": dark_theme_name
      }
    ) do
      control_label if @show_label
      toggle_button
    end
  end

  private

  def container_classes
    base_classes = "inline-flex items-center"

    case @position
    when :navbar
      # Horizontal layout for navbar
      gap = @show_label ? "gap-2" : "gap-0"
      "#{base_classes} #{gap}"
    when :sidebar
      "#{base_classes} flex-col gap-1"
    else # :inline or :fixed
      gap = @show_label ? "gap-1" : "gap-0"
      orientation = @show_label ? "flex-col" : ""
      position = @position == :fixed ? "fixed bottom-4 right-4 z-50" : ""
      "#{base_classes} #{gap} #{orientation} #{position}".strip
    end
  end

  def toggle_button
    button(
      type: "button",
      class: button_classes,
      data: {
        action: "click->theme#toggle",
        "theme-target": "toggle",
        dark: initial_is_dark?
      },
      aria: {
        label: "Toggle theme",
        pressed: initial_is_dark?.to_s
      },
      role: "switch",
      title: toggle_title
    ) do
      span(class: "tracking-wider") { current_polarity_label }
    end
  end

  def control_label
    if @position == :navbar
      div(class: "flex flex-col items-center leading-tight text-base-content/80 select-none uppercase tracking-wide") do
        span(class: "text-[7px]") { "Display" }
        span(class: "text-[7px]") { "Polarity" }
      end
    else
      label_class = case @position
      when :sidebar
        "text-[8px] text-base-content/80 select-none uppercase tracking-wide"
      else
        "text-[9px] text-base-content/80 select-none uppercase tracking-wide"
      end

      span(class: label_class) { "Display Polarity" }
    end
  end

  def toggle_title
    "Toggle display polarity between positive and negative"
  end

  def button_classes
    base = "relative flex items-center justify-center cursor-pointer select-none " \
      "border rounded-box transition-all duration-150 " \
      "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent " \
      "focus-visible:ring-offset-2 focus-visible:ring-offset-base-100 " \
      "disabled:cursor-not-allowed disabled:opacity-50 " \
      "active:scale-95"

    size = case @position
    when :navbar
      "h-7 w-28 text-xs"
    when :sidebar
      "h-8 w-28 text-xs"
    else
      "h-10 w-32 text-sm"
    end

    "#{base} #{size}"
  end

  def current_polarity_label
    initial_is_dark? ? "NEGATIVE" : "POSITIVE"
  end

  def initial_is_dark?
    current_theme = Current.theme_name || light_theme_name
    current_theme == dark_theme_name
  end

  def light_theme_name
    @light_theme || boilermaker_config.theme_light_name
  end

  def dark_theme_name
    @dark_theme || boilermaker_config.theme_dark_name
  end
end
