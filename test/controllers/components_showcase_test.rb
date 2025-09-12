# frozen_string_literal: true

require "test_helper"

class ComponentsShowcaseTest < ActionView::TestCase
  test "components showcase view renders successfully" do
    view = Views::Home::Components.new
    html = view.call

    assert html.present?
    assert html.include?("Phlex Component Showcase")
    assert html.include?("Component Library Overview")
  end

  test "showcase includes all major component sections" do
    view = Views::Home::Components.new
    html = view.call

    # Check for major sections
    assert html.include?("Link Components")
    assert html.include?("Button Components")
    assert html.include?("Form Input Components")
    assert html.include?("Form Layout Components")
    assert html.include?("Feedback Components")
    assert html.include?("Utility Components")
    assert html.include?("Layout Components")
    assert html.include?("Testing Infrastructure")
    assert html.include?("Developer Style Guide")
  end

  test "showcase includes component examples" do
    view = Views::Home::Components.new
    html = view.call

    # Check for basic component text patterns
    assert html.include?("Link"), "Missing any Link text"
    assert html.include?("Primary"), "Missing Primary text"
    assert html.include?("Button"), "Missing Button text"
    assert html.include?("Badge"), "Missing Badge text"
    assert html.include?("Alert"), "Missing Alert text"
  end

  test "showcase includes code examples" do
    view = Views::Home::Components.new
    html = view.call

    # Check for code examples
    assert html.include?("Ruby Code")
    assert html.include?("Components::Link.new")
    assert html.include?("Components::Badge.new")
    assert html.include?("Copy")
  end

  test "showcase includes style guide documentation" do
    view = Views::Home::Components.new
    html = view.call

    # Check for style guide sections
    assert html.include?("Component Architecture")
    assert html.include?("Naming Conventions")
    assert html.include?("Integration Patterns")
    assert html.include?("Performance Guidelines")
  end

  test "showcase includes testing documentation" do
    view = Views::Home::Components.new
    html = view.call

    # Check for testing sections
    assert html.include?("ComponentTestCase")
    assert html.include?("Testing Best Practices")
    assert html.include?("assert_component_html")
  end

  test "showcase has navigation structure" do
    view = Views::Home::Components.new
    html = view.call

    # Check for navigation elements
    assert html.include?("overview"), "Missing overview section"
    assert html.include?("links"), "Missing links section"
    assert html.include?("buttons"), "Missing buttons section"
    assert html.include?("feedback"), "Missing feedback section"
    assert html.include?("utility"), "Missing utility section"
    assert html.include?("testing"), "Missing testing section"
    assert html.include?("style-guide"), "Missing style guide section"
  end

  test "showcase includes footer with library information" do
    view = Views::Home::Components.new
    html = view.call

    # Check for footer content
    assert html.include?("Phlex Component Library")
    assert html.include?("Component Categories")
    assert html.include?("Features")
    assert html.include?("Development")
  end
end
