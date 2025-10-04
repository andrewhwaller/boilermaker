# frozen_string_literal: true

require "test_helper"
require Rails.root.join("lib", "boilermaker")

class Boilermaker::FontConfigurationTest < ActiveSupport::TestCase
  test "font_config returns configuration hash with required keys" do
    config = Boilermaker::FontConfiguration.font_config("Inter")

    assert config.is_a?(Hash)
    assert_includes config.keys, :name
    assert_includes config.keys, :type
    assert_includes config.keys, :family_stack
  end

  test "font_config falls back to CommitMono for unknown fonts" do
    config = Boilermaker::FontConfiguration.font_config("UnknownFont")

    assert_equal "CommitMono", config[:name]
    assert_equal :local, config[:type]
  end

  test "local_font? correctly identifies local fonts" do
    assert Boilermaker::FontConfiguration.local_font?("CommitMono")
  end

  test "remote_font? correctly identifies remote fonts" do
    assert Boilermaker::FontConfiguration.remote_font?("Inter")
  end

  test "google_fonts_url returns URL for Google Fonts" do
    url = Boilermaker::FontConfiguration.google_fonts_url("Inter")

    assert_not_nil url
    assert_match /fonts\.googleapis\.com/, url
  end

  test "google_fonts_url returns nil for local fonts" do
    assert_nil Boilermaker::FontConfiguration.google_fonts_url("CommitMono")
  end

  test "google_fonts_url returns nil for non-Google remote fonts" do
    assert_nil Boilermaker::FontConfiguration.google_fonts_url("Monaspace Neon")
  end

  test "stylesheet_urls returns array" do
    urls = Boilermaker::FontConfiguration.stylesheet_urls("Inter")

    assert urls.is_a?(Array)
  end

  test "preconnect_urls returns array" do
    urls = Boilermaker::FontConfiguration.preconnect_urls("Inter")

    assert urls.is_a?(Array)
  end

  test "preload_links returns array" do
    links = Boilermaker::FontConfiguration.preload_links("Monaspace Neon")

    assert links.is_a?(Array)
  end

  test "style_blocks returns array" do
    blocks = Boilermaker::FontConfiguration.style_blocks("Monaspace Neon")

    assert blocks.is_a?(Array)
  end

  test "font_family_stack returns non-empty string" do
    stack = Boilermaker::FontConfiguration.font_family_stack("Inter")

    assert stack.is_a?(String)
    assert stack.length > 0
  end

  test "all_fonts returns array of font names" do
    fonts = Boilermaker::FontConfiguration.all_fonts

    assert fonts.is_a?(Array)
    assert fonts.length > 0
    assert_includes fonts, "CommitMono"
    assert_includes fonts, "Inter"
  end
end
