# frozen_string_literal: true

require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:regular_user)
  end

  # Feature flag tests
  test "returns 404 when notifications feature is disabled" do
    with_config(features: { notifications: false }) do
      sign_in_as @user
      get notifications_url
      assert_response :not_found
    end
  end

  # Authentication tests
  test "index requires authentication" do
    with_config(features: { notifications: true }) do
      get notifications_url
      assert_redirected_to sign_in_url
    end
  end

  test "mark_all_read requires authentication" do
    with_config(features: { notifications: true }) do
      post mark_all_read_notifications_url
      assert_redirected_to sign_in_url
    end
  end

  # Index tests
  test "should get index" do
    with_config(features: { notifications: true }) do
      sign_in_as @user
      get notifications_url
      assert_response :success
    end
  end

  test "index shows user notifications" do
    with_config(features: { notifications: true }) do
      sign_in_as @user

      # Create a notification for this user
      event = Noticed::Event.create!(type: "WelcomeNotifier", params: { message: "Test notification" })
      notification = Noticed::Notification.create!(
        event: event,
        recipient: @user,
        type: "Noticed::Notification"
      )

      get notifications_url
      assert_response :success
    end
  end

  # Show tests
  test "show requires authentication" do
    with_config(features: { notifications: true }) do
      event = Noticed::Event.create!(type: "WelcomeNotifier", params: { message: "Test" })
      notification = Noticed::Notification.create!(
        event: event,
        recipient: @user,
        type: "Noticed::Notification"
      )

      get notification_url(notification)
      assert_redirected_to sign_in_url
    end
  end

  test "show marks notification as read and redirects" do
    with_config(features: { notifications: true }) do
      sign_in_as @user

      event = Noticed::Event.create!(type: "WelcomeNotifier", params: { message: "Test" })
      notification = Noticed::Notification.create!(
        event: event,
        recipient: @user,
        type: "Noticed::Notification"
      )

      assert_nil notification.read_at

      get notification_url(notification)
      assert_response :redirect

      notification.reload
      assert_not_nil notification.read_at
    end
  end

  test "show redirects to notification URL when present" do
    with_config(features: { notifications: true }) do
      sign_in_as @user

      event = Noticed::Event.create!(
        type: "WelcomeNotifier",
        params: { message: "Test", url: "/custom-path" }
      )
      notification = Noticed::Notification.create!(
        event: event,
        recipient: @user,
        type: "Noticed::Notification"
      )

      get notification_url(notification)
      assert_redirected_to "/custom-path"
    end
  end

  test "show redirects to notifications index when no URL present" do
    with_config(features: { notifications: true }) do
      sign_in_as @user

      event = Noticed::Event.create!(type: "WelcomeNotifier", params: { message: "Test" })
      notification = Noticed::Notification.create!(
        event: event,
        recipient: @user,
        type: "Noticed::Notification"
      )

      get notification_url(notification)
      assert_redirected_to notifications_path
    end
  end

  test "show returns 404 for other user's notification" do
    with_config(features: { notifications: true }) do
      other_user = users(:app_admin)
      sign_in_as @user

      event = Noticed::Event.create!(type: "WelcomeNotifier", params: { message: "Test" })
      notification = Noticed::Notification.create!(
        event: event,
        recipient: other_user,
        type: "Noticed::Notification"
      )

      get notification_url(notification)
      assert_response :not_found
    end
  end

  # Mark read tests
  test "mark_read marks single notification as read" do
    with_config(features: { notifications: true }) do
      sign_in_as @user

      event = Noticed::Event.create!(type: "WelcomeNotifier", params: { message: "Test" })
      notification = Noticed::Notification.create!(
        event: event,
        recipient: @user,
        type: "Noticed::Notification"
      )

      assert_nil notification.read_at

      post mark_read_notification_url(notification)
      assert_response :redirect

      notification.reload
      assert_not_nil notification.read_at
    end
  end

  # Mark all read tests
  test "mark_all_read marks all notifications as read" do
    with_config(features: { notifications: true }) do
      sign_in_as @user

      # Create multiple notifications
      3.times do |i|
        event = Noticed::Event.create!(type: "WelcomeNotifier", params: { message: "Test #{i}" })
        Noticed::Notification.create!(
          event: event,
          recipient: @user,
          type: "Noticed::Notification"
        )
      end

      assert_equal 3, @user.unread_notifications_count

      post mark_all_read_notifications_url
      assert_redirected_to notifications_path
      assert_equal "All notifications marked as read", flash[:notice]

      assert_equal 0, @user.unread_notifications_count
    end
  end

  test "mark_all_read responds to turbo_stream" do
    with_config(features: { notifications: true }) do
      sign_in_as @user

      event = Noticed::Event.create!(type: "WelcomeNotifier", params: { message: "Test" })
      Noticed::Notification.create!(
        event: event,
        recipient: @user,
        type: "Noticed::Notification"
      )

      post mark_all_read_notifications_url, as: :turbo_stream
      assert_response :ok
    end
  end
end
