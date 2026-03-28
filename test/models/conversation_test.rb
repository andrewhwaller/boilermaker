# frozen_string_literal: true

require "test_helper"

class ConversationTest < ActiveSupport::TestCase
  setup do
    Current.account = accounts(:one)
  end

  teardown do
    Current.account = nil
  end

  test "requires account" do
    convo = Conversation.new(title: "Test", account: nil)
    assert_not convo.valid?
    assert_includes convo.errors[:account], "must exist"
  end

  test "requires title" do
    convo = Conversation.new(account: accounts(:one))
    assert_not convo.valid?
    assert_includes convo.errors[:title], "can't be blank"
  end

  test "scoped to current account" do
    convos = Conversation.all
    assert convos.all? { |c| c.account_id == accounts(:one).id }
  end

  test "has many messages with dependent destroy" do
    convo = conversations(:one)
    assert convo.messages.any?
    message_ids = convo.messages.pluck(:id)

    convo.destroy!
    assert_empty Message.unscoped.where(id: message_ids)
  end
end
