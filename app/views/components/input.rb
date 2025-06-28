# frozen_string_literal: true

module Views
  module Components
    class Input < Views::Base
      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template
        input(input_attributes)
      end

      private

      def input_attributes
        {
          class: input_classes
        }.merge(@attrs)
      end

      def input_classes
        "w-full p-2 border border-border rounded-lg bg-input text-foreground focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-colors"
      end
    end
  end
end
