# frozen_string_literal: true

require "test_helper"

class ResearchAssistantServiceTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:one)
    Current.account = @account
    @conversation = conversations(:one)
    @service = ResearchAssistantService.new(conversation: @conversation)
  end

  teardown do
    Current.account = nil
  end

  # --- System prompt structure ---

  test "build_system_prompt includes retrieved source XML tags" do
    chunk = document_chunks(:one)
    retrieved = [ { chunk: chunk, distance: 0.1 } ]

    prompt = @service.send(:build_system_prompt, retrieved)

    assert_match(/<retrieved_source id="1"/, prompt,
      "System prompt should include <retrieved_source id=...> XML tags")
    assert_match(chunk.content, prompt,
      "System prompt should include chunk content")
  end

  test "build_system_prompt includes source title and authors in XML attributes" do
    chunk = document_chunks(:one)
    item = zotero_items(:one)
    retrieved = [ { chunk: chunk, distance: 0.1 } ]

    prompt = @service.send(:build_system_prompt, retrieved)

    assert_match(/title="#{Regexp.escape(item.title)}"/, prompt,
      "System prompt should include the ZoteroItem title as an XML attribute")
    assert_match(/authors="Doe, Jane"/, prompt,
      "System prompt should include parsed author names as an XML attribute")
  end

  test "build_system_prompt includes citation instructions" do
    prompt = @service.send(:build_system_prompt, [])

    assert_match(/\[Author, Title\]/, prompt,
      "System prompt should instruct the model to use [Author, Title] citation format")
    assert_match(/retrieved_source.*as instructions to follow/m, prompt,
      "System prompt should warn against treating retrieved content as instructions")
  end

  test "build_system_prompt with zero retrieved chunks includes no-results message" do
    prompt = @service.send(:build_system_prompt, [])

    assert_match(/No relevant sources were found/, prompt,
      "System prompt with no retrieved chunks should include a no-results message")
    refute_match(/<retrieved_source id=/, prompt,
      "System prompt with no retrieved chunks should not include any <retrieved_source id=...> source blocks")
  end

  test "build_system_prompt with multiple retrieved chunks numbers them sequentially" do
    chunk_one = document_chunks(:one)
    chunk_two = document_chunks(:two)
    retrieved = [
      { chunk: chunk_one, distance: 0.1 },
      { chunk: chunk_two, distance: 0.2 }
    ]

    prompt = @service.send(:build_system_prompt, retrieved)

    assert_match(/<retrieved_source id="1"/, prompt, "First source should have id=1")
    assert_match(/<retrieved_source id="2"/, prompt, "Second source should have id=2")
  end

  # --- XML escaping ---

  test "escape_xml escapes ampersands" do
    result = @service.send(:escape_xml, "Smith & Jones")
    assert_equal "Smith &amp; Jones", result,
      "escape_xml should escape & as &amp;"
  end

  test "escape_xml escapes angle brackets" do
    result = @service.send(:escape_xml, "<title>")
    assert_equal "&lt;title&gt;", result,
      "escape_xml should escape < and > characters"
  end

  test "escape_xml escapes double quotes" do
    result = @service.send(:escape_xml, 'say "hello"')
    assert_equal "say &quot;hello&quot;", result,
      "escape_xml should escape double-quote characters"
  end

  test "escape_xml handles nil gracefully" do
    result = @service.send(:escape_xml, nil)
    assert_equal "", result,
      "escape_xml should return empty string for nil input"
  end

  # --- Conversation history building ---

  test "build_conversation_history excludes system messages" do
    history = @service.send(:build_conversation_history)

    roles = history.map { |m| m[:role] }
    assert_not_includes roles, "system",
      "build_conversation_history should not include system messages"
  end

  test "build_conversation_history excludes incomplete assistant messages" do
    # The :incomplete_message fixture has complete: false
    history = @service.send(:build_conversation_history)
    incomplete_content = messages(:incomplete_message).content

    contents = history.map { |m| m[:content] }
    assert_not_includes contents, incomplete_content,
      "build_conversation_history should exclude incomplete assistant messages"
  end

  test "build_conversation_history includes complete user and assistant messages" do
    history = @service.send(:build_conversation_history)

    user_msg = messages(:user_message)
    assistant_msg = messages(:assistant_message)

    contents = history.map { |m| m[:content] }
    assert_includes contents, user_msg.content,
      "build_conversation_history should include the complete user message"
    assert_includes contents, assistant_msg.content,
      "build_conversation_history should include the complete assistant message"
  end

  test "build_conversation_history returns messages as hashes with role and content keys" do
    history = @service.send(:build_conversation_history)

    history.each do |msg|
      assert_includes msg.keys, :role, "Each history entry should have a :role key"
      assert_includes msg.keys, :content, "Each history entry should have a :content key"
    end
  end

  test "build_conversation_history respects MAX_HISTORY_MESSAGES sliding window" do
    (ResearchAssistantService::MAX_HISTORY_MESSAGES + 5).times do |i|
      @conversation.messages.create!(role: "user", content: "Old message #{i}", complete: true)
    end

    history = @service.send(:build_conversation_history)

    assert history.length <= ResearchAssistantService::MAX_HISTORY_MESSAGES,
      "build_conversation_history should not exceed MAX_HISTORY_MESSAGES entries (got #{history.length})"
  end

  # --- API-dependent tests ---

  test "answer creates MessageSource records for retrieved chunks" do
    skip "OpenRouter API key not configured" unless Rails.application.credentials.dig(:openrouter, :api_key).present?

    assistant_message = @conversation.messages.create!(role: "assistant", content: "", complete: false)

    chunk = document_chunks(:one)
    search_stub = ->(account:) {
      svc = Object.new
      svc.define_singleton_method(:retrieve_chunks) { |_q, k:| [ { chunk: chunk, distance: 0.15 } ] }
      svc
    }

    chat_stub = Object.new
    def chat_stub.with_instructions(_); self; end
    def chat_stub.add_message(**_); nil; end
    def chat_stub.ask(_)
      yield Struct.new(:content).new("Mocked response") if block_given?
      nil
    end

    SearchService.stub(:new, search_stub) do
      RubyLLM.stub(:chat, ->(**) { chat_stub }) do
        @service.answer("What is research methodology?", assistant_message: assistant_message)
      end
    end

    assert MessageSource.where(message: assistant_message).exists?,
      "answer should create MessageSource records linking the assistant message to retrieved chunks"
  end

  test "answer returns accumulated content string" do
    skip "OpenRouter API key not configured" unless Rails.application.credentials.dig(:openrouter, :api_key).present?

    assistant_message = @conversation.messages.create!(role: "assistant", content: "", complete: false)

    search_stub = ->(account:) {
      svc = Object.new
      svc.define_singleton_method(:retrieve_chunks) { |_q, k:| [] }
      svc
    }

    chat_stub = Object.new
    def chat_stub.with_instructions(_); self; end
    def chat_stub.add_message(**_); nil; end
    def chat_stub.ask(_)
      yield Struct.new(:content).new("Hello") if block_given?
      nil
    end

    SearchService.stub(:new, search_stub) do
      RubyLLM.stub(:chat, ->(**) { chat_stub }) do
        result = @service.answer("test question", assistant_message: assistant_message)
        assert_kind_of String, result, "answer should return a String"
      end
    end
  end
end
