# frozen_string_literal: true

require_relative "component_test_case"

class InputTest < ComponentTestCase
  test "stores all initialization parameters correctly" do
    input = Components::Input.new(
      type: :email,
      name: :user_email,
      id: "email-field",
      value: "test@example.com",
      placeholder: "Enter email",
      required: true,
      class: "extra-class"
    )

    assert_equal :email, input.instance_variable_get(:@type)
    assert_equal :user_email, input.instance_variable_get(:@name)
    assert_equal "email-field", input.instance_variable_get(:@id)
    assert_equal "test@example.com", input.instance_variable_get(:@value)
    assert_equal "Enter email", input.instance_variable_get(:@placeholder)
    assert input.instance_variable_get(:@required)
    assert_equal({ class: "extra-class" }, input.instance_variable_get(:@attributes))
  end

  test "defaults to text type when not specified" do
    input = Components::Input.new(name: :username)

    assert_equal :text, input.instance_variable_get(:@type)
  end

  test "defaults required to false when not specified" do
    input = Components::Input.new(name: :username)

    refute input.instance_variable_get(:@required)
  end

  test "accepts nil values for optional parameters" do
    input = Components::Input.new(
      name: :username,
      id: nil,
      value: nil,
      placeholder: nil
    )

    assert_nil input.instance_variable_get(:@id)
    assert_nil input.instance_variable_get(:@value)
    assert_nil input.instance_variable_get(:@placeholder)
  end

  test "handles various input types" do
    input_types = [ :text, :email, :password, :number, :tel, :url, :search, :date ]

    input_types.each do |type|
      input = Components::Input.new(type: type, name: :field)
      assert_equal type, input.instance_variable_get(:@type)
    end
  end
end
