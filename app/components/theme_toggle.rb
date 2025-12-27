# frozen_string_literal: true

class Components::ThemeToggle < Components::Base
  include ApplicationHelper

  def initialize(show_label: true, position: :inline)
    @show_label = show_label
    @position = position
  end

  def view_template
    div(
      class: container_classes,
      data: {
        controller: "theme",
        "theme-default-polarity-value": default_polarity
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
        label: "Toggle light/dark mode",
        pressed: initial_is_dark?.to_s
      },
      role: "switch",
      title: "Toggle between light and dark mode"
    ) do
      span(class: "tracking-wider") { current_polarity_label }
    end
  end

  def control_label
    if @position == :navbar
      div(class: "flex flex-col items-center leading-tight text-muted select-none uppercase tracking-wide") do
        span(class: "text-[7px]") { "Display" }
        span(class: "text-[7px]") { "Mode" }
      end
    else
      label_class = case @position
      when :sidebar
        "text-[8px] text-muted select-none uppercase tracking-wide"
      else
        "text-[9px] text-muted select-none uppercase tracking-wide"
      end

      span(class: label_class) { "Display Mode" }
    end
  end

  def button_classes
    base = "relative flex items-center justify-center cursor-pointer select-none " \
      "border border-border-default bg-surface text-body transition-all duration-150 " \
      "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent " \
      "focus-visible:ring-offset-2 " \
      "disabled:cursor-not-allowed disabled:opacity-50 " \
      "active:scale-95 hover:bg-surface-alt"

    size = case @position
    when :navbar
      "h-7 w-20 text-xs"
    when :sidebar
      "h-8 w-20 text-xs"
    else
      "h-10 w-24 text-sm"
    end

    "#{base} #{size}"
  end

  def current_polarity_label
    initial_is_dark? ? "DARK" : "LIGHT"
  end

  def initial_is_dark?
    Current.polarity == "dark"
  end

  def default_polarity
    Boilermaker::Themes.default_polarity_for(Current.theme_name || Boilermaker::Themes::DEFAULT)
  end
end
