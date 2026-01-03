# frozen_string_literal: true

# Technical drawing title block (blueprint-style)
# Displays a title, optional description, and metadata in a grid layout
class Components::Boilermaker::TitleBlock < Components::Boilermaker::Base
  def initialize(title:, description: nil, user: nil, date: nil, revision: nil, **attributes)
    @title = title
    @description = description
    @meta = {
      "USER" => user,
      "DATE" => date,
      "REV" => revision
    }.compact
    @attributes = attributes
  end

  def view_template
    div(**@attributes, class: css_classes("border-2 border-accent grid grid-cols-[1fr_auto] mb-10")) {
      render_main_content
      render_metadata if @meta.any?
    }
  end

  private

  def render_main_content
    div(class: @meta.any? ? "px-5 py-4 border-r-2 border-accent" : "px-5 py-4") {
      div(class: "text-lg font-bold text-accent tracking-[0.05em] mb-1") { @title }
      div(class: "text-[11px] text-muted") { @description } if @description
    }
  end

  def render_metadata
    div(class: "px-4 py-2 text-[10px] min-w-[180px] flex flex-col justify-center gap-1") {
      @meta.each do |label, value|
        div(class: "flex justify-between") {
          span(class: "text-muted") { label }
          span(class: "font-semibold text-accent") { value }
        }
      end
    }
  end
end
