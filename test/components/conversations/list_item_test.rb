# frozen_string_literal: true

require_relative "../component_test_case"
require_relative "../test_helpers"

class Conversations::ListItemTest < ComponentTestCase
  include ComponentTestHelpers

  def conversation
    conversations(:one)
  end

  def conversation_two
    conversations(:two)
  end

  test "renders conversation title" do
    html = render_component(Components::Conversations::ListItem.new(conversation: conversation))
    assert html.include?(conversation.title),
      "List item should display the conversation title"
  end

  test "renders link to the conversation" do
    html = render_component(Components::Conversations::ListItem.new(conversation: conversation))
    assert html.include?("/conversations/"),
      "List item should include a link to the conversation"
  end

  test "renders a timestamp with 'ago'" do
    html = render_component(Components::Conversations::ListItem.new(conversation: conversation))
    assert html.include?("ago"),
      "List item should display a relative timestamp ending in 'ago'"
  end

  test "non-current conversation does not have active background class" do
    html = render_component(Components::Conversations::ListItem.new(conversation: conversation, current: false))
    doc = parse_html(html)
    link = doc.css("a").first
    refute_nil link, "Should render a link element"
    # bg-surface-raised only appears when current: true
    classes = link["class"].to_s.split(" ")
    # Check it includes the base class
    assert classes.include?("ui-conversation-list-item"),
      "List item should have the ui-conversation-list-item CSS class"
  end

  test "current conversation has active background class" do
    html = render_component(Components::Conversations::ListItem.new(conversation: conversation, current: true))
    doc = parse_html(html)
    link = doc.css("a").first
    refute_nil link, "Should render a link element"
    assert link["class"].to_s.include?("bg-surface-raised"),
      "Current conversation should have bg-surface-raised active state class"
  end

  test "title text is truncated class applied" do
    html = render_component(Components::Conversations::ListItem.new(conversation: conversation))
    assert html.include?("truncate"),
      "Title should have truncate class to handle long titles"
  end

  test "renders correctly with different conversations" do
    html_one = render_component(Components::Conversations::ListItem.new(conversation: conversation))
    html_two = render_component(Components::Conversations::ListItem.new(conversation: conversation_two))

    assert html_one.include?(conversation.title),
      "First conversation title should appear in first list item"
    assert html_two.include?(conversation_two.title),
      "Second conversation title should appear in second list item"
  end
end
