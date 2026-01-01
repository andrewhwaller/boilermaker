# frozen_string_literal: true

module Views
  module Boilermaker
    module Layouts
      # Paper-themed dashboard layout
      # Clean, minimal design similar to a printed document
      class PaperDashboard < DashboardBase
        def theme_name = "paper"
        def polarity = "light"

        def header_content
          header(class: "max-w-4xl mx-auto px-6 pt-6 mb-8 border-b border-border-light pb-4") {
            h1(class: "text-xl font-serif") { @title }
          }
        end

        def footer_content
          footer(class: "max-w-4xl mx-auto px-6 py-8 mt-8 border-t border-border-light text-xs text-muted") {
            plain "© #{Time.current.year}"
          }
        end
      end
    end
  end
end
