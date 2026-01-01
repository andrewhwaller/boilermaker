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

  test "applies grid layout" do
    block = Components::Boilermaker::TitleBlock.new(title: "Test")

    assert_has_css_class(block, "grid")

    html = render_component(block)
    assert html.include?("grid-cols-[1fr_auto]"), "Should have grid-cols-[1fr_auto] class"
  end

  test "applies accent border" do
    block = Components::Boilermaker::TitleBlock.new(title: "Test")

    assert_has_css_class(block, "border-2")
    assert_has_css_class(block, "border-accent")
  end

  test "applies bottom margin" do
    block = Components::Boilermaker::TitleBlock.new(title: "Test")

    assert_has_css_class(block, "mb-8")
  end

  test "title has accent text color" do
    block = Components::Boilermaker::TitleBlock.new(title: "Test")

    doc = render_and_parse(block)
    title_div = doc.css("div.text-accent").first

    assert title_div, "Should have div with text-accent class"
  end

  test "title is bold and large" do
    block = Components::Boilermaker::TitleBlock.new(title: "Test")

    doc = render_and_parse(block)
    title_div = doc.css("div.font-bold.text-lg").first

    assert title_div, "Should have bold, large text"
  end

  test "title has wide tracking" do
    block = Components::Boilermaker::TitleBlock.new(title: "Test")

    doc = render_and_parse(block)
    title_div = doc.css("div.tracking-wide").first

    assert title_div, "Should have tracking-wide"
  end

  test "description has muted text color" do
    block = Components::Boilermaker::TitleBlock.new(title: "Test", description: "Desc")

    doc = render_and_parse(block)
    desc_div = doc.css("div.text-muted.text-xs").first

    assert desc_div, "Should have muted, small description"
  end

  test "renders metadata fields" do
    block = Components::Boilermaker::TitleBlock.new(
      title: "Test",
      drawing_no: "PW-001",
      revision: "A",
      date: "2024-01-15",
      scale: "1:1"
    )

    assert_has_text(block, "DWG NO")
    assert_has_text(block, "PW-001")
    assert_has_text(block, "REV")
    assert_has_text(block, "A")
    assert_has_text(block, "DATE")
    assert_has_text(block, "2024-01-15")
    assert_has_text(block, "SCALE")
    assert_has_text(block, "1:1")
  end

  test "metadata labels have muted text color" do
    block = Components::Boilermaker::TitleBlock.new(title: "Test", drawing_no: "PW-001")

    doc = render_and_parse(block)
    label_spans = doc.css("span.text-muted")

    assert label_spans.any?, "Should have muted label spans"
  end

  test "metadata values have accent text and bold" do
    block = Components::Boilermaker::TitleBlock.new(title: "Test", drawing_no: "PW-001")

    doc = render_and_parse(block)
    value_spans = doc.css("span.font-semibold.text-accent")

    assert value_spans.any?, "Should have bold accent value spans"
  end

  test "metadata has small text size" do
    block = Components::Boilermaker::TitleBlock.new(title: "Test", drawing_no: "PW-001")

    html = render_component(block)
    assert html.include?("text-[10px]"), "Should have 10px text size"
  end

  test "metadata has minimum width" do
    block = Components::Boilermaker::TitleBlock.new(title: "Test", drawing_no: "PW-001")

    html = render_component(block)
    assert html.include?("min-w-[160px]"), "Should have min width"
  end

  test "main content has right border when metadata present" do
    block = Components::Boilermaker::TitleBlock.new(title: "Test", drawing_no: "PW-001")

    html = render_component(block)
    assert html.include?("border-r-2"), "Should have right border"
  end

  test "main content has no right border when no metadata" do
    block = Components::Boilermaker::TitleBlock.new(title: "Test")

    html = render_component(block)
    assert_not html.include?("border-r-2"), "Should not have right border"
  end

  test "only includes provided metadata fields" do
    block = Components::Boilermaker::TitleBlock.new(title: "Test", revision: "B")

    html = render_component(block)

    assert_not html.include?("DWG NO"), "Should not include DWG NO"
    assert html.include?("REV"), "Should include REV"
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
