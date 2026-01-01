# frozen_string_literal: true

require_relative "component_test_case"
require_relative "test_helpers"

class CommandInputTest < ComponentTestCase
  include ComponentTestHelpers

  test "renders successfully" do
    input = Components::Boilermaker::CommandInput.new

    assert_renders_successfully(input)
    assert_produces_output(input)
  end

  test "renders default prompt" do
    input = Components::Boilermaker::CommandInput.new

    assert_has_text(input, ">")
  end

  test "renders custom prompt" do
    input = Components::Boilermaker::CommandInput.new(prompt: "$")

    assert_has_text(input, "$")
  end

  test "renders input element" do
    input = Components::Boilermaker::CommandInput.new

    assert_has_tag(input, "input")
  end

  test "input is text type" do
    input = Components::Boilermaker::CommandInput.new

    doc = render_and_parse(input)
    input_el = doc.css("input").first

    assert_equal "text", input_el["type"]
  end

  test "applies default placeholder" do
    input = Components::Boilermaker::CommandInput.new

    doc = render_and_parse(input)
    input_el = doc.css("input").first

    assert_equal "type command...", input_el["placeholder"]
  end

  test "applies custom placeholder" do
    input = Components::Boilermaker::CommandInput.new(placeholder: "search patents...")

    doc = render_and_parse(input)
    input_el = doc.css("input").first

    assert_equal "search patents...", input_el["placeholder"]
  end

  test "applies default name attribute" do
    input = Components::Boilermaker::CommandInput.new

    doc = render_and_parse(input)
    input_el = doc.css("input").first

    assert_equal "command", input_el["name"]
  end

  test "applies custom name attribute" do
    input = Components::Boilermaker::CommandInput.new(name: "search_query")

    doc = render_and_parse(input)
    input_el = doc.css("input").first

    assert_equal "search_query", input_el["name"]
  end

  test "applies flex layout" do
    input = Components::Boilermaker::CommandInput.new

    assert_has_css_class(input, "flex")
    assert_has_css_class(input, "items-center")
  end

  test "applies gap between elements" do
    input = Components::Boilermaker::CommandInput.new

    assert_has_css_class(input, "gap-2")
  end

  test "applies body background" do
    input = Components::Boilermaker::CommandInput.new

    assert_has_css_class(input, "bg-body")
  end

  test "applies surface text color" do
    input = Components::Boilermaker::CommandInput.new

    assert_has_css_class(input, "text-surface")
  end

  test "applies padding" do
    input = Components::Boilermaker::CommandInput.new

    assert_has_css_class(input, "p-3")
  end

  test "applies monospace font" do
    input = Components::Boilermaker::CommandInput.new

    assert_has_css_class(input, "font-mono")
  end

  test "prompt has muted text color" do
    input = Components::Boilermaker::CommandInput.new

    doc = render_and_parse(input)
    prompt_span = doc.css("span.text-muted").first

    assert prompt_span, "Should have muted prompt"
  end

  test "prompt does not shrink" do
    input = Components::Boilermaker::CommandInput.new

    doc = render_and_parse(input)
    prompt_span = doc.css("span.flex-shrink-0").first

    assert prompt_span, "Prompt should not shrink"
  end

  test "input is flexible" do
    input = Components::Boilermaker::CommandInput.new

    doc = render_and_parse(input)
    input_el = doc.css("input.flex-1").first

    assert input_el, "Input should be flex-1"
  end

  test "input has transparent background" do
    input = Components::Boilermaker::CommandInput.new

    doc = render_and_parse(input)
    input_el = doc.css("input.bg-transparent").first

    assert input_el, "Input should have transparent bg"
  end

  test "input has no border" do
    input = Components::Boilermaker::CommandInput.new

    doc = render_and_parse(input)
    input_el = doc.css("input.border-none").first

    assert input_el, "Input should have no border"
  end

  test "input has no outline" do
    input = Components::Boilermaker::CommandInput.new

    doc = render_and_parse(input)
    input_el = doc.css("input.outline-none").first

    assert input_el, "Input should have no outline"
  end

  test "input has surface text color" do
    input = Components::Boilermaker::CommandInput.new

    doc = render_and_parse(input)
    input_el = doc.css("input.text-surface").first

    assert input_el, "Input should have surface text"
  end

  test "placeholder has semi-transparent muted color" do
    input = Components::Boilermaker::CommandInput.new

    html = render_component(input)
    assert html.include?("placeholder:text-muted/50"), "Should have muted placeholder"
  end

  test "accepts custom attributes" do
    input = Components::Boilermaker::CommandInput.new(
      id: "search-box",
      "data-testid": "command-input"
    )

    assert_has_attributes(input, "div", {
      id: "search-box",
      "data-testid" => "command-input"
    })
  end
end
