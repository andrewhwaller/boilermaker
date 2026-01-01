# frozen_string_literal: true

# F1-F10 function key bar (Amber theme style)
# Renders a horizontal bar with function key labels and their actions
class Components::Boilermaker::FkeyBar < Components::Boilermaker::Base
  KEYS = %w[F1 F2 F3 F4 F5 F6 F7 F8 F9 F10].freeze

  def initialize(actions: {}, **attributes)
    @actions = actions.transform_keys { |k| k.to_s.upcase }
    @attributes = attributes
  end

  def view_template
    div(**@attributes, class: css_classes("flex border-t-2 border-accent pt-2 mt-4")) {
      KEYS.each { |key| render_key(key) }
    }
  end

  private

  def render_key(key)
    div(class: "flex-1 text-center text-xs") {
      span(class: "bg-accent text-surface px-1 font-bold") { key }
      span(class: "text-muted ml-1") { @actions[key] || "" }
    }
  end
end
