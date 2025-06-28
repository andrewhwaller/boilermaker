# frozen_string_literal: true

module Views
  module Components
    class Label < Views::Base
      def initialize(for_input:, required: false, **attrs)
        @for = for_input
        @required = required
        @attrs = attrs
      end

      def view_template(&block)
        label(label_attributes) do
          yield
          if @required
            span(class: "text-error ml-1") { "*" }
          end
        end
      end

      private

      def label_attributes
        {
          for: @for,
          class: label_classes
        }.merge(@attrs)
      end

      def label_classes
        "block mb-1 font-medium"
      end
    end
  end
end
