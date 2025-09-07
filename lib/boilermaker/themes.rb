# frozen_string_literal: true

module Boilermaker
  module Themes
    LIGHT = %w[
      light cupcake bumblebee emerald corporate retro valentine garden aqua
      lofi pastel fantasy wireframe cmyk autumn lemonade winter caramellatte silk
    ].freeze

    DARK = %w[
      dark synthwave cyberpunk halloween forest black luxury dracula business
      acid night coffee dim nord sunset abyss
    ].freeze

    BUILTINS = (LIGHT + DARK).freeze
  end
end
