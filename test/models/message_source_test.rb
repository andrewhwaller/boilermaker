# frozen_string_literal: true

require "test_helper"

class MessageSourceTest < ActiveSupport::TestCase
  setup do
    Current.account = accounts(:one)
  end

  teardown do
    Current.account = nil
  end

  test "requires message" do
    source = MessageSource.new(document_chunk: document_chunks(:one), relevance_score: 0.9)
    assert_not source.valid?
    assert_includes source.errors[:message], "must exist"
  end

  test "requires document_chunk" do
    source = MessageSource.new(message: messages(:assistant_message), relevance_score: 0.9)
    assert_not source.valid?
    assert_includes source.errors[:document_chunk], "must exist"
  end

  test "unique constraint on message and document_chunk" do
    existing = message_sources(:one)
    duplicate = MessageSource.new(
      message: existing.message,
      document_chunk: existing.document_chunk,
      relevance_score: 0.5
    )
    assert_not duplicate.valid?
  end

  test "tracks relevance score" do
    source = message_sources(:one)
    assert_equal 0.92, source.relevance_score.round(2)
  end
end
