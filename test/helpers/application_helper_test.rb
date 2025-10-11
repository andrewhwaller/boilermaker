# frozen_string_literal: true

require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "page_title returns app name when no title provided" do
    assert_equal Boilermaker.config.app_name, page_title
  end

  test "page_title includes custom title with app name" do
    title = page_title("Dashboard")
    assert_includes title, "Dashboard"
    assert_includes title, Boilermaker.config.app_name
  end

  test "page_title uses content_for title when available" do
    content_for :title, "Custom Title"
    title = page_title
    assert_includes title, "Custom Title"
    assert_includes title, Boilermaker.config.app_name
  end
end
