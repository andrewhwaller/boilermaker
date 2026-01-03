# frozen_string_literal: true

class Components::Table::Header < Components::Base
  def initialize(sortable: false, sorted: nil, **attributes)
    @sortable = sortable
    @sorted = sorted # :asc, :desc, or nil
    @attributes = attributes
  end

  def view_template(&block)
    th(class: css_classes((@sortable ? "cursor-pointer select-none" : nil)), **@attributes) do
      div(class: "flex items-center gap-1") do
        span(&block)

        if @sortable
          span(class: "text-xs opacity-60") do
            case @sorted
            when :asc
              "↑"
            when :desc
              "↓"
            else
              "↕"
            end
          end
        end
      end
    end
  end
end
