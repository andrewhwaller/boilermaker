# frozen_string_literal: true

class Components::PageHeader < Components::Base
  Stat = Data.define(:value, :label, :highlight) do
    def initialize(value:, label:, highlight: false)
      super
    end
  end

  def initialize(title:, meta: nil, stats: [], **attributes)
    @title = title
    @meta = meta
    @stats = stats.map { |s| s.is_a?(Stat) ? s : Stat.new(**s) }
    @attributes = attributes
  end

  def view_template
    div(class: header_classes, **filtered_attributes) do
      title_section
      stats_section if @stats.any?
    end
  end

  private

  def header_classes
    css_classes(
      "mb-8",
      "flex justify-between items-end"
    )
  end

  def title_section
    div do
      h1(class: "text-lg font-semibold tracking-tight text-body") { @title }
      p(class: "text-[11px] text-muted mt-1") { @meta } if @meta
    end
  end

  def stats_section
    div(class: "flex gap-8 text-xs") do
      @stats.each { |stat| stat_item(stat) }
    end
  end

  def stat_item(stat)
    div(class: "flex items-baseline gap-1.5") do
      span(class: stat_value_classes(stat.highlight)) { stat.value }
      span(class: "text-muted") { stat.label }
    end
  end

  def stat_value_classes(highlight)
    base = "font-bold text-sm"
    highlight ? "#{base} text-accent" : "#{base} text-body"
  end
end
