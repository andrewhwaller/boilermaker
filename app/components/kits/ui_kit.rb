# frozen_string_literal: true

module Components
  module Kits
    module UIKit
      module_function

      def kits
        {
          form: Components::Kits::FormKit,
          navigation: Components::Kits::NavigationKit
        }
      end

      def components
        {
          form: Components::Kits::FormKit.components,
          navigation: Components::Kits::NavigationKit.components,
          base: { base: Components::Base }
        }
      end

      def form
        Components::Kits::FormKit
      end

      def navigation
        Components::Kits::NavigationKit
      end

      def list_components
        list = []
        components.each do |category, comps|
          comps.each_key { |name| list << "#{category}.#{name}" }
        end
        list
      end
    end
  end
end

