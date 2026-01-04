# frozen_string_literal: true

require_relative "component_test_case"
require_relative "test_helpers"

class FileListTest < ComponentTestCase
  include ComponentTestHelpers

  test "renders empty state when no attachments" do
    list = Components::FileList.new(attachments: nil)
    html = render_component(list)
    assert html.include?("No files uploaded")
  end

  # Note: Testing with real ActiveStorage attachments would require
  # fixtures with actual file uploads. The component's rendering logic
  # with real attachments is covered by system tests.
end
