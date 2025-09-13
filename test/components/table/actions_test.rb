# frozen_string_literal: true

require "test_helper"

class Table::ActionsTest < ComponentTestCase
  def test_renders_empty_actions_cell_with_block
    component = Components::Table::Actions.new

    render_inline(component) do
      "Custom actions content"
    end

    assert_selector "td.text-right"
    assert_selector "td div.flex.items-center.gap-1"
    assert_text "Custom actions content"
  end

  def test_renders_actions_with_default_alignment
    component = Components::Table::Actions.new

    render_inline(component)

    assert_selector "td.text-right"
  end

  def test_renders_actions_with_left_alignment
    component = Components::Table::Actions.new(align: :left)

    render_inline(component)

    assert_selector "td.text-left"
  end

  def test_renders_actions_with_center_alignment
    component = Components::Table::Actions.new(align: :center)

    render_inline(component)

    assert_selector "td.text-center"
  end

  def test_renders_button_actions
    items = [
      { type: :button, text: "Edit", attributes: { data: { action: "edit", id: "1" } } },
      { type: :button, text: "Delete", attributes: { data: { action: "delete", id: "1" } } }
    ]

    component = Components::Table::Actions.new(items: items)

    render_inline(component)

    assert_selector "button.btn.btn-ghost.btn-xs", count: 2
    assert_selector "button[data-action='edit'][data-id='1']", text: "Edit"
    assert_selector "button[data-action='delete'][data-id='1']", text: "Delete"
  end

  def test_renders_link_actions
    items = [
      { type: :link, text: "View", href: "/items/1" },
      { type: :link, text: "Edit", href: "/items/1/edit" }
    ]

    component = Components::Table::Actions.new(items: items)

    render_inline(component)

    assert_selector "a.btn.btn-ghost.btn-xs", count: 2
    assert_selector "a[href='/items/1']", text: "View"
    assert_selector "a[href='/items/1/edit']", text: "Edit"
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

    render_inline(component)

    assert_selector ".dropdown.dropdown-end"
    assert_selector "button.btn.btn-ghost.btn-xs", text: "⋯"
    assert_selector ".dropdown-content.menu"
    assert_selector "li a[href='/items/1']", text: "View"
    assert_selector "li button[data-action='delete'][data-id='1']", text: "Delete"
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

    render_inline(component)

    assert_selector "button.btn.btn-ghost.btn-xs", text: "Edit"
    assert_selector "a.btn.btn-ghost.btn-xs[href='/items/1']", text: "View"
    assert_selector ".dropdown button.btn.btn-ghost.btn-xs", text: "⋯"
  end

  def test_passes_additional_attributes_to_cell
    component = Components::Table::Actions.new(id: "actions-cell", data: { test: "value" })

    render_inline(component)

    assert_selector "td[id='actions-cell'][data-test='value']"
  end
end
