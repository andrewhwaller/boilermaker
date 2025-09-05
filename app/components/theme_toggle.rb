# frozen_string_literal: true

class Components::ThemeToggle < Components::Base
  def initialize(show_label: true, position: :inline, keyboard_shortcut: true)
    @show_label = show_label
    @position = position
    @keyboard_shortcut = keyboard_shortcut
  end

  def view_template
    div(
      class: theme_toggle_classes,
      data: {
        action: @keyboard_shortcut ? "keydown@window->theme#handleKeyboard" : nil
      }.compact
    ) do
      toggle_button
      keyboard_hint if @keyboard_shortcut && @show_label
    end
  end

  private

  def theme_toggle_classes
    base_classes = "flex items-center gap-2"

    case @position
    when :fixed
      "#{base_classes} fixed bottom-4 right-4 z-50"
    when :navbar
      "#{base_classes}"
    else # :inline
      base_classes
    end
  end

  def toggle_button
    button(
      type: "button",
      class: "group relative inline-flex h-9 w-16 shrink-0 cursor-pointer rounded-full " \
             "border border-base-300 bg-base-200 transition-colors duration-200 " \
             "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent " \
             "focus-visible:ring-offset-2 focus-visible:ring-offset-base-100 " \
             "disabled:cursor-not-allowed disabled:opacity-50 " \
             "hover:bg-base-300",
      data: {
        action: "click->theme#toggle",
        "theme-target": "button"
      },
      aria: {
        label: "Toggle theme",
        pressed: "false"
      },
      role: "switch",
      title: toggle_title
    ) do
      # Toggle switch track
      span(
        class: "pointer-events-none absolute left-[2px] top-[2px] h-7 w-7 " \
               "rounded-full bg-base-100 shadow-sm ring-0 transition-transform " \
               "duration-200 translate-x-0 " \
               "group-aria-pressed:translate-x-7",
        data: { "theme-target": "indicator" }
      ) do
        # Icons container
        span(class: "absolute inset-0 flex h-full w-full items-center justify-center") do
          # Sun icon (light mode)
          sun_icon
          # Moon icon (dark mode)
          moon_icon
        end
      end
    end
  end

  def sun_icon
    # Simple sun emoji as fallback until we implement proper SVG support
    span(
      class: "h-4 w-4 text-amber-500 transition-opacity duration-200 opacity-100 flex items-center justify-center text-sm",
      data: { "theme-target": "sunIcon" }
    ) { "☀️" }
  end

  def moon_icon
    # Simple moon emoji as fallback until we implement proper SVG support
    span(
      class: "h-4 w-4 text-slate-600 transition-opacity duration-200 opacity-0 flex items-center justify-center text-sm",
      data: { "theme-target": "moonIcon" }
    ) { "🌙" }
  end

  def keyboard_hint
    if @show_label
      span(class: "text-sm text-base-content hidden sm:inline") do
        "Press "
        kbd(class: "kbd kbd-xs") { "⌘" }
        kbd(class: "kbd kbd-xs") { "⇧" }
        kbd(class: "kbd kbd-xs") { "L" }
        " to toggle"
      end
    end
  end

  def toggle_title
    if @keyboard_shortcut
      "Toggle theme (⌘⇧L)"
    else
      "Toggle between light and dark theme"
    end
  end
end
