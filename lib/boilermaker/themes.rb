# frozen_string_literal: true

module Boilermaker
  module Themes
    # Custom themes built specifically for this application
    CUSTOM_LIGHT = %w[work-station drafting-table].freeze
    CUSTOM_DARK = %w[command-center terminal].freeze

    # Built-in DaisyUI themes
    LIGHT = %w[
      light cupcake bumblebee emerald corporate retro valentine garden aqua
      lofi pastel fantasy wireframe cmyk autumn lemonade winter caramellatte silk
    ].freeze

    DARK = %w[
      dark synthwave cyberpunk halloween forest black luxury dracula business
      acid night coffee dim nord sunset abyss
    ].freeze

    BUILTINS = (LIGHT + DARK).freeze
    ALL_LIGHT = (CUSTOM_LIGHT + LIGHT).freeze
    ALL_DARK = (CUSTOM_DARK + DARK).freeze
    ALL = (CUSTOM_LIGHT + CUSTOM_DARK + BUILTINS).freeze
  end
end
