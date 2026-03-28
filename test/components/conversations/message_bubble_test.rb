# frozen_string_literal: true

require_relative "../component_test_case"
require_relative "../test_helpers"

class Conversations::MessageBubbleTest < ComponentTestCase
  include ComponentTestHelpers

  def user_message
    messages(:user_message)
  end

  def assistant_message
    messages(:assistant_message)
  end

  def incomplete_message
    messages(:incomplete_message)
  end

  # User messages

  test "renders user message with role label 'You'" do
    html = render_component(Components::Conversations::MessageBubble.new(message: user_message))
    assert html.include?("You"),
      "User message should display 'You' as the role label"
  end

  test "renders user message content as plain text" do
    html = render_component(Components::Conversations::MessageBubble.new(message: user_message))
    assert html.include?(user_message.content),
      "User message content should appear in the rendered output"
  end

  test "user message has ui-message-bubble CSS class" do
    assert_has_css_class(
      Components::Conversations::MessageBubble.new(message: user_message),
      "ui-message-bubble"
    )
  end

  test "user message does not have markdown controller data attribute" do
    html = render_component(Components::Conversations::MessageBubble.new(message: user_message))
    refute html.include?('data-controller="markdown"'),
      "User messages should not use the markdown Stimulus controller"
  end

  # Assistant messages

  test "renders assistant message with role label 'Assistant'" do
    html = render_component(Components::Conversations::MessageBubble.new(message: assistant_message))
    assert html.include?("Assistant"),
      "Assistant message should display 'Assistant' as the role label"
  end

  test "assistant message has markdown controller data attribute" do
    html = render_component(Components::Conversations::MessageBubble.new(message: assistant_message))
    assert html.include?('data-controller="markdown"'),
      "Assistant messages should use the markdown Stimulus controller"
  end

  test "assistant message includes raw content as markdown data value" do
    html = render_component(Components::Conversations::MessageBubble.new(message: assistant_message))
    assert html.include?("data-markdown-raw-value"),
      "Assistant message should pass raw content to markdown controller via data attribute"
    assert html.include?(assistant_message.content),
      "Raw content should be present in the data attribute"
  end

  test "assistant message has markdown output target" do
    html = render_component(Components::Conversations::MessageBubble.new(message: assistant_message))
    assert html.include?('data-markdown-target="output"'),
      "Assistant message output div should have markdown target attribute"
  end

  # Incomplete (interrupted) state
  # When complete: false on page load, the component shows "Response was interrupted"
  # indicating the streaming job crashed before completion

  test "incomplete assistant message shows interrupted indicator" do
    html = render_component(Components::Conversations::MessageBubble.new(message: incomplete_message))
    assert html.include?("Response was interrupted"),
      "Incomplete assistant message (complete: false on page load) should show interrupted indicator"
  end

  test "incomplete assistant message has yellow border styling" do
    html = render_component(Components::Conversations::MessageBubble.new(message: incomplete_message))
    assert html.include?("border-yellow"),
      "Incomplete/interrupted message should have yellow border styling"
  end

  test "incomplete assistant message does not show completed assistant styling" do
    html = render_component(Components::Conversations::MessageBubble.new(message: incomplete_message))
    refute html.include?("Response failed"),
      "Interrupted message should not show error state"
  end

  # Error state

  test "assistant message with error marker shows error state" do
    error_message = Message.new(
      role: "assistant",
      content: "Partial response\n\n---\n*Error: OpenAI request failed*",
      complete: true
    )
    html = render_component(Components::Conversations::MessageBubble.new(message: error_message))
    assert html.include?("Response failed"),
      "Error state should display 'Response failed' message"
  end

  test "assistant message with error marker has destructive border class" do
    error_message = Message.new(
      role: "assistant",
      content: "Partial\n\n---\n*Error: Something went wrong*",
      complete: true
    )
    html = render_component(Components::Conversations::MessageBubble.new(message: error_message))
    assert html.include?("border-destructive"),
      "Error state should apply destructive border styling"
  end

  # DOM id

  test "message bubble has id attribute based on message id" do
    message = assistant_message
    html = render_component(Components::Conversations::MessageBubble.new(message: message))
    assert html.include?("id=\"message_#{message.id}\""),
      "Message bubble should have a unique id for Turbo Stream targeting"
  end
end
