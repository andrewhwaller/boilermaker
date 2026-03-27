# frozen_string_literal: true

require "test_helper"

class Boilermaker::ThemesTest < ActiveSupport::TestCase
  test "AVAILABLE contains only the default theme" do
    assert_equal 1, Boilermaker::Themes::AVAILABLE.length
    assert_includes Boilermaker::Themes::AVAILABLE, "default"
  end

  test "DEFAULT is default" do
    assert_equal "default", Boilermaker::Themes::DEFAULT
  end

  test "POLARITIES contains light and dark" do
    assert_equal %w[light dark], Boilermaker::Themes::POLARITIES
  end

  test "valid? returns true for valid themes" do
    Boilermaker::Themes::AVAILABLE.each do |theme|
      assert Boilermaker::Themes.valid?(theme), "Expected #{theme} to be valid"
    end
  end

  test "valid? returns false for invalid themes" do
    refute Boilermaker::Themes.valid?("invalid")
    refute Boilermaker::Themes.valid?(nil)
    refute Boilermaker::Themes.valid?("")
  end

  test "valid? returns false for removed themes" do
    %w[paper terminal blueprint brutalist amber blackbox].each do |removed|
      refute Boilermaker::Themes.valid?(removed), "Expected #{removed} to no longer be valid"
    end
  end

  test "valid_polarity? returns true for light and dark" do
    assert Boilermaker::Themes.valid_polarity?("light")
    assert Boilermaker::Themes.valid_polarity?("dark")
  end

  test "valid_polarity? returns false for invalid polarities" do
    refute Boilermaker::Themes.valid_polarity?("invalid")
    refute Boilermaker::Themes.valid_polarity?(nil)
  end

  test "metadata_for returns correct metadata for default theme" do
    metadata = Boilermaker::Themes.metadata_for("default")
    assert_equal "Default", metadata[:name]
    assert_equal "Neutral gray scale, clean and professional", metadata[:description]
    assert_equal "light", metadata[:default_polarity]
    assert_equal false, metadata[:has_overlays]
    assert_empty metadata[:unique_components]
  end

  test "metadata_for returns default metadata for invalid theme" do
    metadata = Boilermaker::Themes.metadata_for("invalid")
    assert_equal "Default", metadata[:name]
  end

  test "default_polarity_for returns light for default theme" do
    assert_equal "light", Boilermaker::Themes.default_polarity_for("default")
  end

  test "default_polarity_for falls back to default for unknown theme" do
    assert_equal "light", Boilermaker::Themes.default_polarity_for("nonexistent")
  end

  test "has_overlays? returns false for default theme" do
    refute Boilermaker::Themes.has_overlays?("default")
  end

  test "unique_components_for returns empty for default theme" do
    assert_empty Boilermaker::Themes.unique_components_for("default")
  end
end
