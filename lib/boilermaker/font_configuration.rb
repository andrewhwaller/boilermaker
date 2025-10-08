# frozen_string_literal: true

module Boilermaker
  module FontConfiguration
    GOOGLE_PRECONNECT_LINKS = [
      { href: "https://fonts.googleapis.com" },
      { href: "https://fonts.gstatic.com", crossorigin: "anonymous" }
    ].freeze

    JSDELIVR_PRECONNECT_LINKS = [
      { href: "https://cdn.jsdelivr.net", crossorigin: "anonymous" }
    ].freeze

    MONASPACE_CDN_BASE = "https://cdn.jsdelivr.net/gh/githubnext/monaspace@v1.000/fonts/webfonts"
    MONASPACE_WEIGHTS = {
      400 => "Regular",
      500 => "Medium",
      700 => "Bold"
    }.freeze

    def self.build_monaspace_style_block(family, slug)
      MONASPACE_WEIGHTS.map do |weight, suffix|
        <<~CSS
          @font-face {
            font-family: '#{family}';
            font-style: normal;
            font-weight: #{weight};
            font-display: swap;
            src: url('#{MONASPACE_CDN_BASE}/#{slug}-#{suffix}.woff') format('woff');
          }
        CSS
      end.join("\n")
    end

    def self.build_monaspace_preload_links(slug)
      MONASPACE_WEIGHTS.values.map do |suffix|
        {
          href: "#{MONASPACE_CDN_BASE}/#{slug}-#{suffix}.woff",
          as: "font",
          type: "font/woff",
          crossorigin: "anonymous"
        }
      end
    end

    MONASPACE_STYLE_BLOCKS = {
      "Monaspace Argon" => build_monaspace_style_block("Monaspace Argon", "MonaspaceArgon"),
      "Monaspace Neon" => build_monaspace_style_block("Monaspace Neon", "MonaspaceNeon"),
      "Monaspace Xenon" => build_monaspace_style_block("Monaspace Xenon", "MonaspaceXenon"),
      "Monaspace Krypton" => build_monaspace_style_block("Monaspace Krypton", "MonaspaceKrypton"),
      "Monaspace Radon" => build_monaspace_style_block("Monaspace Radon", "MonaspaceRadon")
    }.freeze

    MONASPACE_PRELOAD_LINKS = {
      "Monaspace Argon" => build_monaspace_preload_links("MonaspaceArgon"),
      "Monaspace Neon" => build_monaspace_preload_links("MonaspaceNeon"),
      "Monaspace Xenon" => build_monaspace_preload_links("MonaspaceXenon"),
      "Monaspace Krypton" => build_monaspace_preload_links("MonaspaceKrypton"),
      "Monaspace Radon" => build_monaspace_preload_links("MonaspaceRadon")
    }.freeze

    private_class_method :build_monaspace_style_block, :build_monaspace_preload_links

    FONTS = {
      "CommitMono" => {
        name: "CommitMono",
        display_name: "Commit Mono",
        type: :local,
        family_stack: '"CommitMonoIndustrial", monospace'
      },
      "Geist" => {
        name: "Geist",
        display_name: "Geist",
        type: :remote,
        family_stack: '"Geist", -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif',
        stylesheet_urls: [
          "https://fonts.googleapis.com/css2?family=Geist:wght@400;500;600;700&display=swap"
        ],
        preconnect_urls: GOOGLE_PRECONNECT_LINKS
      },
      "Geist Mono" => {
        name: "Geist Mono",
        display_name: "Geist Mono",
        type: :remote,
        family_stack: '"Geist Mono", "SF Mono", "Monaco", "Inconsolata", "Roboto Mono", "Source Code Pro", "Courier New", monospace',
        stylesheet_urls: [
          "https://fonts.googleapis.com/css2?family=Geist+Mono:wght@400;500;600;700&display=swap"
        ],
        preconnect_urls: GOOGLE_PRECONNECT_LINKS
      },
      "Martian Mono" => {
        name: "Martian Mono",
        display_name: "Martian Mono",
        type: :remote,
        family_stack: '"Martian Mono", "SF Mono", "Monaco", "Inconsolata", "Roboto Mono", "Source Code Pro", "Courier New", monospace',
        stylesheet_urls: [
          "https://fonts.googleapis.com/css2?family=Martian+Mono:wght@400;500;600;700&display=swap"
        ],
        preconnect_urls: GOOGLE_PRECONNECT_LINKS
      },
      "JetBrains Mono" => {
        name: "JetBrains Mono",
        display_name: "JetBrains Mono",
        type: :remote,
        family_stack: '"JetBrains Mono", "SF Mono", "Monaco", "Inconsolata", "Roboto Mono", "Source Code Pro", "Courier New", monospace',
        stylesheet_urls: [
          "https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;600;700&display=swap"
        ],
        preconnect_urls: GOOGLE_PRECONNECT_LINKS
      },
      "Public Sans" => {
        name: "Public Sans",
        display_name: "Public Sans",
        type: :remote,
        family_stack: '"Public Sans", -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif',
        stylesheet_urls: [
          "https://fonts.googleapis.com/css2?family=Public+Sans:wght@400;500;600;700&display=swap"
        ],
        preconnect_urls: GOOGLE_PRECONNECT_LINKS
      },
      "IBM Plex Sans" => {
        name: "IBM Plex Sans",
        display_name: "IBM Plex Sans",
        type: :remote,
        family_stack: '"IBM Plex Sans", -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif',
        stylesheet_urls: [
          "https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@400;500;600;700&display=swap"
        ],
        preconnect_urls: GOOGLE_PRECONNECT_LINKS
      },
      "IBM Plex Mono" => {
        name: "IBM Plex Mono",
        display_name: "IBM Plex Mono",
        type: :remote,
        family_stack: '"IBM Plex Mono", "SF Mono", "Monaco", "Inconsolata", "Roboto Mono", "Source Code Pro", "Courier New", monospace',
        stylesheet_urls: [
          "https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500;600;700&display=swap"
        ],
        preconnect_urls: GOOGLE_PRECONNECT_LINKS
      },
      "Roboto Mono" => {
        name: "Roboto Mono",
        display_name: "Roboto Mono",
        type: :remote,
        family_stack: '"Roboto Mono", "SF Mono", "Monaco", "Inconsolata", "JetBrains Mono", "Source Code Pro", "Courier New", monospace',
        stylesheet_urls: [
          "https://fonts.googleapis.com/css2?family=Roboto+Mono:wght@400;500;600;700&display=swap"
        ],
        preconnect_urls: GOOGLE_PRECONNECT_LINKS
      },
      "EB Garamond" => {
        name: "EB Garamond",
        display_name: "EB Garamond",
        type: :remote,
        family_stack: '"EB Garamond", "Georgia", serif',
        stylesheet_urls: [
          "https://fonts.googleapis.com/css2?family=EB+Garamond:wght@400;500;600;700&display=swap"
        ],
        preconnect_urls: GOOGLE_PRECONNECT_LINKS
      },
      "Libre Franklin" => {
        name: "Libre Franklin",
        display_name: "Libre Franklin",
        type: :remote,
        family_stack: '"Libre Franklin", -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif',
        stylesheet_urls: [
          "https://fonts.googleapis.com/css2?family=Libre+Franklin:wght@400;500;600;700&display=swap"
        ],
        preconnect_urls: GOOGLE_PRECONNECT_LINKS
      },
      "Jura" => {
        name: "Jura",
        display_name: "Jura",
        type: :remote,
        family_stack: '"Jura", -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif',
        stylesheet_urls: [
          "https://fonts.googleapis.com/css2?family=Jura:wght@400;500;600;700&display=swap"
        ],
        preconnect_urls: GOOGLE_PRECONNECT_LINKS
      },
      "DM Serif Text" => {
        name: "DM Serif Text",
        display_name: "DM Serif Text",
        type: :remote,
        family_stack: '"DM Serif Text", "Georgia", serif',
        stylesheet_urls: [
          "https://fonts.googleapis.com/css2?family=DM+Serif+Text:wght@400;500;600;700&display=swap"
        ],
        preconnect_urls: GOOGLE_PRECONNECT_LINKS
      },
      "Recursive" => {
        name: "Recursive",
        display_name: "Recursive",
        type: :remote,
        family_stack: '"Recursive", -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif',
        stylesheet_urls: [
          "https://fonts.googleapis.com/css2?family=Recursive:wght@400;500;600;700&display=swap"
        ],
        preconnect_urls: GOOGLE_PRECONNECT_LINKS
      },
      "Instrument Serif" => {
        name: "Instrument Serif",
        display_name: "Instrument Serif",
        type: :remote,
        family_stack: '"Instrument Serif", "Georgia", serif',
        stylesheet_urls: [
          "https://fonts.googleapis.com/css2?family=Instrument+Serif:wght@400;500;600;700&display=swap"
        ],
        preconnect_urls: GOOGLE_PRECONNECT_LINKS
      },
      "Monaspace Argon" => {
        name: "Monaspace Argon",
        display_name: "Monaspace Argon",
        type: :remote,
        family_stack: '"Monaspace Argon", "CommitMonoIndustrial", monospace',
        preconnect_urls: JSDELIVR_PRECONNECT_LINKS,
        preload_links: MONASPACE_PRELOAD_LINKS["Monaspace Argon"],
        style_blocks: [ MONASPACE_STYLE_BLOCKS["Monaspace Argon"] ]
      },
      "Monaspace Neon" => {
        name: "Monaspace Neon",
        display_name: "Monaspace Neon",
        type: :remote,
        family_stack: '"Monaspace Neon", "CommitMonoIndustrial", monospace',
        preconnect_urls: JSDELIVR_PRECONNECT_LINKS,
        preload_links: MONASPACE_PRELOAD_LINKS["Monaspace Neon"],
        style_blocks: [ MONASPACE_STYLE_BLOCKS["Monaspace Neon"] ]
      },
      "Monaspace Xenon" => {
        name: "Monaspace Xenon",
        display_name: "Monaspace Xenon",
        type: :remote,
        family_stack: '"Monaspace Xenon", "CommitMonoIndustrial", monospace',
        preconnect_urls: JSDELIVR_PRECONNECT_LINKS,
        preload_links: MONASPACE_PRELOAD_LINKS["Monaspace Xenon"],
        style_blocks: [ MONASPACE_STYLE_BLOCKS["Monaspace Xenon"] ]
      },
      "Monaspace Krypton" => {
        name: "Monaspace Krypton",
        display_name: "Monaspace Krypton",
        type: :remote,
        family_stack: '"Monaspace Krypton", "CommitMonoIndustrial", monospace',
        preconnect_urls: JSDELIVR_PRECONNECT_LINKS,
        preload_links: MONASPACE_PRELOAD_LINKS["Monaspace Krypton"],
        style_blocks: [ MONASPACE_STYLE_BLOCKS["Monaspace Krypton"] ]
      },
      "Monaspace Radon" => {
        name: "Monaspace Radon",
        display_name: "Monaspace Radon",
        type: :remote,
        family_stack: '"Monaspace Radon", "CommitMonoIndustrial", monospace',
        preconnect_urls: JSDELIVR_PRECONNECT_LINKS,
        preload_links: MONASPACE_PRELOAD_LINKS["Monaspace Radon"],
        style_blocks: [ MONASPACE_STYLE_BLOCKS["Monaspace Radon"] ]
      }
    }.freeze

    class << self
      def font_config(font_name)
        FONTS[font_name] || FONTS["CommitMono"]
      end

      def font_family_stack(font_name)
        font_config(font_name)[:family_stack]
      end

      def stylesheet_urls(font_name)
        Array(font_config(font_name)[:stylesheet_urls]).compact
      end

      def preconnect_urls(font_name)
        Array(font_config(font_name)[:preconnect_urls]).compact
      end

      def style_blocks(font_name)
        Array(font_config(font_name)[:style_blocks]).compact
      end

      def preload_links(font_name)
        Array(font_config(font_name)[:preload_links]).compact
      end

      def google_fonts_url(font_name)
        config = font_config(font_name)
        return nil if config[:type] == :local

        stylesheet_urls(font_name).find { |url| url.include?("fonts.googleapis.com") }
      end

      def google_font?(font_name)
        google_fonts_url(font_name).present?
      end

      def remote_font?(font_name)
        font_config(font_name)[:type] != :local
      end

      def local_font?(font_name)
        font_config(font_name)[:type] == :local
      end

      def all_fonts
        FONTS.keys
      end

      def select_options
        FONTS.map do |_, config|
          label = config[:display_name] || config[:name]
          label += " (local)" if config[:type] == :local
          [ label, config[:name] ]
        end
      end
    end
  end
end
