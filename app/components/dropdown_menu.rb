# frozen_string_literal: true

class Components::DropdownMenu < Components::Base
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::ButtonTo

  def initialize(trigger_text:)
    @trigger_text = trigger_text
  end

  def view_template(&block)
    div(class: "relative", data: { controller: "dropdown" }) do
      trigger
      menu(&block)
    end
  end

  private

  def trigger
    button(
      type: "button",
      class: "inline-flex items-center px-3 py-2 text-sm font-medium text-foreground hover:text-secondary focus:outline-none bg-transparent border-0",
      data: { action: "click->dropdown#toggle" }
    ) do
      @trigger_text
      chevron
    end
  end

  def menu(&block)
    div(
      class: "absolute right-0 mt-2 w-48 bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 shadow-lg z-50 hidden",
      data: { dropdown_target: "menu" }
    ) do
      div(class: "py-1", &block)
    end
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