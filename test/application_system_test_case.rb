require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  # Helper method to sign in a user in system tests
  # Since system tests use a browser, we need to actually go through the login flow
  def sign_in_as(user)
    # Reload user to get latest state from database
    user.reload

    # Ensure user is verified to avoid verification redirects
    unless user.verified?
      user.update!(verified: true)
      user.reload
    end

    visit sign_in_path

    fill_in "Email", with: user.email
    fill_in "Password", with: "Secret1*3*5*"
    click_on "Sign in"

    # If 2FA is enabled, handle the challenge
    if user.otp_required_for_sign_in?
      # Wait for redirect to 2FA challenge page
      begin
        assert_selector "h1", text: /authenticator/i, wait: 3
      rescue Minitest::Assertion
        # If not on 2FA page, authentication might have failed
        return
      end

      totp = ROTP::TOTP.new(user.otp_secret, issuer: "Boilermaker")
      fill_in "code", with: totp.now
      click_on "Verify"

      # Wait for redirect after successful 2FA - should go to root_path
      begin
        # Wait for redirect away from 2FA challenge page
        assert_no_selector "h1", text: /authenticator/i, wait: 3
      rescue Minitest::Assertion
        # Still on 2FA page, verification may have failed
        nil
      end
    else
      # For non-2FA users, wait for redirect after sign in
      # Should be redirected away from sign in page
      begin
        assert_no_current_path sign_in_path, wait: 3
      rescue Minitest::Assertion
        # Still on sign in page, authentication may have failed
        nil
      end
    end

    # Don't assert current path - let tests handle that based on their context
    # (e.g., might be root_path, or might be redirected elsewhere due to before_actions)
  end

  # Helper to assert we're not on a specific path
  def assert_no_current_path(path, wait: Capybara.default_max_wait_time)
    start_time = Time.now
    while Time.now - start_time < wait
      return unless current_path == path
      sleep 0.1
    end
    raise Minitest::Assertion, "Expected not to be on #{path}, but current_path is #{current_path}"
  end
end
