# frozen_string_literal: true

require_relative "component_test_case"
require_relative "test_helpers"

class LogWindowTest < ComponentTestCase
  include ComponentTestHelpers

  test "renders successfully" do
    window = Components::LogWindow.new

    assert_renders_successfully(window)
    assert_produces_output(window)
  end

  test "renders with entries" do
    entries = [
      { time: "14:32:01", type: "INFO", message: "Test message" }
    ]
    window = Components::LogWindow.new(entries: entries)

    assert_renders_successfully(window)
  end

  test "renders timestamp in brackets" do
    entries = [
      { time: "14:32:01", type: "INFO", message: "Test" }
    ]
    window = Components::LogWindow.new(entries: entries)

    assert_has_text(window, "[14:32:01]")
  end

  test "renders type badge in brackets" do
    entries = [
      { time: "10:00:00", type: "ERROR", message: "Test" }
    ]
    window = Components::LogWindow.new(entries: entries)

    assert_has_text(window, "[ERROR]")
  end

  test "renders message content" do
    entries = [
      { time: "10:00:00", type: "INFO", message: "System initialized" }
    ]
    window = Components::LogWindow.new(entries: entries)

    assert_has_text(window, "System initialized")
  end

  test "applies monospace font" do
    window = Components::LogWindow.new

    assert_has_css_class(window, "font-mono")
  end

  test "applies text-xs for small text" do
    window = Components::LogWindow.new

    assert_has_css_class(window, "text-xs")
  end

  test "applies semi-transparent background" do
    window = Components::LogWindow.new

    html = render_component(window)
    assert html.include?("bg-surface-alt/50"), "Should have bg-surface-alt/50"
  end

  test "applies overflow-y-auto for scrolling" do
    window = Components::LogWindow.new

    assert_has_css_class(window, "overflow-y-auto")
  end

  test "applies default height of 120px" do
    window = Components::LogWindow.new

    html = render_component(window)
    assert html.include?('style="height: 120px"'), "Should have default height"
  end

  test "accepts custom height" do
    window = Components::LogWindow.new(height: "200px")

    html = render_component(window)
    assert html.include?('style="height: 200px"'), "Should have custom height"
  end

  test "renders multiple entries" do
    entries = [
      { time: "14:30:00", type: "INFO", message: "First message" },
      { time: "14:31:00", type: "WARN", message: "Second message" },
      { time: "14:32:00", type: "ERROR", message: "Third message" }
    ]
    window = Components::LogWindow.new(entries: entries)

    html = render_component(window)

    assert html.include?("First message"), "Should render first entry"
    assert html.include?("Second message"), "Should render second entry"
    assert html.include?("Third message"), "Should render third entry"
  end

  test "timestamp has muted text color" do
    entries = [{ time: "10:00:00", type: "INFO", message: "Test" }]
    window = Components::LogWindow.new(entries: entries)

    doc = render_and_parse(window)
    time_span = doc.css("span.text-muted").first

    assert time_span, "Should have span with text-muted class"
    assert_equal "[10:00:00]", time_span.text
  end

  test "type badge has accent text color" do
    entries = [{ time: "10:00:00", type: "SYNC", message: "Test" }]
    window = Components::LogWindow.new(entries: entries)

    doc = render_and_parse(window)
    type_span = doc.css("span.text-accent").first

    assert type_span, "Should have span with text-accent class"
    assert_equal "[SYNC]", type_span.text
  end

  test "message has body text color" do
    entries = [{ time: "10:00:00", type: "INFO", message: "Hello world" }]
    window = Components::LogWindow.new(entries: entries)

    doc = render_and_parse(window)
    message_span = doc.css("span.text-body").first

    assert message_span, "Should have span with text-body class"
    assert_equal "Hello world", message_span.text
  end

  test "accepts Entry data objects" do
    entry = Components::LogWindow::Entry.new(
      time: "12:00:00",
      type: "DEBUG",
      message: "Debug message"
    )
    window = Components::LogWindow.new(entries: [entry])

    html = render_component(window)

    assert html.include?("[12:00:00]"), "Should render Entry time"
    assert html.include?("[DEBUG]"), "Should render Entry type"
    assert html.include?("Debug message"), "Should render Entry message"
  end

  test "renders empty state when no entries" do
    window = Components::LogWindow.new(entries: [])

    assert_has_text(window, "No log entries")
  end

  test "empty state has muted italic styling" do
    window = Components::LogWindow.new(entries: [])

    doc = render_and_parse(window)
    empty_div = doc.css("div.text-muted.italic").first

    assert empty_div, "Should have empty state with muted italic styling"
  end

  test "accepts custom attributes" do
    window = Components::LogWindow.new(
      id: "system-log",
      "data-testid": "log-window"
    )

    assert_has_attributes(window, "div", {
      id: "system-log",
      "data-testid" => "log-window"
    })
  end

  test "entries have margin bottom for spacing" do
    entries = [{ time: "10:00:00", type: "INFO", message: "Test" }]
    window = Components::LogWindow.new(entries: entries)

    html = render_component(window)
    assert html.include?("mb-0.5"), "Should have mb-0.5 spacing"
  end

  test "elements have margin left for spacing" do
    entries = [{ time: "10:00:00", type: "INFO", message: "Test" }]
    window = Components::LogWindow.new(entries: entries)

    html = render_component(window)
    assert html.include?("ml-2"), "Should have ml-2 spacing"
  end
end
