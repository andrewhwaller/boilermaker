# frozen_string_literal: true

require "test_helper"

class Boilermaker::ThemesTest < ActiveSupport::TestCase
  test "AVAILABLE contains all 5 themes" do
    assert_equal 5, Boilermaker::Themes::AVAILABLE.length
    assert_includes Boilermaker::Themes::AVAILABLE, "paper"
    assert_includes Boilermaker::Themes::AVAILABLE, "terminal"
    assert_includes Boilermaker::Themes::AVAILABLE, "blueprint"
    assert_includes Boilermaker::Themes::AVAILABLE, "brutalist"
    assert_includes Boilermaker::Themes::AVAILABLE, "amber"
  end

  test "DEFAULT is paper" do
    assert_equal "paper", Boilermaker::Themes::DEFAULT
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

  test "valid_polarity? returns true for light and dark" do
    assert Boilermaker::Themes.valid_polarity?("light")
    assert Boilermaker::Themes.valid_polarity?("dark")
  end

  test "valid_polarity? returns false for invalid polarities" do
    refute Boilermaker::Themes.valid_polarity?("invalid")
    refute Boilermaker::Themes.valid_polarity?(nil)
  end

  test "metadata_for returns correct metadata for each theme" do
    metadata = Boilermaker::Themes.metadata_for("paper")
    assert_equal "Paper", metadata[:name]
    assert_equal "light", metadata[:default_polarity]
    assert_equal false, metadata[:has_overlays]

    metadata = Boilermaker::Themes.metadata_for("terminal")
    assert_equal "Terminal", metadata[:name]
    assert_equal "dark", metadata[:default_polarity]
    assert_equal true, metadata[:has_overlays]
    assert_includes metadata[:unique_components], "command_bar"
  end

  test "metadata_for returns default metadata for invalid theme" do
    metadata = Boilermaker::Themes.metadata_for("invalid")
    assert_equal "Paper", metadata[:name]
  end

  test "default_polarity_for returns correct polarity" do
    assert_equal "light", Boilermaker::Themes.default_polarity_for("paper")
    assert_equal "dark", Boilermaker::Themes.default_polarity_for("terminal")
    assert_equal "light", Boilermaker::Themes.default_polarity_for("blueprint")
    assert_equal "light", Boilermaker::Themes.default_polarity_for("brutalist")
    assert_equal "dark", Boilermaker::Themes.default_polarity_for("amber")
  end

  test "has_overlays? returns correct value" do
    refute Boilermaker::Themes.has_overlays?("paper")
    assert Boilermaker::Themes.has_overlays?("terminal")
    assert Boilermaker::Themes.has_overlays?("blueprint")
    refute Boilermaker::Themes.has_overlays?("brutalist")
    assert Boilermaker::Themes.has_overlays?("amber")
  end

  test "unique_components_for returns correct components" do
    assert_empty Boilermaker::Themes.unique_components_for("paper")
    assert_equal %w[command_bar], Boilermaker::Themes.unique_components_for("terminal")
    assert_equal %w[section_marker], Boilermaker::Themes.unique_components_for("blueprint")
    assert_equal %w[keyboard_hint], Boilermaker::Themes.unique_components_for("brutalist")
    assert_equal %w[fn_bar], Boilermaker::Themes.unique_components_for("amber")
  end
end
