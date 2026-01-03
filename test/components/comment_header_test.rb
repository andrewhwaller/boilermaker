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
