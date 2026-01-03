# frozen_string_literal: true

class Components::Boilermaker::StatsRow < Components::Boilermaker::Base
  Stat = Data.define(:value, :label, :highlight) do
    def initialize(value:, label:, highlight: false)
      super
    end
  end

  def initialize(stats:, **attributes)
    @stats = stats.map { |s| s.is_a?(Stat) ? s : Stat.new(**s) }
    @attributes = attributes
  end

  def view_template
    div(class: row_classes, **filtered_attributes) do
      @stats.each { |stat| stat_item(stat) }
    end
  end

  private

  def row_classes
    css_classes("flex gap-8 text-xs")
  end

  def stat_item(stat)
    div(class: "flex items-baseline gap-1.5") do
      span(class: value_classes(stat.highlight)) { stat.value }
      span(class: "text-muted") { stat.label }
    end
  end

  def value_classes(highlight)
    base = "font-bold text-sm"
    highlight ? "#{base} text-accent" : "#{base} text-body"
  end
end
