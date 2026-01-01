# frozen_string_literal: true

require_relative "component_test_case"
require_relative "test_helpers"

class PromptHeaderTest < ComponentTestCase
  include ComponentTestHelpers

  test "renders successfully" do
    header = Components::Boilermaker::PromptHeader.new(text: "test command")

    assert_renders_successfully(header)
    assert_produces_output(header)
  end

  test "renders dollar sign prompt prefix" do
    header = Components::Boilermaker::PromptHeader.new(text: "ls -la")

    assert_has_text(header, "$ ")
  end

  test "renders text content" do
    header = Components::Boilermaker::PromptHeader.new(text: "PATENTWATCH v2.1")

    assert_has_text(header, "PATENTWATCH v2.1")
  end

  test "applies text-sm class" do
    header = Components::Boilermaker::PromptHeader.new(text: "test")

    assert_has_css_class(header, "text-sm")
  end

  test "prompt has accent styling" do
    header = Components::Boilermaker::PromptHeader.new(text: "test")

    doc = render_and_parse(header)
    prompt_span = doc.css("span.text-accent").first

    assert prompt_span, "Should have span with text-accent class"
    assert_equal "$ ", prompt_span.text
  end

  test "text has muted styling" do
    header = Components::Boilermaker::PromptHeader.new(text: "my text")

    doc = render_and_parse(header)
    text_span = doc.css("span.text-muted").first

    assert text_span, "Should have span with text-muted class"
    assert_equal "my text", text_span.text
  end

  test "accepts custom attributes" do
    header = Components::Boilermaker::PromptHeader.new(
      text: "test",
      id: "prompt-1",
      "data-testid": "prompt"
    )

    assert_has_attributes(header, "div", {
      id: "prompt-1",
      "data-testid" => "prompt"
    })
  end
end
