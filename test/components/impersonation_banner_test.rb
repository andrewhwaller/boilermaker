# frozen_string_literal: true

require_relative "component_test_case"
require_relative "test_helpers"

class ImpersonationBannerTest < ComponentTestCase
  include ComponentTestHelpers

  setup do
    @original_session = Current.session
  end

  teardown do
    Current.session = @original_session
  end

  test "renders nothing when not impersonating" do
    Current.session = nil
    banner = Components::ImpersonationBanner.new
    assert render_component(banner).blank?

    # Also test with session but no impersonator
    user = users(:regular_user)
    session = user.sessions.create!(ip_address: "127.0.0.1", user_agent: "Test")
    Current.session = session
    assert render_component(Components::ImpersonationBanner.new).blank?
  end

  test "shows impersonated user email and exit option when impersonating" do
    admin = users(:app_admin)
    regular_user = users(:regular_user)

    session = regular_user.sessions.create!(
      ip_address: "127.0.0.1",
      user_agent: "Test",
      impersonator: admin
    )
    Current.session = session

    banner = Components::ImpersonationBanner.new
    html = render_component(banner)

    assert html.include?(regular_user.email)
    assert html.include?("Exit Impersonation")
  end
end
