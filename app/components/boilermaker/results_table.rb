# frozen_string_literal: true

class Components::Boilermaker::ResultsTable < Components::Boilermaker::Base
  Column = Data.define(:key, :label, :width, :cell_class) do
    def initialize(key:, label:, width: nil, cell_class: nil)
      super
    end
  end

  def initialize(columns:, rows:, **attributes)
    @columns = columns.map { |c| c.is_a?(Column) ? c : Column.new(**c) }
    @rows = rows
    @attributes = attributes
  end

  def view_template
    table(class: table_classes, **filtered_attributes) do
      thead { header_row }
      tbody { @rows.each { |row| data_row(row) } }
    end
  end

  private

  def table_classes
    css_classes(
      "w-full border-collapse",
      "border border-border-default",
      "text-xs"
    )
  end

  def header_row
    tr do
      @columns.each { |col| header_cell(col) }
    end
  end

  def header_cell(column)
    th(
      class: "text-left px-3 py-2 text-[10px] uppercase tracking-wide text-muted font-medium border-b border-border-default bg-surface-alt",
      style: column.width ? "width: #{column.width}" : nil
    ) { column.label }
  end

  def data_row(row)
    tr(class: "hover:bg-surface-alt transition-colors") do
      @columns.each { |col| data_cell(row, col) }
    end
  end

  def data_cell(row, column)
    value = row[column.key]
    cell_class = column.cell_class || "text-body"

    td(class: "px-3 py-2 border-b border-border-light align-top #{cell_class}") do
      if value.is_a?(Hash) && value[:href]
        a(href: value[:href], class: "text-accent no-underline hover:underline") { value[:text] }
      else
        plain value.to_s
      end
    end
  end
end
