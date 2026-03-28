# frozen_string_literal: true

require_relative "../component_test_case"

class Components::Conversations::EmptyStateTest < ComponentTestCase
  setup do
    Current.account = accounts(:one)
  end

  teardown do
    Current.account = nil
  end

  test "renders pre_pipeline variant" do
    html = render_component(Components::Conversations::EmptyState.new(variant: :pre_pipeline))
    assert_includes html, "Welcome to Carrel"
    assert_includes html, "rails credentials:edit"
    assert_includes html, "Sync Library"
  end

  test "renders pre_embedding variant" do
    html = render_component(Components::Conversations::EmptyState.new(variant: :pre_embedding))
    assert_includes html, "Library synced"
    assert_includes html, "not yet indexed"
    assert_includes html, "Run Pipeline"
  end

  test "renders ready variant" do
    html = render_component(Components::Conversations::EmptyState.new(variant: :ready))
    assert_includes html, "Ready to research"
    assert_includes html, "New Conversation"
  end

  test "pre_pipeline variant renders button_to for POST action" do
    html = render_component(Components::Conversations::EmptyState.new(variant: :pre_pipeline))
    doc = Nokogiri::HTML::DocumentFragment.parse(html)
    form = doc.css("form").first
    assert_not_nil form, "pre_pipeline variant should render a form (button_to)"
    assert_equal "post", form["method"]
  end

  test "pre_embedding variant renders button_to for POST action" do
    html = render_component(Components::Conversations::EmptyState.new(variant: :pre_embedding))
    doc = Nokogiri::HTML::DocumentFragment.parse(html)
    form = doc.css("form").first
    assert_not_nil form, "pre_embedding variant should render a form (button_to)"
    assert_equal "post", form["method"]
  end

  test "ready variant renders anchor link" do
    html = render_component(Components::Conversations::EmptyState.new(variant: :ready))
    doc = Nokogiri::HTML::DocumentFragment.parse(html)
    link = doc.css("a.ui-button").first
    assert_not_nil link, "ready variant should render an anchor link"
    assert_includes link["href"], "/conversations/new"
  end

  test "defaults to pre_pipeline variant" do
    html = render_component(Components::Conversations::EmptyState.new)
    assert_includes html, "Welcome to Carrel"
  end
end
