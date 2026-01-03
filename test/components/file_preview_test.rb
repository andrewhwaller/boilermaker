# frozen_string_literal: true

require_relative "component_test_case"
require_relative "test_helpers"

class FilePreviewTest < ComponentTestCase
  include ComponentTestHelpers

  test "renders nothing when attachment is nil" do
    preview = Components::FilePreview.new(attachment: nil)
    html = render_component(preview)
    assert html.blank?
  end

  # Note: Testing with real ActiveStorage attachments would require
  # fixtures with actual file uploads. The component's rendering logic
  # with real attachments is covered by system tests.
end
