# frozen_string_literal: true

class Components::Table < Components::Base
  VARIANTS = {
    zebra: "table-zebra",
    pin_rows: "table-pin-rows",
    pin_cols: "table-pin-cols",
    dense: "table-dense",
    bordered: "table-bordered"
  }.freeze

  SIZES = {
    xs: "table-xs",
    sm: "table-sm",
    md: "",  # Default size, no class needed
    lg: "table-lg"
  }.freeze

  def initialize(variant: nil, size: :md, data: nil, headers: nil, **attributes)
    @variant = variant
    @size = size
    @data = data
    @headers = headers
    @attributes = attributes
  end

  def view_template(&block)
    table_classes = [
      "table",
      VARIANTS[@variant],
      SIZES[@size]
    ].compact.reject(&:empty?).join(" ")

    table(class: table_classes, **@attributes) do
      if block
        yield
      else
        render_default_table
      end
    end
  end

  private

  def render_default_table
    if @headers&.any?
      thead do
        tr do
          @headers.each do |header|
            th { header.to_s }
          end
        end
      end
    end

    if @data&.any?
      tbody do
        @data.each do |row|
          tr do
            case row
            when Array
              row.each { |cell| td { cell.to_s } }
            when Hash
              @headers&.each { |header| td { row[header].to_s } }
            else
              td { row.to_s }
            end
          end
        end
      end
    else
      tbody do
        tr do
          td(colspan: @headers&.length || 1, class: "text-center text-base-content/60") do
            "No data available"
          end
        end
      end
    end
  end
end
