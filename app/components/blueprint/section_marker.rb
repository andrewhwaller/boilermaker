# frozen_string_literal: true

module Components
  module Blueprint
    class SectionMarker < Components::Base
      def initialize(number:, title: nil, id: nil)
        @number = number
        @title = title
        @id = id || "section-#{number}"
      end

      def view_template
        div(
          id: @id,
          class: "flex items-center gap-3 mb-4 scroll-mt-4",
          data: {
            controller: "section-marker",
            section_marker_target: "marker"
          }
        ) do
          section_number
          section_title if @title
          section_line
        end
      end

      private

      def section_number
        formatted = Kernel.format("%02d", @number)
        a(
          href: "##{@id}",
          class: number_classes,
          title: "Section #{@number}",
          data: { action: "click->section-marker#scrollTo" }
        ) do
          span(class: "text-xs font-mono") { formatted }
        end
      end

      def number_classes
        "flex items-center justify-center w-8 h-8 " \
          "border-2 border-accent rounded-full " \
          "text-accent font-mono font-bold " \
          "hover:bg-accent hover:text-inverse transition-colors " \
          "cursor-pointer select-none"
      end

      def section_title
        h3(class: "text-sm font-semibold text-body uppercase tracking-wider") { @title }
      end

      def section_line
        div(class: "flex-1 h-px bg-border-light")
      end
    end
  end
end
