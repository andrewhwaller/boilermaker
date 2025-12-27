# frozen_string_literal: true

# Panel with title bar (DOS-style)
# Renders a bordered box with a colored title bar and content area
class Components::BoxPanel < Components::Base
  def initialize(title:, **attributes, &block)
    @title = title
    @attributes = attributes
  end

  def view_template(&block)
    div(**@attributes, class: css_classes("border-2 border-accent mb-4")) {
      render_title_bar
      render_content(&block)
    }
  end

  private

  def render_title_bar
    div(class: "bg-accent text-surface px-3 py-1 font-bold text-sm tracking-wide") {
      @title
    }
  end

  def render_content(&block)
    div(class: "p-3") {
      yield if block_given?
    }
  end
end
