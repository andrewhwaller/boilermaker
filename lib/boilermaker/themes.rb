# frozen_string_literal: true

module Boilermaker
  module Themes
    AVAILABLE = %w[paper terminal blueprint brutalist dos].freeze
    DEFAULT = "paper"
    DEFAULT_POLARITY = "light"
    POLARITIES = %w[light dark].freeze

    # Layout class mapping (theme name -> layout class name)
    LAYOUT_CLASSES = {
      "paper" => "Views::Layouts::PaperDashboard",
      "terminal" => "Views::Layouts::TerminalDashboard",
      "blueprint" => "Views::Layouts::BlueprintDashboard",
      "brutalist" => "Views::Layouts::BrutalistDashboard",
      "dos" => "Views::Layouts::DosDashboard"
    }.freeze

    # Metadata for each theme
    METADATA = {
      "paper" => {
        name: "Paper",
        description: "Warm, minimal, refined industrial",
        default_polarity: "light",
        has_overlays: false,
        unique_components: [],
        layout_class: "Views::Layouts::PaperDashboard"
      },
      "terminal" => {
        name: "Terminal",
        description: "Green phosphor CRT aesthetic",
        default_polarity: "dark",
        has_overlays: true,
        unique_components: %w[command_bar],
        layout_class: "Views::Layouts::TerminalDashboard"
      },
      "blueprint" => {
        name: "Blueprint",
        description: "Engineering document / technical drawing",
        default_polarity: "light",
        has_overlays: true,
        unique_components: %w[section_marker],
        layout_class: "Views::Layouts::BlueprintDashboard"
      },
      "brutalist" => {
        name: "Brutalist",
        description: "Raw, minimal, maximum content",
        default_polarity: "light",
        has_overlays: false,
        unique_components: %w[keyboard_hint],
        layout_class: "Views::Layouts::BrutalistDashboard"
      },
      "dos" => {
        name: "DOS",
        description: "Amber monochrome, chunky, nostalgic",
        default_polarity: "dark",
        has_overlays: true,
        unique_components: %w[fn_bar],
        layout_class: "Views::Layouts::DosDashboard"
      }
    }.freeze

    class << self
      def valid?(theme_name)
        AVAILABLE.include?(theme_name.to_s)
      end

      def valid_polarity?(polarity)
        POLARITIES.include?(polarity.to_s)
      end

      def metadata_for(theme_name)
        METADATA[theme_name.to_s] || METADATA[DEFAULT]
      end

      def default_polarity_for(theme_name)
        metadata_for(theme_name)[:default_polarity]
      end

      def has_overlays?(theme_name)
        metadata_for(theme_name)[:has_overlays]
      end

      def unique_components_for(theme_name)
        metadata_for(theme_name)[:unique_components]
      end

      def layout_class_for(theme_name)
        class_name = LAYOUT_CLASSES[theme_name.to_s] || LAYOUT_CLASSES[DEFAULT]
        class_name.constantize
      end
    end
  end
end
