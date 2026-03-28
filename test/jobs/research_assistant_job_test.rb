# frozen_string_literal: true

require "test_helper"

class ResearchAssistantJobTest < ActiveSupport::TestCase
  setup do
    Current.account = accounts(:one)
    @conversation = conversations(:one)
  end

  teardown do
    Current.account = nil
  end

  test "job is enqueued on the default queue" do
    assert_equal "default", ResearchAssistantJob.queue_name,
      "ResearchAssistantJob should be on the default queue"
  end

  test "perform creates an assistant message with complete: false before calling the service" do
    service_called = false

    stub_service = ->(conversation:) {
      svc = Object.new
      svc.define_singleton_method(:answer) do |_content, assistant_message:, &_block|
        service_called = true
        # Verify the message was created with complete: false
        assert_equal false, assistant_message.complete,
          "assistant_message should start with complete: false"
        assert_equal "assistant", assistant_message.role,
          "assistant_message should have role 'assistant'"
        ""
      end
      svc
    }

    ResearchAssistantService.stub(:new, stub_service) do
      ResearchAssistantJob.new.perform(@conversation, "What is methodology?")
    end

    assert service_called, "ResearchAssistantService#answer should have been called"
  end

  test "perform creates a new assistant message belonging to the conversation" do
    before_count = @conversation.messages.where(role: "assistant").count

    stub_service = ->(conversation:) {
      svc = Object.new
      svc.define_singleton_method(:answer) { |_content, assistant_message:, &_block| "" }
      svc
    }

    ResearchAssistantService.stub(:new, stub_service) do
      ResearchAssistantJob.new.perform(@conversation, "test question")
    end

    after_count = @conversation.messages.where(role: "assistant").count
    assert_equal before_count + 1, after_count,
      "perform should create exactly one new assistant message"
  end

  test "perform marks the assistant message complete after the service returns" do
    created_message_id = nil

    stub_service = ->(conversation:) {
      svc = Object.new
      svc.define_singleton_method(:answer) do |_content, assistant_message:, &_block|
        created_message_id = assistant_message.id
        assistant_message.update!(content: "Final answer", complete: true)
        "Final answer"
      end
      svc
    }

    ResearchAssistantService.stub(:new, stub_service) do
      ResearchAssistantJob.new.perform(@conversation, "test question")
    end

    msg = Message.find(created_message_id)
    assert msg.complete?,
      "The assistant message should be marked complete after perform finishes"
  end

  test "perform handles errors by appending error text and marking message complete" do
    created_message_id = nil

    stub_service = ->(conversation:) {
      svc = Object.new
      svc.define_singleton_method(:answer) do |_content, assistant_message:, &_block|
        created_message_id = assistant_message.id
        raise "LLM connection failed"
      end
      svc
    }

    Turbo::StreamsChannel.stub(:broadcast_update_to, ->(*_args, **_kwargs) { nil }) do
      ResearchAssistantService.stub(:new, stub_service) do
        ResearchAssistantJob.new.perform(@conversation, "test question")
      end
    end

    msg = Message.find(created_message_id)
    assert msg.complete?,
      "The assistant message should be marked complete even when an error occurs"
    assert_match(/Error: LLM connection failed/, msg.content,
      "The error message text should be appended to the assistant message content")
  end

  test "perform broadcasts error state via Turbo Streams when an error occurs" do
    broadcasts = []

    Turbo::StreamsChannel.stub(:broadcast_update_to, ->(*args, **kwargs) {
      broadcasts << { args: args, kwargs: kwargs }
    }) do
      stub_service = ->(conversation:) {
        svc = Object.new
        svc.define_singleton_method(:answer) do |_content, assistant_message:, &_block|
          raise "Network timeout"
        end
        svc
      }

      ResearchAssistantService.stub(:new, stub_service) do
        ResearchAssistantJob.new.perform(@conversation, "test question")
      end
    end

    assert_equal 1, broadcasts.length,
      "perform should broadcast exactly once when handling an error (the error broadcast)"
    stream_name = broadcasts.first[:args].first
    assert_match(/^conversation_/, stream_name,
      "Turbo broadcast stream name should start with 'conversation_'")
  end

  test "perform passes the conversation to ResearchAssistantService" do
    received_conversation = nil

    stub_service = ->(conversation:) {
      received_conversation = conversation
      svc = Object.new
      svc.define_singleton_method(:answer) { |_content, assistant_message:, &_block| "" }
      svc
    }

    ResearchAssistantService.stub(:new, stub_service) do
      ResearchAssistantJob.new.perform(@conversation, "test question")
    end

    assert_equal @conversation, received_conversation,
      "perform should pass the conversation to ResearchAssistantService"
  end
end
