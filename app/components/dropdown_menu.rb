# frozen_string_literal: true

class Components::DropdownMenu < Components::Base
  def initialize(trigger_text:)
    @trigger_text = trigger_text
  end

  def view_template(&block)
    div(class: "dropdown dropdown-end", data: { controller: "dropdown" }, tabindex: 0) do
      trigger
      menu(&block)
    end
  end

  private

  def trigger
    button(
      type: "button",
      class: "btn btn-ghost",
      data: { action: nil },
      tabindex: 0,
      role: "button"
    ) do
      @trigger_text if @trigger_text
      chevron
    end
  end

  def menu(&block)
    ul(
      class: "dropdown-content menu menu-sm gap-1 p-2 shadow bg-base-200 border border-base-300 rounded-box z-50 w-48 mt-2",
      tabindex: 0,
      data: { dropdown_target: "menu" },
      &block
    )
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
