# frozen_string_literal: true

# Section with circled letter marker (blueprint-style)
# Used to mark and label sections with a prominent marker
# The marker hangs into the page's left margin area
class Components::Boilermaker::SectionMarker < Components::Boilermaker::Base
  def initialize(letter:, title:, ref: nil, **attributes, &block)
    @letter = letter
    @title = title
    @ref = ref
    @attributes = attributes
  end

  def view_template(&block)
    section(**@attributes, class: css_classes("relative mb-10")) {
      render_marker
      render_header
      yield if block_given?
    }
  end

  private

  def render_marker
    div(
      class: "absolute -left-[30px] top-0 w-5 h-5 border-2 border-accent bg-surface " \
             "flex items-center justify-center text-[10px] font-bold text-accent"
    ) { @letter }
  end

  def render_header
    div(class: "flex justify-between items-center border-b border-accent pb-2 mb-4") {
      span(class: "text-[11px] uppercase tracking-[0.1em] text-accent") { @title }
      span(class: "text-[9px] text-muted font-normal") { @ref } if @ref
    }
  end
end
