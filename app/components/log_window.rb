# frozen_string_literal: true

# Timestamped log window with scrollable entries
# Each entry has timestamp, type badge, and message
class Components::LogWindow < Components::Base
  Entry = Data.define(:time, :type, :message)

  def initialize(entries: [], height: "120px", **attributes)
    @entries = entries.map { |e| e.is_a?(Entry) ? e : Entry.new(**e) }
    @height = height
    @attributes = attributes
  end

  def view_template
    div(
      **@attributes,
      class: css_classes(
        "bg-surface-alt/50 p-2 overflow-y-auto text-xs font-mono"
      ),
      style: "height: #{@height}"
    ) {
      if @entries.any?
        @entries.each { |entry| render_entry(entry) }
      else
        render_empty_state
      end
    }
  end

  private

  def render_entry(entry)
    div(class: "mb-0.5") {
      span(class: "text-muted") { "[#{entry.time}]" }
      span(class: "text-accent ml-2") { "[#{entry.type}]" }
      span(class: "text-body ml-2") { entry.message }
    }
  end

  def render_empty_state
    div(class: "text-muted italic") { "No log entries" }
  end
end
