# frozen_string_literal: true

module Boilermaker
  module Themes
    AVAILABLE = %w[default].freeze
    DEFAULT = "default"
    DEFAULT_POLARITY = "light"
    POLARITIES = %w[light dark].freeze

    # Metadata for each theme
    METADATA = {
      "default" => {
        name: "Default",
        description: "Neutral gray scale, clean and professional",
        default_polarity: "light",
        has_overlays: false,
        unique_components: []
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
    end
  end
end
