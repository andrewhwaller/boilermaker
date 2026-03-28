# frozen_string_literal: true

require "test_helper"

class ConversationChannelTest < ActionCable::Channel::TestCase
  # app_admin owns account :one, which has conversations :one and :two
  # regular_user owns account :three (no conversations) and is a member of account :two

  test "authenticated user can subscribe to their own conversation" do
    user = users(:app_admin)
    conversation = conversations(:one) # belongs to account :one, owned by app_admin

    stub_connection current_user: user

    subscribe conversation_id: conversation.id

    assert subscription.confirmed?,
      "Subscription should be confirmed when the user owns the conversation's account"
    assert_has_stream "conversation_#{conversation.id}"
  end

  test "subscription is rejected when conversation belongs to a different account" do
    user = users(:regular_user)
    # regular_user is not a member of account :one
    conversation = conversations(:one) # belongs to account :one

    stub_connection current_user: user

    subscribe conversation_id: conversation.id

    assert subscription.rejected?,
      "Subscription should be rejected when the conversation does not belong to the user's account"
  end

  test "subscription is rejected for a non-existent conversation id" do
    user = users(:app_admin)

    stub_connection current_user: user

    subscribe conversation_id: 999_999_999

    assert subscription.rejected?,
      "Subscription should be rejected when the conversation does not exist"
  end

  test "subscription streams from the correct channel name" do
    user = users(:app_admin)
    conversation = conversations(:two) # also belongs to account :one

    stub_connection current_user: user

    subscribe conversation_id: conversation.id

    assert_has_stream "conversation_#{conversation.id}"
  end

  test "user with access to multiple accounts can subscribe to any of their conversations" do
    # app_admin belongs to account :one and account :two
    user = users(:app_admin)
    conversation = conversations(:one)

    stub_connection current_user: user

    subscribe conversation_id: conversation.id

    assert subscription.confirmed?,
      "User with multiple account memberships should be able to subscribe to any of their conversations"
  end
end
