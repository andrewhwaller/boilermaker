# frozen_string_literal: true

module Views
  module Admin
    module Dashboards
      class Show < Views::Base
        include Phlex::Rails::Helpers::LinkTo

        def view_template
          page_with_title("Admin") do
            div(class: "flex items-center justify-between mb-4") do
              h1(class: "text-xl font-bold text-base-content") { "Application Admin" }
            end

            div(class: "bg-base-200 rounded-box p-4") do
              p(class: "text-base-content/80") do
                plain "This is the application-level admin area."
              end
            end
          end
        end
      end
    end
  end
end
