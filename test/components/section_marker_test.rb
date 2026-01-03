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

  test "does not render reference when not provided" do
    marker = Components::Boilermaker::SectionMarker.new(letter: "A", title: "OVERVIEW")

    html = render_component(marker)
    assert_not html.include?("REF-"), "Should not render reference element when not provided"
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
