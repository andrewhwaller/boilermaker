# frozen_string_literal: true

require "test_helper"

class MessageTest < ActiveSupport::TestCase
  setup do
    Current.account = accounts(:one)
  end

  teardown do
    Current.account = nil
  end

  test "requires role" do
    msg = Message.new(conversation: conversations(:one), content: "test")
    assert_not msg.valid?
    assert_includes msg.errors[:role], "can't be blank"
  end

  test "role must be system, user, or assistant" do
    msg = Message.new(conversation: conversations(:one), role: "invalid")
    assert_not msg.valid?
    assert_includes msg.errors[:role], "is not included in the list"
  end

  test "valid roles accepted" do
    %w[system user assistant].each do |role|
      msg = Message.new(conversation: conversations(:one), role: role, content: "test")
      assert msg.valid?, "Role '#{role}' should be valid"
    end
  end

  test "complete defaults to false" do
    msg = Message.create!(conversation: conversations(:one), role: "assistant", content: "test")
    assert_not msg.complete?, "New messages should default to incomplete"
  end

  test "complete! marks message as complete" do
    msg = messages(:incomplete_message)
    assert_not msg.complete?
    msg.complete!
    assert msg.reload.complete?
  end

  test "default scope orders by created_at" do
    convo = conversations(:one)
    messages = convo.messages
    assert_equal messages.map(&:created_at), messages.map(&:created_at).sort
  end

  test "has many message_sources with dependent destroy" do
    msg = messages(:assistant_message)
    assert msg.message_sources.any?
    source_ids = msg.message_sources.pluck(:id)

    msg.destroy!
    assert_empty MessageSource.where(id: source_ids)
  end
end
