# frozen_string_literal: true

require "test_helper"
require Rails.root.join("lib", "boilermaker")

class Boilermaker::FontConfigurationTest < ActiveSupport::TestCase
  test "font_config returns correct configuration for CommitMono" do
    config = Boilermaker::FontConfiguration.font_config("CommitMono")

    assert_equal "CommitMono", config[:name]
    assert_equal "Commit Mono", config[:display_name]
    assert_equal :local, config[:type]
    assert_equal '"CommitMonoIndustrial", monospace', config[:family_stack]
    assert_nil config[:google_url]
  end

  test "font_config returns correct configuration for Inter" do
    config = Boilermaker::FontConfiguration.font_config("Inter")

    assert_equal "Inter", config[:name]
    assert_equal "Inter", config[:display_name]
    assert_equal :google, config[:type]
    assert_equal '"Inter", -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif', config[:family_stack]
    assert_match /fonts\.googleapis\.com/, config[:google_url]
  end

  test "font_config returns correct configuration for Space Grotesk" do
    config = Boilermaker::FontConfiguration.font_config("Space Grotesk")

    assert_equal "Space Grotesk", config[:name]
    assert_equal :google, config[:type]
    assert_match /fonts\.googleapis\.com/, config[:google_url]
  end

  test "font_config returns correct configuration for JetBrains Mono" do
    config = Boilermaker::FontConfiguration.font_config("JetBrains Mono")

    assert_equal "JetBrains Mono", config[:name]
    assert_equal :google, config[:type]
    assert_match /fonts\.googleapis\.com/, config[:google_url]
  end

  test "font_config returns correct configuration for IBM Plex Sans" do
    config = Boilermaker::FontConfiguration.font_config("IBM Plex Sans")

    assert_equal "IBM Plex Sans", config[:name]
    assert_equal :google, config[:type]
    assert_match /fonts\.googleapis\.com/, config[:google_url]
  end

  test "font_config returns correct configuration for Roboto Mono" do
    config = Boilermaker::FontConfiguration.font_config("Roboto Mono")

    assert_equal "Roboto Mono", config[:name]
    assert_equal :google, config[:type]
    assert_match /fonts\.googleapis\.com/, config[:google_url]
  end

  test "font_config returns CommitMono config for unknown font" do
    config = Boilermaker::FontConfiguration.font_config("UnknownFont")

    assert_equal "CommitMono", config[:name]
    assert_equal :local, config[:type]
  end

  test "google_fonts_url returns nil for local fonts" do
    assert_nil Boilermaker::FontConfiguration.google_fonts_url("CommitMono")
  end

  test "google_fonts_url returns URL for Google Fonts" do
    url = Boilermaker::FontConfiguration.google_fonts_url("Inter")

    assert_not_nil url
    assert_match /fonts\.googleapis\.com/, url
    assert_match /Inter/, url
  end

  test "font_family_stack returns correct stack for CommitMono" do
    stack = Boilermaker::FontConfiguration.font_family_stack("CommitMono")

    assert_equal '"CommitMonoIndustrial", monospace', stack
  end

  test "font_family_stack returns correct stack for Inter" do
    stack = Boilermaker::FontConfiguration.font_family_stack("Inter")

    assert_match /Inter/, stack
    assert_match /sans-serif/, stack
  end

  test "google_font? returns false for local fonts" do
    assert_not Boilermaker::FontConfiguration.google_font?("CommitMono")
  end

  test "google_font? returns true for Google Fonts" do
    assert Boilermaker::FontConfiguration.google_font?("Inter")
    assert Boilermaker::FontConfiguration.google_font?("Space Grotesk")
    assert Boilermaker::FontConfiguration.google_font?("JetBrains Mono")
  end

  test "local_font? returns true for local fonts" do
    assert Boilermaker::FontConfiguration.local_font?("CommitMono")
  end

  test "local_font? returns false for Google Fonts" do
    assert_not Boilermaker::FontConfiguration.local_font?("Inter")
    assert_not Boilermaker::FontConfiguration.local_font?("Space Grotesk")
  end

  test "all_fonts returns list of all available fonts" do
    fonts = Boilermaker::FontConfiguration.all_fonts

    assert_includes fonts, "CommitMono"
    assert_includes fonts, "Inter"
    assert_includes fonts, "Space Grotesk"
    assert_includes fonts, "JetBrains Mono"
    assert_includes fonts, "IBM Plex Sans"
    assert_includes fonts, "Roboto Mono"
    assert_equal 6, fonts.length
  end
end
