# frozen_string_literal: true

require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  def setup
    @original_data = Boilermaker::Config.instance_variable_get(:@data)
  end

  def teardown
    Boilermaker::Config.instance_variable_set(:@data, @original_data)
  end

  test "font_stylesheet_link_tag returns nil for CommitMono" do
    stub_font_config("CommitMono")

    result = font_stylesheet_link_tag

    assert_nil result
  end

  test "font_stylesheet_link_tag returns link tags for Google Fonts" do
    stub_font_config("Inter")

    result = font_stylesheet_link_tag

    assert_not_nil result
    assert_includes result, "fonts.googleapis.com"
    assert_includes result, "fonts.gstatic.com"
    assert_includes result, "Inter"
    assert_includes result, 'rel="preconnect"'
    assert_includes result, 'rel="stylesheet"'
    assert_includes result, 'crossorigin="anonymous"'
  end

  test "font_stylesheet_link_tag returns link tags for Monaspace" do
    stub_font_config("Monaspace Neon")

    result = font_stylesheet_link_tag

    assert_not_nil result
    assert_includes result, "cdn.jsdelivr.net"
    assert_includes result, "@font-face"
    assert_includes result, "<style>"
    assert_includes result, 'rel="preload"'
    assert_not_includes result, "/fonts/monaspace-neon.css"
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

  test "app_font_family returns correct stack for Monaspace" do
    stub_font_config("Monaspace Neon")

    result = app_font_family

    assert_includes result, "Monaspace Neon"
    assert_includes result, "monospace"
  end

  test "app_text_transform defaults to uppercase" do
    Boilermaker::Config.instance_variable_set(:@data, {})

    assert_equal "uppercase", app_text_transform
  end

  test "app_text_transform reflects config toggle" do
    Boilermaker::Config.instance_variable_set(:@data, {
      "ui" => {
        "typography" => { "uppercase" => false }
      }
    })

    assert_equal "none", app_text_transform
  end

  test "app_base_font_size defaults to multiplier 1" do
    Boilermaker::Config.instance_variable_set(:@data, {})

    assert_in_delta 1.0, app_base_font_size
  end

  test "app_base_font_size reflects configured scale" do
    Boilermaker::Config.instance_variable_set(:@data, {
      "ui" => {
        "typography" => { "size" => "expanded" }
      }
    })

    assert_in_delta 1.12, app_base_font_size
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
