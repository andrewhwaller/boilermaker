# frozen_string_literal: true

module Views
  module Boilermaker
    module Demos
      # Base class for demo pages
      # Uses composition - demos RENDER layouts rather than INHERIT from them
      # This decouples demos from layouts and makes the relationship explicit
      class Base < Phlex::HTML
        include Phlex::Rails::Helpers::Routes
        include SampleData
      end
    end
  end
end
