# frozen_string_literal: true

module Components
  module Kits
    module FormKit
      module_function

      def components
        {
          button: Components::Button,
          input: Components::Input,
          label: Components::Label,
          form_field: Components::FormField
        }
      end

      def field(**kwargs)
        Components::FormField.new(**kwargs)
      end

      def submit_button(text = "Submit", variant: :primary, **attrs)
        Components::Button.new(type: :submit, variant: variant, **attrs) { text }
      end
    end
  end
end

