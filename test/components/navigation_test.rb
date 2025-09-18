# frozen_string_literal: true

require_relative "component_test_case"
require_relative "test_helpers"

class NavigationTest < ComponentTestCase
  include ComponentTestHelpers

  test "renders successfully" do
    navigation = Components::Navigation.new
    assert_renders_successfully(navigation)
    assert_has_tag(navigation, "nav")
  end

  test "shows sign in link when not authenticated" do
    with_current_user(nil) do
      navigation = Components::Navigation.new
      doc = render_and_parse(navigation)

      sign_in_links = doc.css('a[href*="sign_in"]')
      assert sign_in_links.any?, "Should have sign in link"
    end
  end

  test "shows dashboard link when authenticated" do
    with_current_user(email: "test@example.com") do
      navigation = Components::Navigation.new
      doc = render_and_parse(navigation)

      dashboard_links = doc.css('a[href="/"]')
      assert dashboard_links.any?, "Should have dashboard link"
    end
  end

  test "shows admin link for admin users" do
    with_current_user(email: "admin@example.com", admin?: true) do
      navigation = Components::Navigation.new
      html = render_component(navigation)

      assert html.include?("Admin"), "Should show admin link"
    end
  end

  test "shows account link for account admins" do
    with_current_user(email: "admin@example.com", account_admin_for?: true) do
      navigation = Components::Navigation.new
      html = render_component(navigation)

      assert html.include?("Account"), "Should show account link"
    end
  end

  test "includes branding when configured" do
    navigation = Components::Navigation.new
    html = render_component(navigation)

    # Should have branding with app name if show_branding? is true
    if navigation.send(:show_branding?)
      assert html.include?(navigation.send(:app_name)), "Should show app name in branding"
    end
  end

  test "includes theme toggle" do
    navigation = Components::Navigation.new
    html = render_component(navigation)

    # Should have theme toggle control
    assert html.include?('role="switch"') || html.include?('data-theme-target="button"'),
      "Should include theme toggle"
  end
end
