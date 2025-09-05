# frozen_string_literal: true

module Components
  module Kits
    module NavigationKit
      module_function

      def components
        {
          navigation: Components::Navigation,
          dropdown_menu: Components::DropdownMenu
        }
      end
    end
  end
end
