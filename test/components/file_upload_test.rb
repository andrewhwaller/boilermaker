# frozen_string_literal: true

require_relative "component_test_case"
require_relative "test_helpers"

class FileUploadTest < ComponentTestCase
  include ComponentTestHelpers

  test "renders file input with correct name for form submission" do
    upload = Components::FileUpload.new(name: "user[documents][]")
    html = render_component(upload)
    assert html.include?('name="user[documents][]"')
    assert html.include?('type="file"')
  end

  test "respects accept attribute to restrict file types" do
    upload = Components::FileUpload.new(name: "avatar", accept: "image/*")
    html = render_component(upload)
    assert html.include?('accept="image/*"')
  end

  test "respects multiple attribute for multi-file selection" do
    upload = Components::FileUpload.new(name: "documents[]", multiple: true)
    html = render_component(upload)
    assert html.include?("multiple")
  end

  test "configures direct upload when enabled" do
    upload = Components::FileUpload.new(name: "avatar", direct_upload: true)
    html = render_component(upload)
    assert html.include?("/rails/active_storage/direct_uploads")
  end

  test "omits direct upload when disabled" do
    upload = Components::FileUpload.new(name: "avatar", direct_upload: false)
    html = render_component(upload)
    refute html.include?("direct_upload_url")
  end

  test "displays custom label when provided" do
    upload = Components::FileUpload.new(name: "avatar", label: "Upload your photo")
    html = render_component(upload)
    assert html.include?("Upload your photo")
  end

  test "shows file type hint based on accept parameter" do
    with_accept = Components::FileUpload.new(name: "avatar", accept: "image/*")
    assert render_component(with_accept).include?("Accepts: image/*")

    without_accept = Components::FileUpload.new(name: "files")
    assert render_component(without_accept).include?("Any file type")
  end
end
