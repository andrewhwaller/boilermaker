# frozen_string_literal: true

require_relative "component_test_case"
require_relative "test_helpers"

class TitleBlockTest < ComponentTestCase
  include ComponentTestHelpers

  test "renders successfully with just title" do
    block = Components::Boilermaker::TitleBlock.new(title: "PROJECT ALPHA")

    assert_renders_successfully(block)
    assert_produces_output(block)
  end

  test "renders title text" do
    block = Components::Boilermaker::TitleBlock.new(title: "PATENTWATCH")

    assert_has_text(block, "PATENTWATCH")
  end

  test "renders description when provided" do
    block = Components::Boilermaker::TitleBlock.new(
      title: "PATENTWATCH",
      description: "Patent Monitoring System"
    )

    assert_has_text(block, "Patent Monitoring System")
  end

  test "renders metadata fields" do
    block = Components::Boilermaker::TitleBlock.new(
      title: "Test",
      user: "jdoe",
      date: "2024-01-15",
      revision: "A"
    )

    assert_has_text(block, "USER")
    assert_has_text(block, "jdoe")
    assert_has_text(block, "DATE")
    assert_has_text(block, "2024-01-15")
    assert_has_text(block, "REV")
    assert_has_text(block, "A")
  end

  test "only includes provided metadata fields" do
    block = Components::Boilermaker::TitleBlock.new(title: "Test", revision: "B")

    html = render_component(block)

    assert_not html.include?("USER"), "Should not include USER"
    assert html.include?("REV"), "Should include REV"
  end

  test "main content has right border when metadata present" do
    block = Components::Boilermaker::TitleBlock.new(title: "Test", revision: "A")

    html = render_component(block)
    assert html.include?("border-r-2"), "Should have right border when metadata present"
  end

  test "main content has no right border when no metadata" do
    block = Components::Boilermaker::TitleBlock.new(title: "Test")

    html = render_component(block)
    assert_not html.include?("border-r-2"), "Should not have right border when no metadata"
  end

  test "accepts custom attributes" do
    block = Components::Boilermaker::TitleBlock.new(
      title: "Test",
      id: "project-title",
      "data-testid": "title-block"
    )

    assert_has_attributes(block, "div", {
      id: "project-title",
      "data-testid" => "title-block"
    })
  end
end
