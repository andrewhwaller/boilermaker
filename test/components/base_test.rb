# frozen_string_literal: true

require_relative "component_test_case"

class BaseTest < ComponentTestCase
  class TestComponent < Components::Base
    def initialize(**attributes)
      @attributes = attributes
    end

    def view_template
      div(class: css_classes("base-class", "another-class"), **filtered_attributes(:custom_param)) do
        "test content"
      end
    end

    # Expose protected methods for testing
    def test_filtered_attributes(*exclude_keys)
      filtered_attributes(*exclude_keys)
    end

    def test_css_classes(*class_arrays)
      css_classes(*class_arrays)
    end
  end

  # Test filtered_attributes method
  test "filtered_attributes excludes specified keys and class" do
    attributes = { class: "custom-class", data: { test: "value" }, custom_param: "exclude_me", other: "keep" }
    component = TestComponent.new(**attributes)

    result = component.test_filtered_attributes(:custom_param)

    assert_equal({ data: { test: "value" }, other: "keep" }, result)
    refute_includes result.keys, :class
    refute_includes result.keys, :custom_param
  end

  test "filtered_attributes with no exclusions still excludes class" do
    attributes = { class: "custom-class", data: { test: "value" }, other: "keep" }
    component = TestComponent.new(**attributes)

    result = component.test_filtered_attributes

    assert_equal({ data: { test: "value" }, other: "keep" }, result)
    refute_includes result.keys, :class
  end

  test "filtered_attributes handles empty attributes" do
    component = TestComponent.new

    result = component.test_filtered_attributes(:custom_param)

    assert_equal({}, result)
  end

  # Test css_classes method
  test "css_classes combines arrays and strings, includes attribute class" do
    attributes = { class: "attr-class" }
    component = TestComponent.new(**attributes)

    result = component.test_css_classes("string-class", ["array", "classes"], nil, "another")

    expected = ["string-class", "array", "classes", "another", "attr-class"]
    assert_equal expected, result
  end

  test "css_classes handles nil values and empty arrays" do
    attributes = { class: "attr-class" }
    component = TestComponent.new(**attributes)

    result = component.test_css_classes(nil, [], "valid-class", nil)

    expected = ["valid-class", "attr-class"]
    assert_equal expected, result
  end

  test "css_classes works without attribute class" do
    component = TestComponent.new

    result = component.test_css_classes("class-one", ["class-two", "class-three"])

    expected = ["class-one", "class-two", "class-three"]
    assert_equal expected, result
  end

  test "css_classes flattens nested arrays" do
    attributes = { class: ["nested", "attr-classes"] }
    component = TestComponent.new(**attributes)

    result = component.test_css_classes("base", [["nested", "array"], "single"])

    expected = ["base", "nested", "array", "single", "nested", "attr-classes"]
    assert_equal expected, result
  end

  # Integration test
  test "component renders with helper methods" do
    attributes = { 
      class: "custom-class", 
      data: { controller: "test" }, 
      custom_param: "should-be-filtered",
      id: "test-id"
    }
    component = TestComponent.new(**attributes)

    html = render_component(component)
    doc = parse_html(html)
    div = doc.css("div").first

    # Should have combined classes
    assert_includes div["class"], "base-class"
    assert_includes div["class"], "another-class"  
    assert_includes div["class"], "custom-class"

    # Should have filtered attributes
    assert_equal "test-id", div["id"]
    assert_equal "test", div["data-controller"]

    # Should not have filtered custom_param
    refute div.attributes.key?("custom_param")
    refute div.attributes.key?("custom-param")

    # Content should render
    assert_equal "test content", div.text.strip
  end

  # Test generate_id_from_name (existing method)
  test "generate_id_from_name handles brackets and underscores" do
    component = TestComponent.new
    
    assert_equal "user_name", component.send(:generate_id_from_name, "user[name]")
    assert_equal "user_address_street", component.send(:generate_id_from_name, "user[address][street]")
    assert_equal "simple_name", component.send(:generate_id_from_name, "simple_name")
    assert_equal "trailing_underscore", component.send(:generate_id_from_name, "trailing_underscore_")
    assert_equal "multiple_underscores", component.send(:generate_id_from_name, "multiple___underscores")
  end
end