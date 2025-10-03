# frozen_string_literal: true

module Boilermaker
  module FontConfiguration
    # Curated list of fonts with their configuration
    FONTS = {
      "CommitMono" => {
        name: "CommitMono",
        display_name: "Commit Mono",
        type: :local,
        family_stack: '"CommitMonoIndustrial", monospace'
      },
      "Inter" => {
        name: "Inter",
        display_name: "Inter",
        type: :google,
        family_stack: '"Inter", -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif',
        google_url: "https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
      },
      "Space Grotesk" => {
        name: "Space Grotesk",
        display_name: "Space Grotesk",
        type: :google,
        family_stack: '"Space Grotesk", -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif',
        google_url: "https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;600;700&display=swap"
      },
      "JetBrains Mono" => {
        name: "JetBrains Mono",
        display_name: "JetBrains Mono",
        type: :google,
        family_stack: '"JetBrains Mono", "Courier New", monospace',
        google_url: "https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;600;700&display=swap"
      },
      "IBM Plex Sans" => {
        name: "IBM Plex Sans",
        display_name: "IBM Plex Sans",
        type: :google,
        family_stack: '"IBM Plex Sans", -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif',
        google_url: "https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@400;500;600;700&display=swap"
      },
      "Roboto Mono" => {
        name: "Roboto Mono",
        display_name: "Roboto Mono",
        type: :google,
        family_stack: '"Roboto Mono", "Courier New", monospace',
        google_url: "https://fonts.googleapis.com/css2?family=Roboto+Mono:wght@400;500;600;700&display=swap"
      },
      "EB Garamond" => {
        name: "EB Garamond",
        display_name: "EB Garamond",
        type: :google,
        family_stack: '"EB Garamond", "Georgia", serif',
        google_url: "https://fonts.googleapis.com/css2?family=EB+Garamond:wght@400;500;600;700&display=swap"
      },
      "Libre Franklin" => {
        name: "Libre Franklin",
        display_name: "Libre Franklin",
        type: :google,
        family_stack: '"Libre Franklin", -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif',
        google_url: "https://fonts.googleapis.com/css2?family=Libre+Franklin:wght@400;500;600;700&display=swap"
      }
    }.freeze

    class << self
      # Get font configuration for a given font name
      def font_config(font_name)
        FONTS[font_name] || FONTS["CommitMono"]
      end

      # Get Google Fonts URL for a font (returns nil for local fonts)
      def google_fonts_url(font_name)
        config = font_config(font_name)
        config[:type] == :google ? config[:google_url] : nil
      end

      # Get CSS font-family stack for a font
      def font_family_stack(font_name)
        font_config(font_name)[:family_stack]
      end

      # Check if a font is a Google Font
      def google_font?(font_name)
        font_config(font_name)[:type] == :google
      end

      # Check if a font is a local font
      def local_font?(font_name)
        font_config(font_name)[:type] == :local
      end

      # List all available fonts
      def all_fonts
        FONTS.keys
      end
    end
  end
end
