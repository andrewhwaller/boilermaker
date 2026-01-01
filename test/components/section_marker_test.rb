# frozen_string_literal: true

require_relative "component_test_case"
require_relative "test_helpers"

class SectionMarkerTest < ComponentTestCase
  include ComponentTestHelpers

  test "renders successfully" do
    marker = Components::Boilermaker::SectionMarker.new(letter: "A", title: "OVERVIEW")

    assert_renders_successfully(marker)
    assert_produces_output(marker)
  end

  test "renders section element" do
    marker = Components::Boilermaker::SectionMarker.new(letter: "A", title: "OVERVIEW")

    assert_has_tag(marker, "section")
  end

  test "renders letter marker" do
    marker = Components::Boilermaker::SectionMarker.new(letter: "B", title: "DETAILS")

    assert_has_text(marker, "B")
  end

  test "renders title text" do
    marker = Components::Boilermaker::SectionMarker.new(letter: "A", title: "SYSTEM OVERVIEW")

    assert_has_text(marker, "SYSTEM OVERVIEW")
  end

  test "renders reference when provided" do
    marker = Components::Boilermaker::SectionMarker.new(letter: "A", title: "OVERVIEW", ref: "REF-001")

    assert_has_text(marker, "REF-001")
  end

  test "applies relative positioning" do
    marker = Components::Boilermaker::SectionMarker.new(letter: "A", title: "OVERVIEW")

    assert_has_css_class(marker, "relative")
  end

  test "applies left padding for marker space" do
    marker = Components::Boilermaker::SectionMarker.new(letter: "A", title: "OVERVIEW")

    assert_has_css_class(marker, "pl-10")
  end

  test "applies bottom margin" do
    marker = Components::Boilermaker::SectionMarker.new(letter: "A", title: "OVERVIEW")

    assert_has_css_class(marker, "mb-8")
  end

  test "marker is absolutely positioned" do
    marker = Components::Boilermaker::SectionMarker.new(letter: "A", title: "OVERVIEW")

    assert_has_css_class(marker, "absolute")
  end

  test "marker has accent border" do
    marker = Components::Boilermaker::SectionMarker.new(letter: "A", title: "OVERVIEW")

    doc = render_and_parse(marker)
    marker_div = doc.css("div.border-accent.border-2").first

    assert marker_div, "Should have marker with accent border"
  end

  test "marker has fixed dimensions" do
    marker = Components::Boilermaker::SectionMarker.new(letter: "A", title: "OVERVIEW")

    doc = render_and_parse(marker)
    marker_div = doc.css("div.w-6.h-6").first

    assert marker_div, "Should have 6x6 marker dimensions"
  end

  test "marker has surface background" do
    marker = Components::Boilermaker::SectionMarker.new(letter: "A", title: "OVERVIEW")

    assert_has_css_class(marker, "bg-surface")
  end

  test "marker letter is bold and small" do
    marker = Components::Boilermaker::SectionMarker.new(letter: "A", title: "OVERVIEW")

    doc = render_and_parse(marker)
    marker_div = doc.css("div.font-bold.text-xs").first

    assert marker_div, "Should have bold small text"
  end

  test "marker letter has accent color" do
    marker = Components::Boilermaker::SectionMarker.new(letter: "A", title: "OVERVIEW")

    doc = render_and_parse(marker)
    marker_div = doc.css("div.text-accent").first

    assert marker_div, "Should have accent text color"
  end

  test "marker is centered" do
    marker = Components::Boilermaker::SectionMarker.new(letter: "A", title: "OVERVIEW")

    doc = render_and_parse(marker)
    marker_div = doc.css("div.flex.items-center.justify-center").first

    assert marker_div, "Should be centered with flexbox"
  end

  test "header has bottom border" do
    marker = Components::Boilermaker::SectionMarker.new(letter: "A", title: "OVERVIEW")

    doc = render_and_parse(marker)
    header_div = doc.css("div.border-b.border-accent").first

    assert header_div, "Should have bottom border"
  end

  test "title has uppercase styling" do
    marker = Components::Boilermaker::SectionMarker.new(letter: "A", title: "OVERVIEW")

    doc = render_and_parse(marker)
    title_span = doc.css("span.uppercase").first

    assert title_span, "Should have uppercase title"
  end

  test "title has tracking wider" do
    marker = Components::Boilermaker::SectionMarker.new(letter: "A", title: "OVERVIEW")

    doc = render_and_parse(marker)
    title_span = doc.css("span.tracking-wider").first

    assert title_span, "Should have wider tracking"
  end

  test "title has accent color" do
    marker = Components::Boilermaker::SectionMarker.new(letter: "A", title: "OVERVIEW")

    doc = render_and_parse(marker)
    title_span = doc.css("span.text-accent").first

    assert title_span, "Title should have accent color"
  end

  test "reference has muted small text" do
    marker = Components::Boilermaker::SectionMarker.new(letter: "A", title: "OVERVIEW", ref: "REF-001")

    doc = render_and_parse(marker)
    ref_span = doc.css("span.text-muted").first

    assert ref_span, "Reference should have muted color"
  end

  test "reference has tiny text size" do
    marker = Components::Boilermaker::SectionMarker.new(letter: "A", title: "OVERVIEW", ref: "REF-001")

    html = render_component(marker)
    assert html.include?("text-[9px]"), "Should have 9px text size"
  end

  test "yields block content" do
    html = render_component(
      Components::Boilermaker::SectionMarker.new(letter: "A", title: "OVERVIEW")
    ) { "Section content here" }

    assert html.include?("Section content here"), "Should render block content"
  end

  test "accepts custom attributes" do
    marker = Components::Boilermaker::SectionMarker.new(
      letter: "A",
      title: "OVERVIEW",
      id: "section-a",
      "data-testid": "section-marker"
    )

    assert_has_attributes(marker, "section", {
      id: "section-a",
      "data-testid" => "section-marker"
    })
  end
end
