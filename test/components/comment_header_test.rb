# frozen_string_literal: true

require_relative "component_test_case"
require_relative "test_helpers"

class CommentHeaderTest < ComponentTestCase
  include ComponentTestHelpers

  test "renders successfully" do
    header = Components::Boilermaker::CommentHeader.new(title: "SECTION")

    assert_renders_successfully(header)
    assert_produces_output(header)
  end

  test "renders double slash comment prefix" do
    header = Components::Boilermaker::CommentHeader.new(title: "ALERTS")

    assert_has_text(header, "// ALERTS")
  end

  test "applies uppercase styling" do
    header = Components::Boilermaker::CommentHeader.new(title: "test")

    assert_has_css_class(header, "uppercase")
  end

  test "applies text-xs styling" do
    header = Components::Boilermaker::CommentHeader.new(title: "test")

    assert_has_css_class(header, "text-xs")
  end

  test "applies tracking-wider styling" do
    header = Components::Boilermaker::CommentHeader.new(title: "test")

    assert_has_css_class(header, "tracking-wider")
  end

  test "applies muted text color" do
    header = Components::Boilermaker::CommentHeader.new(title: "test")

    assert_has_css_class(header, "text-muted")
  end

  test "applies dashed border" do
    header = Components::Boilermaker::CommentHeader.new(title: "test")

    assert_has_css_class(header, "border-dashed")
    assert_has_css_class(header, "border-b")
    assert_has_css_class(header, "border-border-light")
  end

  test "applies bottom padding and margin" do
    header = Components::Boilermaker::CommentHeader.new(title: "test")

    assert_has_css_class(header, "pb-1")
    assert_has_css_class(header, "mb-2")
  end

  test "accepts custom attributes" do
    header = Components::Boilermaker::CommentHeader.new(
      title: "SECTION",
      id: "section-header",
      "data-testid": "comment-header"
    )

    assert_has_attributes(header, "div", {
      id: "section-header",
      "data-testid" => "comment-header"
    })
  end
end
