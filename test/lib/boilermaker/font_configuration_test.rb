# frozen_string_literal: true

require "test_helper"
require Rails.root.join("lib", "boilermaker")

class Boilermaker::FontConfigurationTest < ActiveSupport::TestCase
  setup do
    fonts = Boilermaker::FontConfiguration.all_fonts
    @local_font = fonts.find { |font| Boilermaker::FontConfiguration.local_font?(font) }
    @remote_font = fonts.find { |font| Boilermaker::FontConfiguration.remote_font?(font) }
    @google_font = fonts.find { |font| Boilermaker::FontConfiguration.google_font?(font) }
    @remote_non_google_font = fonts.find do |font|
      Boilermaker::FontConfiguration.remote_font?(font) &&
        !Boilermaker::FontConfiguration.google_font?(font)
    end
    @font_with_preload = fonts.find do |font|
      Boilermaker::FontConfiguration.preload_links(font).any?
    end
  end

  test "font_config returns configuration hash with required keys" do
    skip unless @remote_font
    config = Boilermaker::FontConfiguration.font_config(@remote_font)

    assert config.is_a?(Hash)
    assert_includes config.keys, :name
    assert_includes config.keys, :type
    assert_includes config.keys, :family_stack
  end

  test "font_config falls back to local default for unknown fonts" do
    config = Boilermaker::FontConfiguration.font_config("UnknownFont")

    assert Boilermaker::FontConfiguration.local_font?(config[:name])
  end

  test "local_font? correctly identifies local fonts" do
    skip unless @local_font
    assert Boilermaker::FontConfiguration.local_font?(@local_font)
  end

  test "remote_font? correctly identifies remote fonts" do
    skip unless @remote_font
    assert Boilermaker::FontConfiguration.remote_font?(@remote_font)
  end

  test "google_fonts_url returns URL for Google Fonts" do
    skip unless @google_font
    url = Boilermaker::FontConfiguration.google_fonts_url(@google_font)

    assert_not_nil url
    assert_match /fonts\.googleapis\.com/, url
  end

  test "google_fonts_url returns nil for local fonts" do
    skip unless @local_font
    assert_nil Boilermaker::FontConfiguration.google_fonts_url(@local_font)
  end

  test "google_fonts_url returns nil for non-Google remote fonts" do
    skip unless @remote_non_google_font
    assert_nil Boilermaker::FontConfiguration.google_fonts_url(@remote_non_google_font)
  end

  test "stylesheet_urls returns array" do
    skip unless @remote_font
    urls = Boilermaker::FontConfiguration.stylesheet_urls(@remote_font)

    assert urls.is_a?(Array)
  end

  test "preconnect_urls returns array" do
    skip unless @remote_font
    urls = Boilermaker::FontConfiguration.preconnect_urls(@remote_font)

    assert urls.is_a?(Array)
  end

  test "preload_links returns array" do
    skip unless @font_with_preload
    links = Boilermaker::FontConfiguration.preload_links(@font_with_preload)

    assert links.is_a?(Array)
  end

  test "style_blocks returns array" do
    skip unless @remote_non_google_font
    blocks = Boilermaker::FontConfiguration.style_blocks(@remote_non_google_font)

    assert blocks.is_a?(Array)
  end

  test "font_family_stack returns non-empty string" do
    skip unless @remote_font
    stack = Boilermaker::FontConfiguration.font_family_stack(@remote_font)

    assert stack.is_a?(String)
    assert stack.length > 0
  end

  test "all_fonts returns array of font names" do
    fonts = Boilermaker::FontConfiguration.all_fonts

    assert fonts.is_a?(Array)
    assert fonts.length > 0
    assert_includes fonts, @remote_font if @remote_font
  end
end
