# frozen_string_literal: true

module Components
  module Boilermaker
    class Base < ::Components::Base
      # Boilermaker theme components inherit from the main Components::Base
      # This provides access to all helpers while namespacing theme-specific components
    end
  end
end
