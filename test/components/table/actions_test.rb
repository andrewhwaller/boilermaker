# frozen_string_literal: true

require "test_helper"
require_relative "../component_test_case"

class ActionsTest < ComponentTestCase
  def test_renders_empty_actions_cell_with_block
    component = Components::Table::Actions.new
    html = render_component(component) { "Custom actions content" }
    assert_includes html, "Custom actions content"
  end

  def test_renders_actions_with_default_alignment
    component = Components::Table::Actions.new
    assert_renders_successfully component
  end

  def test_renders_actions_with_left_alignment
    component = Components::Table::Actions.new(align: :left)
    assert_renders_successfully component
  end

  def test_renders_actions_with_center_alignment
    component = Components::Table::Actions.new(align: :center)
    assert_renders_successfully component
  end

  def test_renders_button_actions
    items = [
      { type: :button, text: "Edit", attributes: { data: { action: "edit", id: "abC123xy" } } },
      { type: :button, text: "Delete", attributes: { data: { action: "delete", id: "abC123xy" } } }
    ]

    component = Components::Table::Actions.new(items: items)

    html = render_component(component)
    doc = parse_html(html)
    assert doc.css("button[data-action='edit'][data-id='abC123xy']").any? && html.include?("Edit")
    assert doc.css("button[data-action='delete'][data-id='abC123xy']").any? && html.include?("Delete")
  end

  def test_renders_link_actions
    items = [
      { type: :link, text: "View", href: "/items/abC123xy" },
      { type: :link, text: "Edit", href: "/items/abC123xy/edit" }
    ]

    component = Components::Table::Actions.new(items: items)

    html = render_component(component)
    doc = parse_html(html)
    assert doc.css("a[href='/items/abC123xy']").any? && html.include?("View")
    assert doc.css("a[href='/items/abC123xy/edit']").any? && html.include?("Edit")
  end

  def test_renders_dropdown_actions
    items = [
      {
        type: :dropdown,
        items: [
          { type: :link, text: "View", href: "/items/abC123xy" },
          { type: :button, text: "Delete", attributes: { data: { action: "delete", id: "abC123xy" } } }
        ]
      }
    ]

    component = Components::Table::Actions.new(items: items)

    html = render_component(component)
    doc = parse_html(html)
    assert_includes html, "⋯"
    assert doc.css("li a[href='/items/abC123xy']").any? && html.include?("View")
    assert doc.css("li button[data-action='delete'][data-id='abC123xy']").any? && html.include?("Delete")
  end

  def test_renders_mixed_action_types
    items = [
      { type: :button, text: "Edit" },
      { type: :link, text: "View", href: "/items/abC123xy" },
      {
        type: :dropdown,
        items: [
          { type: :button, text: "Archive" },
          { type: :button, text: "Delete" }
        ]
      }
    ]

    component = Components::Table::Actions.new(items: items)

    html = render_component(component)
    assert html.include?("Edit")
    assert html.include?("View")
    assert html.include?("Archive")
    assert html.include?("Delete")
  end

  def test_passes_additional_attributes_to_cell
    component = Components::Table::Actions.new(id: "actions-cell", data: { test: "value" })
    html = render_component(component)
    doc = parse_html(html)
    assert doc.css("td#actions-cell[data-test='value']").any?
  end
end
