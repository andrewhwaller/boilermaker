# frozen_string_literal: true

class Components::Table < Components::Base
  VARIANTS = {
    striped: "ui-table-striped", # formerly zebra
    bordered: "ui-table-bordered",
    header_pin: "ui-table-header-pin" # formerly pin_rows
  }.freeze

  SIZES = {
    xs: "ui-table-xs",
    sm: "ui-table-sm",
    md: "ui-table-sm", # Map to sm for a denser default
    lg: "ui-table-lg"
  }.freeze

  def initialize(variant: nil, size: :md, data: nil, headers: nil, **attributes)
    @variant = variant
    @size = size
    @data = data
    @headers = headers
    @attributes = attributes
  end

  def view_template(&block)
    table_classes = css_classes("ui-table", VARIANTS[@variant], SIZES[@size]) # Base table class
    if block
      table(class: table_classes, **@attributes, &block)
    else
      table(class: table_classes, **@attributes) { render_default_table }
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
          td(colspan: @headers&.length || 1, class: "text-center text-muted") do
            "No data available"
          end
        end
      end
    end
  end
end
