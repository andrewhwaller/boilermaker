# frozen_string_literal: true

require_relative "component_test_case"
require_relative "test_helpers"

class AvatarTest < ComponentTestCase
  include ComponentTestHelpers

  # Test basic avatar rendering
  test "renders avatar element successfully" do
    avatar = Components::Avatar.new
    
    assert_renders_successfully(avatar)
    
    # Use separate instance to avoid double render
    avatar_output = Components::Avatar.new
    assert_produces_output(avatar_output)
    
    # Check that it renders with avatar div structure
    avatar_div = Components::Avatar.new
    assert_has_tag(avatar_div, "div")
    
    avatar_class = Components::Avatar.new
    assert_has_css_class(avatar_class, "avatar")
  end

  # Test default avatar configuration
  test "renders with default medium size and circle shape" do
    avatar = Components::Avatar.new
    
    # Should have default size and shape classes
    assert_has_css_class(avatar, ["w-12", "rounded-full"])
    
    # Should render default avatar icon when no src or initials
    default_avatar = Components::Avatar.new
    assert_has_tag(default_avatar, "svg")
  end

  # Test avatar with image source
  test "renders avatar with image source correctly" do
    avatar_with_image = Components::Avatar.new(
      src: "https://example.com/avatar.jpg",
      alt: "User Avatar"
    )
    
    # Should contain img element
    assert_has_tag(avatar_with_image, "img")
    
    # Should have correct src and alt attributes using separate instance
    avatar_attrs = Components::Avatar.new(
      src: "https://example.com/avatar.jpg",
      alt: "User Avatar"
    )
    assert_has_attributes(avatar_attrs, "img", {
      src: "https://example.com/avatar.jpg",
      alt: "User Avatar"
    })
  end

  # Test avatar with initials fallback
  test "renders avatar with initials fallback" do
    avatar_with_initials = Components::Avatar.new(initials: "JD")
    
    # Should contain the initials text
    assert_has_text(avatar_with_initials, "JD")
    
    # Should have appropriate background and text colors using separate instance
    avatar_colors = Components::Avatar.new(initials: "JD")
    assert_has_css_class(avatar_colors, ["bg-neutral", "text-neutral-content"])
  end

  # Test all available avatar sizes
  test "renders all avatar sizes correctly" do
    Components::Avatar::SIZES.each do |size, expected_class|
      avatar = Components::Avatar.new(size: size)
      
      assert_has_css_class(avatar, expected_class,
        "Avatar with size #{size} should have class '#{expected_class}'")
    end
  end

  # Test all available avatar shapes
  test "renders all avatar shapes correctly" do
    Components::Avatar::SHAPES.each do |shape, expected_class|
      avatar = Components::Avatar.new(shape: shape)
      
      assert_has_css_class(avatar, expected_class,
        "Avatar with shape #{shape} should have class '#{expected_class}'")
    end
  end

  # Test online status indicator
  test "renders online status indicator correctly" do
    # Online status
    avatar_online = Components::Avatar.new(online: true)
    assert_has_css_class(avatar_online, "online")
    
    # Offline status  
    avatar_offline = Components::Avatar.new(online: false)
    assert_has_css_class(avatar_offline, "offline")
    
    # No status
    avatar_no_status = Components::Avatar.new
    html = render_component(avatar_no_status)
    refute html.include?("online"), "Should not have online class when status not specified"
    refute html.include?("offline"), "Should not have offline class when status not specified"
  end

  # Test placeholder avatar
  test "renders placeholder avatar correctly" do
    placeholder_avatar = Components::Avatar.new(placeholder: true)
    
    # Should have neutral background for placeholder
    assert_has_css_class(placeholder_avatar, "bg-neutral-focus")
  end

  # Test avatar fallback priority
  test "respects avatar content priority correctly" do
    # Image should take priority over initials
    avatar_image_priority = Components::Avatar.new(
      src: "https://example.com/avatar.jpg",
      initials: "JD"
    )
    assert_has_tag(avatar_image_priority, "img")
    # Check using separate instance for HTML inspection
    avatar_image_check = Components::Avatar.new(
      src: "https://example.com/avatar.jpg",
      initials: "JD"
    )
    html = render_component(avatar_image_check)
    refute html.include?("JD"), "Should not show initials when image is provided"
    
    # Initials should take priority over placeholder
    avatar_initials_priority = Components::Avatar.new(
      initials: "JD", 
      placeholder: true
    )
    assert_has_text(avatar_initials_priority, "JD")
    
    avatar_initials_check = Components::Avatar.new(
      initials: "JD", 
      placeholder: true
    )
    html = render_component(avatar_initials_check)
    refute html.include?("bg-neutral-focus"), "Should not show placeholder when initials provided"
    
    # Placeholder should take priority over default
    avatar_placeholder_priority = Components::Avatar.new(placeholder: true)
    html = render_component(avatar_placeholder_priority)
    assert html.include?("bg-neutral-focus"), "Should show placeholder background"
    refute html.include?("<svg"), "Should not show default SVG icon when placeholder is true"
  end

  # Test avatar with custom attributes
  test "renders avatar with custom attributes" do
    avatar = Components::Avatar.new(
      src: "https://example.com/avatar.jpg",
      id: "custom-avatar",
      "data-testid": "avatar-component",
      title: "Custom Avatar"
    )
    
    # Custom attributes should be passed to the img element
    assert_has_attributes(avatar, "img", {
      id: "custom-avatar", 
      "data-testid": "avatar-component",
      title: "Custom Avatar"
    })
  end

  # Test avatar size and shape combinations
  test "renders avatar with size and shape combinations correctly" do
    # Extra large square avatar
    xl_square_avatar = Components::Avatar.new(size: :xl, shape: :square)
    assert_has_css_class(xl_square_avatar, ["w-20", "rounded"])
    
    # Extra small circle avatar
    xs_circle_avatar = Components::Avatar.new(size: :xs, shape: :circle)
    assert_has_css_class(xs_circle_avatar, ["w-6", "rounded-full"])
  end

  # Test default alt text handling
  test "provides default alt text when not specified" do
    avatar_no_alt = Components::Avatar.new(src: "https://example.com/avatar.jpg")
    
    # Should have default alt text
    assert_has_attributes(avatar_no_alt, "img", { alt: "Avatar" })
  end

  # Test edge cases
  test "handles edge cases gracefully" do
    # Empty/nil src should fallback to initials or default
    avatar_empty_src = Components::Avatar.new(src: "", initials: "JD")
    assert_has_text(avatar_empty_src, "JD")
    
    # Empty/nil initials should fallback to default  
    avatar_empty_initials = Components::Avatar.new(initials: "")
    assert_has_tag(avatar_empty_initials, "svg")
    
    # Invalid size should not break rendering
    avatar_invalid_size = Components::Avatar.new(size: :invalid)
    assert_renders_successfully(avatar_invalid_size)
    
    # Invalid shape should not break rendering
    avatar_invalid_shape = Components::Avatar.new(shape: :invalid)
    assert_renders_successfully(avatar_invalid_shape)
  end

  # Test initials styling
  test "styles initials correctly" do
    avatar_with_initials = Components::Avatar.new(initials: "AB")
    
    # Should have appropriate text styling for initials
    html = render_component(avatar_with_initials)
    assert html.include?("text-sm"), "Initials should have small text size"
    assert html.include?("font-medium"), "Initials should have medium font weight"
    assert html.include?("flex items-center justify-center"), "Initials should be centered"
  end

  # Test default SVG icon
  test "renders default SVG icon correctly" do
    default_avatar = Components::Avatar.new
    
    # Should have SVG with proper attributes
    assert_has_tag(default_avatar, "svg")
    
    # Use separate instance for HTML inspection
    default_avatar_check = Components::Avatar.new
    html = render_component(default_avatar_check)
    assert html.include?("viewBox=\"0 0 20 20\""), "SVG should have correct viewBox"
    assert html.include?("fill=\"currentColor\""), "SVG should use currentColor fill"
    assert html.include?("w-1/2 h-1/2"), "SVG should be appropriately sized"
  end

  # Test accessibility
  test "maintains accessibility standards" do
    # Image avatar should have proper alt text
    image_avatar = Components::Avatar.new(src: "test.jpg", alt: "John Doe")
    assert_has_attributes(image_avatar, "img", { alt: "John Doe" })
    
    # Initials should be readable by screen readers
    initials_avatar = Components::Avatar.new(initials: "JD")
    assert_has_text(initials_avatar, "JD")
    
    # Default SVG should have proper aria attributes for screen readers
    default_avatar = Components::Avatar.new
    html = render_component(default_avatar)
    # SVG content should be descriptive for accessibility
    assert html.include?("<path"), "SVG should have path elements for screen readers"
  end

  # Test block content
  test "renders block content correctly" do
    avatar_with_block = Components::Avatar.new do
      "Additional content"
    end
    
    # Block content should be rendered outside the avatar div but inside the container
    assert_has_text(avatar_with_block, "Additional content")
  end
end