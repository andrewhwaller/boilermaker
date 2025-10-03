# frozen_string_literal: true

require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  def setup
    @original_data = Boilermaker::Config.instance_variable_get(:@data)
  end

  def teardown
    Boilermaker::Config.instance_variable_set(:@data, @original_data)
  end

  test "google_fonts_link_tag returns nil for CommitMono" do
    stub_font_config("CommitMono")

    result = google_fonts_link_tag

    assert_nil result
  end

  test "google_fonts_link_tag returns link tags for Google Fonts" do
    stub_font_config("Inter")

    result = google_fonts_link_tag

    assert_not_nil result
    assert_includes result, "fonts.googleapis.com"
    assert_includes result, "fonts.gstatic.com"
    assert_includes result, "Inter"
    assert_includes result, 'rel="preconnect"'
    assert_includes result, 'rel="stylesheet"'
  end

  test "google_fonts_link_tag returns link tags for Space Grotesk" do
    stub_font_config("Space Grotesk")

    result = google_fonts_link_tag

    assert_not_nil result
    assert_includes result, "fonts.googleapis.com"
    assert_includes result, "Space+Grotesk"
  end

  test "app_font_family returns correct stack for CommitMono" do
    stub_font_config("CommitMono")

    result = app_font_family

    assert_equal '"CommitMonoIndustrial", monospace', result
  end

  test "app_font_family returns correct stack for Inter" do
    stub_font_config("Inter")

    result = app_font_family

    assert_includes result, "Inter"
    assert_includes result, "sans-serif"
  end

  test "app_font_family returns correct stack for JetBrains Mono" do
    stub_font_config("JetBrains Mono")

    result = app_font_family

    assert_includes result, "JetBrains Mono"
    assert_includes result, "monospace"
  end

  private

  def stub_font_config(font_name)
    config = {
      "ui" => {
        "typography" => {
          "font" => font_name
        }
      }
    }
    Boilermaker::Config.instance_variable_set(:@data, config)
  end
end
