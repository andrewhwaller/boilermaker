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
      class: theme_toggle_classes,
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

  def theme_toggle_classes
    base_classes = "inline-flex items-center gap-1"

    case @position
    when :fixed
      orientation = @show_label ? "flex-col" : ""
      "#{base_classes} #{orientation} fixed bottom-4 right-4 z-50"
    when :navbar
      # Compact vertical layout for navbar - constrained height
      "#{base_classes} flex-col gap-0 items-center justify-center h-6"
    when :sidebar
      # Standard vertical layout for sidebar
      "#{base_classes} flex-col gap-1"
    else # :inline
      orientation = @show_label ? "flex-col" : ""
      "#{base_classes} #{orientation}"
    end
  end

  def toggle_button
    button(
      type: "button",
      class: "#{button_classes} #{initial_toggle_class}",
      data: {
        action: "click->theme#toggle",
        "theme-target": "toggle"
      },
      aria: {
        label: "Toggle theme",
        pressed: initial_is_dark?.to_s
      },
      role: "switch",
      title: toggle_title
    ) do
      # Slider track (knob placement handled via CSS)
      div(class: "pointer-events-none absolute inset-0 flex items-center px-[2px]") do
        span(
          class: indicator_classes,
          style: "--toggle-travel: #{travel_for_position}px"
        )
      end

      # Industrial/technical labels
      span(class: pos_label_classes) { "POS" }
      span(class: neg_label_classes) { "NEG" }
    end
  end

  def control_label
    label_class = case @position
    when :navbar
      "uppercase tracking-widest text-[6px] text-base-content/50 select-none"
    when :sidebar
      "uppercase tracking-widest text-[8px] text-base-content/60 select-none"
    else
      "uppercase tracking-widest text-[9px] text-base-content/60 select-none"
    end

    span(class: label_class) { "Display Polarity" }
  end

  def toggle_title
    "Toggle display polarity between positive and negative"
  end

  def button_classes
    base = "group relative inline-flex shrink-0 cursor-pointer rounded-box overflow-hidden " \
           "border border-base-300 bg-base-200 transition-colors duration-200 " \
           "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent " \
           "focus-visible:ring-offset-2 focus-visible:ring-offset-base-100 " \
           "disabled:cursor-not-allowed disabled:opacity-50 " \
           "hover:bg-base-300"

    size = case @position
    when :navbar
      "h-4 w-14"
    when :sidebar
      "h-7 w-24"
    else
      "h-9 w-28"
    end

    "#{base} #{size}"
  end

  def indicator_classes
    base = "z-10 rounded-selector bg-base-100 shadow-lg border border-base-content/20 will-change-transform theme-toggle-indicator"
    size = case @position
    when :navbar
      "h-3 w-6"
    when :sidebar
      "h-6 w-8"
    else
      "h-7 w-10"
    end
    "#{base} #{size}"
  end

  def pos_label_classes
    base = "pointer-events-none absolute inset-y-0 left-1 z-0 flex items-center tracking-wider uppercase text-base-content/60 select-none"
    text_size = case @position
    when :navbar
      "text-[7px]"
    when :sidebar
      "text-[8px]"
    else
      "text-[9px]"
    end
    "#{base} #{text_size}"
  end

  def neg_label_classes
    base = "pointer-events-none absolute inset-y-0 right-1 z-0 flex items-center tracking-wider uppercase text-base-content/60 select-none"
    text_size = case @position
    when :navbar
      "text-[7px]"
    when :sidebar
      "text-[8px]"
    else
      "text-[9px]"
    end
    "#{base} #{text_size}"
  end

  def travel_for_position
    case @position
    when :navbar then 22
    when :sidebar then 50
    when :mobile then 44
    else 60
    end
  end

  def initial_toggle_class
    initial_is_dark? ? "theme-toggle-dark" : ""
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
