# frozen_string_literal: true

require "test_helper"

class Components::Kits::FormKitTest < ActiveSupport::TestCase
  test "provides access to form components" do
    components = Components::Kits::FormKit.components

    assert_equal Components::Button, components[:button]
    assert_equal Components::Input, components[:input]
    assert_equal Components::Label, components[:label]
  end

  test "field convenience method creates FormField component" do
    field = Components::Kits::FormKit.field(
      label_text: "Email",
      input_type: :email,
      required: true,
      name: "user[email]"
    )

    assert_instance_of Components::FormField, field
  end

  test "submit_button convenience method creates Button component" do
    button = Components::Kits::FormKit.submit_button("Save", variant: :secondary)

    assert_instance_of Components::Button, button
  end
end
