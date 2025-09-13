# frozen_string_literal: true

require "test_helper"

class ActionsTest < ComponentTestCase
  def test_renders_empty_actions_cell_with_block
    component = Components::Table::Actions.new
    html = render_component(component) { "Custom actions content" }
    doc = parse_html(html)

    assert doc.css("td.text-right").any?
    assert doc.css("td div.flex.items-center.gap-1").any?
    assert_includes html, "Custom actions content"
  end

  def test_renders_actions_with_default_alignment
    component = Components::Table::Actions.new
    html = render_component(component)
    doc = parse_html(html)
    assert doc.css("td.text-right").any?
  end

  def test_renders_actions_with_left_alignment
    component = Components::Table::Actions.new(align: :left)
    html = render_component(component)
    doc = parse_html(html)
    assert doc.css("td.text-left").any?
  end

  def test_renders_actions_with_center_alignment
    component = Components::Table::Actions.new(align: :center)
    html = render_component(component)
    doc = parse_html(html)
    assert doc.css("td.text-center").any?
  end

  def test_renders_button_actions
    items = [
      { type: :button, text: "Edit", attributes: { data: { action: "edit", id: "1" } } },
      { type: :button, text: "Delete", attributes: { data: { action: "delete", id: "1" } } }
    ]

    component = Components::Table::Actions.new(items: items)

    html = render_component(component)
    doc = parse_html(html)
    assert_equal 2, doc.css("button.btn.btn-ghost.btn-xs").length
    assert doc.css("button[data-action='edit'][data-id='1']").any? && html.include?("Edit")
    assert doc.css("button[data-action='delete'][data-id='1']").any? && html.include?("Delete")
  end

  def test_renders_link_actions
    items = [
      { type: :link, text: "View", href: "/items/1" },
      { type: :link, text: "Edit", href: "/items/1/edit" }
    ]

    component = Components::Table::Actions.new(items: items)

    html = render_component(component)
    doc = parse_html(html)
    assert_equal 2, doc.css("a.btn.btn-ghost.btn-xs").length
    assert doc.css("a[href='/items/1']").any? && html.include?("View")
    assert doc.css("a[href='/items/1/edit']").any? && html.include?("Edit")
  end

  def test_renders_dropdown_actions
    items = [
      {
        type: :dropdown,
        items: [
          { type: :link, text: "View", href: "/items/1" },
          { type: :button, text: "Delete", attributes: { data: { action: "delete", id: "1" } } }
        ]
      }
    ]

    component = Components::Table::Actions.new(items: items)

    html = render_component(component)
    doc = parse_html(html)
    assert doc.css(".dropdown.dropdown-end").any?
    assert doc.css(".dropdown button.btn.btn-ghost.btn-xs").any?
    assert_includes html, "⋯"
    assert doc.css(".dropdown-content.menu").any?
    assert doc.css("li a[href='/items/1']").any? && html.include?("View")
    assert doc.css("li button[data-action='delete'][data-id='1']").any? && html.include?("Delete")
  end

  def test_renders_mixed_action_types
    items = [
      { type: :button, text: "Edit" },
      { type: :link, text: "View", href: "/items/1" },
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
    doc = parse_html(html)
    assert doc.css("button.btn.btn-ghost.btn-xs").any? && html.include?("Edit")
    assert doc.css("a.btn.btn-ghost.btn-xs[href='/items/1']").any? && html.include?("View")
    assert doc.css(".dropdown button.btn.btn-ghost.btn-xs").any?
  end

  def test_passes_additional_attributes_to_cell
    component = Components::Table::Actions.new(id: "actions-cell", data: { test: "value" })
    html = render_component(component)
    doc = parse_html(html)
    assert doc.css("td#actions-cell[data-test='value']").any?
  end
end
