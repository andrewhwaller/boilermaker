# frozen_string_literal: true

class Components::ThemeToggle < Components::Base
  def initialize(show_label: true, position: :inline)
    @show_label = show_label
    @position = position
  end

  def view_template
    div(
      class: theme_toggle_classes,
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
      orientation = @show_label ? "flex-col" : ""
      "#{base_classes} #{orientation}"
    else # :inline
      orientation = @show_label ? "flex-col" : ""
      "#{base_classes} #{orientation}"
    end
  end

  def toggle_button
    button(
      type: "button",
      class: "group relative inline-flex h-9 w-28 shrink-0 cursor-pointer rounded-box overflow-hidden " \
             "border border-base-300 bg-base-200 transition-colors duration-200 " \
             "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent " \
             "focus-visible:ring-offset-2 focus-visible:ring-offset-base-100 " \
             "disabled:cursor-not-allowed disabled:opacity-50 " \
             "hover:bg-base-300",
      data: {
        action: "click->theme#animateToggle",
        "theme-target": "button"
      },
      aria: {
        label: "Toggle theme",
        pressed: "false"
      },
      role: "switch",
      title: toggle_title
    ) do
      # Simple, reliable slider: flex-align left/right based on aria-pressed
      div(class: "pointer-events-none absolute inset-0 flex items-center px-[2px] justify-start") do
        span(
          class: "h-7 w-8 z-10 rounded-selector bg-base-100 shadow-sm ring-0 will-change-transform",
          data: { "theme-target": "indicator" }
        )
      end

      # Industrial/technical labels
      span(class: "pointer-events-none absolute inset-y-0 left-2 z-0 flex items-center text-[9px] font-mono tracking-wider uppercase text-base-content/60 select-none") { "POS" }
      span(class: "pointer-events-none absolute inset-y-0 right-2 z-0 flex items-center text-[9px] font-mono tracking-wider uppercase text-base-content/60 select-none") { "NEG" }
    end
  end

  def control_label
    span(class: "uppercase tracking-widest text-[9px] font-mono text-base-content/60 select-none") { "Display Polarity" }
  end

  def toggle_title
    "Toggle display polarity between positive and negative"
  end
end
