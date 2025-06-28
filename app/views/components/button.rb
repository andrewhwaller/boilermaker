# frozen_string_literal: true

module Views
  module Components
    class Button < Views::Base
      def initialize(type: "button", variant: :primary, **attrs)
        @type = type
        @variant = variant
        @attrs = attrs
      end

      def view_template(&block)
        button(button_attributes, &block)
      end

      private

      def button_attributes
        {
          type: @type,
          class: button_classes
        }.merge(@attrs)
      end

      def button_classes
        base_classes = "px-4 py-2 rounded-lg font-medium transition-colors"
        variant_classes = case @variant.to_sym
        when :primary
                           "bg-primary hover:bg-primary/90 text-white"
        when :secondary
                           "bg-secondary hover:bg-secondary/90 text-white"
        when :outline
                           "border border-border hover:bg-muted/10"
        when :ghost
                           "hover:bg-muted/10"
        else
                           "bg-primary hover:bg-primary/90 text-white"
        end
        "#{base_classes} #{variant_classes}"
      end
    end
  end
end
