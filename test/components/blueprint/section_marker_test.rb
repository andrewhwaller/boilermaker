# frozen_string_literal: true

require_relative "../component_test_case"
require_relative "../test_helpers"

class Components::Blueprint::SectionMarkerTest < ComponentTestCase
  include ComponentTestHelpers

  test "renders section marker with number" do
    component = Components::Blueprint::SectionMarker.new(number: 1)
    output = render_component(component)

    assert_includes output, "data-controller=\"section-marker\""
    assert_includes output, "01"
    assert_includes output, "id=\"section-1\""
  end

  test "renders section marker with title" do
    component = Components::Blueprint::SectionMarker.new(number: 2, title: "Overview")
    output = render_component(component)

    assert_includes output, "02"
    assert_includes output, "Overview"
  end

  test "renders section marker with custom id" do
    component = Components::Blueprint::SectionMarker.new(number: 3, id: "custom-section")
    output = render_component(component)

    assert_includes output, "id=\"custom-section\""
    assert_includes output, "href=\"#custom-section\""
  end

  test "formats number with leading zero" do
    component1 = Components::Blueprint::SectionMarker.new(number: 5)
    output = render_component(component1)
    assert_includes output, "05"

    component2 = Components::Blueprint::SectionMarker.new(number: 12)
    output = render_component(component2)
    assert_includes output, "12"
  end

  test "has correct stimulus action" do
    component = Components::Blueprint::SectionMarker.new(number: 1)
    output = render_component(component)

    assert_includes output, "click->section-marker#scrollTo"
  end
end
