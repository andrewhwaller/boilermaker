# frozen_string_literal: true

require_relative "component_test_case"
require_relative "test_helpers"

class LinkTest < ComponentTestCase
  include ComponentTestHelpers

  # Test basic link rendering
  test "renders anchor element successfully" do
    link = Components::Link.new(href: "/test", text: "Test Link")

    assert_renders_successfully(link)

    # Use separate instance to avoid double render
    link_output = Components::Link.new(href: "/test", text: "Test Link")
    assert_produces_output(link_output)

    link_tag = Components::Link.new(href: "/test", text: "Test Link")
    assert_has_tag(link_tag, "a")
  end

  # Test default link configuration
  test "renders with default variant styling" do
    link = Components::Link.new(href: "/test", text: "Test Link")

    # Should have default variant classes
    assert_has_css_class(link, [ "link" ]) # Removed "link-hover"

    # Create new instance for attributes test
    link_attrs = Components::Link.new(href: "/test", text: "Test Link")
    assert_has_attributes(link_attrs, "a", { href: "/test" })
  end

  # Test all available link variants from VARIANTS constant
  test "renders all link variants correctly" do
    # Note: `VARIANTS` now has `default: ""` so it will not assert "link" twice
    Components::Link::VARIANTS.except(:default).each do |variant, expected_classes| # Exclude :default for specific check
      # Use separate instances for each assertion to avoid double rendering
      link_base = Components::Link.new(href: "/test", text: "Test Link", variant: variant)

      # Check each expected class individually
      expected_classes.split(" ").each do |expected_class|
        link_variant = Components::Link.new(href: "/test", text: "Test Link", variant: variant)
        assert_has_css_class(link_variant, expected_class,
          "Link with variant #{variant} should have class '#{expected_class}'")
      end
    end

    # Specific check for default variant
    assert_has_css_class(Components::Link.new(href: "/test", text: "Test Link", variant: :default), "link", "Default variant should have base 'link' class")
  end

  # Test each variant individually with detailed assertions
  test "default variant has correct styling" do
    link = Components::Link.new(href: "/test", text: "Test Link", variant: :default)
    assert_has_css_class(link, [ "link" ]) # Removed "link-hover"

    # Should not have other variant-specific classes
    link_check = Components::Link.new(href: "/test", text: "Test Link", variant: :default)
    assert_no_css_class(link_check, [ "link-primary", "link-secondary", "btn-link" ])
  end

  test "primary variant has correct styling" do
    link = Components::Link.new(href: "/test", text: "Test Link", variant: :primary)
    assert_has_css_class(link, [ "link", "link-primary" ]) # Removed "link-hover"

    link_check = Components::Link.new(href: "/test", text: "Test Link", variant: :primary)
    assert_no_css_class(link_check, [ "link-secondary", "link-error", "btn-link" ])
  end

  test "secondary variant has correct styling" do
    link = Components::Link.new(href: "/test", text: "Test Link", variant: :secondary)
    assert_has_css_class(link, [ "link", "link-secondary" ]) # Removed "link-hover"

    link_check = Components::Link.new(href: "/test", text: "Test Link", variant: :secondary)
    assert_no_css_class(link_check, [ "link-primary", "link-error", "btn-link" ])
  end

  test "button variant has correct styling" do
    link = Components::Link.new(href: "/test", text: "Test Link", variant: :button)
    assert_has_css_class(link, [ "ui-button" ])

    link_check = Components::Link.new(href: "/test", text: "Test Link", variant: :button)
    assert_no_css_class(link_check, [ "link", "link-primary", "link-secondary", "link-hover", "btn-link" ]) # Removed "link-hover"
  end

  # Test link content rendering
  test "renders link text content" do
    link = Components::Link.new(href: "/test", text: "Click Me")
    assert_has_text(link, "Click Me")
  end

  test "falls back to href when no text provided" do
    link = Components::Link.new(href: "/test-path")
    assert_has_text(link, "/test-path")
  end

  test "renders block content when provided" do
    # Test that the link can accept block content
    link = Components::Link.new(href: "/test") do
      "Custom Content"
    end
    html = render_component(link)

    # Should contain the block content
    assert html.include?("Custom Content"), "Should render block content"
  end

  test "applies casing transform when specified" do
    uppercase_link = Components::Link.new(href: "/test", text: "Upper", uppercase: true)
    assert_has_css_class(uppercase_link, "uppercase")

    normal_case_link = Components::Link.new(href: "/test", text: "Upper", uppercase: false)
    assert_has_css_class(normal_case_link, "normal-case")
  end

  # Test Rails routing integration
  test "works with Rails path helpers" do
    # Simulate Rails path - would typically be root_path, etc.
    link = Components::Link.new(href: "/", text: "Home")
    assert_has_attributes(link, "a", { href: "/" })
  end

  test "handles URL parameters correctly" do
    link = Components::Link.new(href: "/search?q=ruby", text: "Search")
    assert_has_attributes(link, "a", { href: "/search?q=ruby" })
  end

  # Test external link detection and handling
  test "does not add external attributes to internal links" do
    link = Components::Link.new(href: "/internal", text: "Internal")

    doc = render_and_parse(link)
    a_element = doc.css("a").first

    assert_nil a_element["target"], "Internal link should not have target attribute"
    assert_nil a_element["rel"], "Internal link should not have rel attribute"
  end

  test "respects explicit target and rel attributes for external links" do
    link = Components::Link.new(href: "https://example.com", text: "External",
                               target: "_self", rel: "nofollow")

    assert_has_attributes(link, "a", {
      target: "_self",
      rel: "nofollow"
    })
  end

  # Test custom HTML attributes
  test "accepts custom HTML attributes" do
    link = Components::Link.new(href: "/test", text: "Test",
      id: "custom-link",
      class: "extra-class",
      data: { testid: "nav-link" },
      title: "Tooltip"
    )

    doc = render_and_parse(link)
    a_element = doc.css("a").first

    assert_equal "custom-link", a_element["id"]
    assert_includes a_element["class"], "extra-class"
    assert_equal "nav-link", a_element["data-testid"]
    assert_equal "Tooltip", a_element["title"]
  end

  test "merges custom classes with variant classes" do
    link = Components::Link.new(href: "/test", text: "Test",
      variant: :primary,
      class: "custom-class"
    )

    doc = render_and_parse(link)
    a_element = doc.css("a").first
    classes = a_element["class"].split(" ")

    # Should have both variant and custom classes
    assert_includes classes, "link"
    assert_includes classes, "link-primary"
    assert_includes classes, "custom-class" # Removed "link-hover"
  end

  # Test edge cases and error conditions
  test "handles invalid variant gracefully" do
    # Invalid variant should fall back to default
    link = Components::Link.new(href: "/test", text: "Test", variant: :invalid)

    assert_renders_successfully(link)

    # Should have default styling
    link_check = Components::Link.new(href: "/test", text: "Test", variant: :invalid)
    assert_has_css_class(link_check, [ "link" ]) # Removed "link-hover"
  end

  test "handles nil variant" do
    link = Components::Link.new(href: "/test", text: "Test", variant: nil)

    assert_renders_successfully(link)

    link_check = Components::Link.new(href: "/test", text: "Test", variant: nil)
    assert_has_css_class(link_check, [ "link" ]) # Removed "link-hover"
  end

  test "handles nil href" do
    link = Components::Link.new(href: nil, text: "Test")

    assert_renders_successfully(link)

    link_check = Components::Link.new(href: nil, text: "Test")
    assert_has_attributes(link_check, "a", { href: "" })
  end

  test "handles empty text" do
    link = Components::Link.new(href: "/test", text: "")

    assert_renders_successfully(link)
    # Should fall back to href when text is empty
    link_check = Components::Link.new(href: "/test", text: "")
    assert_has_text(link_check, "/test")
  end

  # Test attribute combinations
  test "handles multiple attribute combinations" do
    attribute_combinations = [
      { variant: :primary, id: "primary-link", external: false },
      { variant: :secondary, class: "nav-item", data: { role: "navigation" } },
      { variant: :error, external: true, title: "Error link" },
      { variant: :button, disabled: true },
      { variant: :info, target: "_parent" }
    ]

    attribute_combinations.each do |attrs|
      # Basic rendering test
      link = Components::Link.new(href: "/test", text: "Test Link", **attrs)
      assert_renders_successfully(link)

      # Verify variant styling
      expected_variant_classes = Components::Link::VARIANTS[attrs[:variant]]
      if expected_variant_classes
        expected_classes = (attrs[:variant] == :button ? ["ui-button"] : ["link"]) # Check for base "link" or "ui-button"
        expected_classes << expected_variant_classes if attrs[:variant] != :default && attrs[:variant] != :button # Add specific variant if not default or button
        expected_classes.flatten!

        link_variant = Components::Link.new(href: "/test", text: "Test Link", **attrs)
        assert_has_css_class(link_variant, expected_classes)
      end
    end
  end

  # Test URL detection logic
  test "correctly identifies internal URLs" do
    internal_urls = [
      "/home",
      "/users/abc123",
      "/search?q=test",
      "#anchor",
      "mailto:test@example.com",
      "tel:+1234567890"
    ]

    internal_urls.each do |url|
      link = Components::Link.new(href: url, text: "Internal")
      doc = render_and_parse(link)
      a_element = doc.css("a").first

      assert_nil a_element["target"], "#{url} should not have target attribute"
      assert_nil a_element["rel"], "#{url} should not have rel attribute"
    end
  end

  # Performance and structure tests
  test "link has clean HTML structure" do
    link = Components::Link.new(href: "/test", text: "Test Link", variant: :primary)
    html = render_component(link)
    doc = parse_html(html)

    # Should have exactly one anchor element
    anchors = doc.css("a")
    assert_equal 1, anchors.length, "Should render exactly one anchor element"

    # Anchor should be the root element
    link_root = Components::Link.new(href: "/test", text: "Test Link", variant: :primary)
    root = get_root_element(link_root)
    assert_equal "a", root.name, "Anchor element should be the root element"
  end

  test "link CSS classes are properly structured" do
    link = Components::Link.new(href: "/test", text: "Test Link", variant: :primary)
    all_classes = extract_css_classes(link)

    # Should have essential classes
    assert_includes all_classes, "link"
    assert_includes all_classes, "link-primary"

    # Should not have conflicting variant classes
    conflicting_classes = [ "btn-link", "link-secondary", "link-error", "link-hover" ] # Removed "link-hover"
    conflicting_classes.each do |conflicting_class|
      assert_not_includes all_classes, conflicting_class,
        "Primary link should not have conflicting class: #{conflicting_class}"
    end
  end

  # Accessibility tests
  test "link maintains accessibility standards" do
    link = Components::Link.new(href: "/test", text: "Test Link", variant: :primary)
    html = render_component(link)
    doc = parse_html(html)
    a_element = doc.css("a").first

    # Link should have href attribute
    assert a_element.has_attribute?("href"), "Link should have href attribute"

    # Link should be focusable (no negative tabindex unless explicitly set)
    refute_equal "-1", a_element["tabindex"], "Link should be focusable by default"
  end

  test "link with aria attributes" do
    link = Components::Link.new(href: "/test", text: "Test Link",
      variant: :primary,
      aria: { label: "Navigate to test page", describedby: "help-text" }
    )

    assert_accessibility_attributes(link, "a", {
      "aria-label" => "Navigate to test page",
      "aria-describedby" => "help-text"
    })
  end

  # Integration tests with existing patterns
  test "works with AuthLinks-style link data structure" do
    # Simulate the pattern used in AuthLinks component
    link_data = { text: "Sign Up", path: "/sign_up" }

    link = Components::Link.new(href: link_data[:path], text: link_data[:text])
    assert_has_text(link, "Sign Up")

    link_attrs = Components::Link.new(href: link_data[:path], text: link_data[:text])
    assert_has_attributes(link_attrs, "a", { href: "/sign_up" })
  end

  test "can replace AuthLinks usage pattern" do
    # Test that Link component can be used in place of AuthLinks pattern
    links = [
      { text: "Sign In", path: "/sign_in" },
      { text: "Forgot Password", path: "/password/new" }
    ]

    links.each do |link_data|
      link = Components::Link.new(href: link_data[:path], text: link_data[:text], variant: :default)
      assert_renders_successfully(link)

      link_text = Components::Link.new(href: link_data[:path], text: link_data[:text], variant: :default)
      assert_has_text(link_text, link_data[:text])

      link_attrs = Components::Link.new(href: link_data[:path], text: link_data[:text], variant: :default)
      assert_has_attributes(link_attrs, "a", { href: link_data[:path] })

      assert_has_css_class(link, [ "link" ]) # Removed "link-hover"
    end
  end

  test "supports navigation link patterns from Navigation component" do
    # Test pattern similar to Navigation component nav_link_class method
    link = Components::Link.new(href: "/dashboard", text: "Dashboard",
                               variant: :default,
                               class: "text-sm")

    doc = render_and_parse(link)
    a_element = doc.css("a").first
    classes = a_element["class"].split(" ")

    assert_includes classes, "link"
    assert_includes classes, "text-sm" # Removed "link-hover"
  end
end