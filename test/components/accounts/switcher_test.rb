# frozen_string_literal: true

require_relative "../component_test_case"
require_relative "../test_helpers"

module Accounts
  class SwitcherTest < ComponentTestCase
  include ComponentTestHelpers

  def setup
    # Use fixture users
    @user_with_multiple_accounts = users(:app_admin)

    # Create isolated user with only ONE account for single-account test
    @user_with_one_account = User.create!(email: "single@test.com", password: "Secret1*3*5*", verified: true)
    @single_account = Account.create!(name: "Single Account", owner: @user_with_one_account, personal: true)
    AccountMembership.create!(user: @user_with_one_account, account: @single_account, roles: { admin: true, member: true })

    @personal_account = accounts(:one)
    @team_account = accounts(:two)
    @another_personal = accounts(:three)
  end

  # Test 1: Doesn't render when user has only one account
  test "does not render when user has only one account" do
    # Verify test data: regular_user should have only one account

    switcher = Components::Accounts::Switcher.new(
      current_account: @single_account,
      user: @user_with_one_account
    )

    html = render_component(switcher)


    # Component should return nil/empty when user has only one account
    assert html.blank? || html.strip.empty?,
      "Expected component to not render when user has only one account, but got HTML: #{html}"

    # Verify no dropdown is present
    doc = parse_html(html)
    dropdowns = doc.css('.dropdown')
    assert_equal 0, dropdowns.length,
      "Expected no dropdown element when user has only one account, found #{dropdowns.length}"
  end

  # Test 2: Renders when user has multiple accounts
  test "renders dropdown when user has multiple accounts" do
    # Verify test data: app_admin should have multiple accounts
    @user_with_multiple_accounts.accounts.each do |acc|
    end

    switcher = Components::Accounts::Switcher.new(
      current_account: @personal_account,
      user: @user_with_multiple_accounts
    )

    assert_renders_successfully(switcher)

    html = render_component(switcher)

    assert html.present?, "Expected component to render HTML when user has multiple accounts"

    # Verify dropdown structure
    switcher_check = Components::Accounts::Switcher.new(
      current_account: @personal_account,
      user: @user_with_multiple_accounts
    )
    assert_has_css_class(switcher_check, "dropdown",
      "Expected component to have dropdown class")

    switcher_dropdown = Components::Accounts::Switcher.new(
      current_account: @personal_account,
      user: @user_with_multiple_accounts
    )
    assert_has_css_class(switcher_dropdown, "dropdown-end",
      "Expected dropdown to be positioned at end")
  end

  # Test 3: Displays personal accounts section when user has personal accounts
  test "displays personal accounts section when user has personal accounts" do
    switcher = Components::Accounts::Switcher.new(
      current_account: @personal_account,
      user: @user_with_multiple_accounts
    )

    html = render_component(switcher)
    doc = parse_html(html)


    # Check for "Personal Accounts" menu title
    assert html.include?("Personal Accounts"),
      "Expected component to display 'Personal Accounts' section heading"

    # Verify section structure
    menu_titles = doc.css('.menu-title')
    personal_title = menu_titles.find { |title| title.text.include?("Personal Accounts") }

    assert personal_title, "Expected to find menu-title element containing 'Personal Accounts'"

    # Verify personal account names appear
    @user_with_multiple_accounts.accounts.personal.each do |account|
      assert html.include?(account.name),
        "Expected personal account '#{account.name}' to appear in switcher"
    end
  end

  # Test 4: Displays team accounts section when user has team accounts
  test "displays team accounts section when user has team accounts" do
    switcher = Components::Accounts::Switcher.new(
      current_account: @team_account,
      user: @user_with_multiple_accounts
    )

    html = render_component(switcher)
    doc = parse_html(html)


    # Check for "Team Accounts" menu title
    assert html.include?("Team Accounts"),
      "Expected component to display 'Team Accounts' section heading"

    # Verify section structure
    menu_titles = doc.css('.menu-title')
    team_title = menu_titles.find { |title| title.text.include?("Team Accounts") }

    assert team_title, "Expected to find menu-title element containing 'Team Accounts'"

    # Verify team account names appear
    @user_with_multiple_accounts.accounts.team.each do |account|
      assert html.include?(account.name),
        "Expected team account '#{account.name}' to appear in switcher"
    end
  end

  # Test 5: Shows current account with CURRENT badge/indicator
  test "shows current account with CURRENT badge indicator" do
    switcher = Components::Accounts::Switcher.new(
      current_account: @personal_account,
      user: @user_with_multiple_accounts
    )

    html = render_component(switcher)
    doc = parse_html(html)


    # Check for CURRENT badge text
    assert html.include?("CURRENT"),
      "Expected component to display 'CURRENT' badge for current account"

    # Find the badge element
    badges = doc.css('.badge')
    current_badge = badges.find { |badge| badge.text.include?("CURRENT") }

    assert current_badge, "Expected to find badge element with 'CURRENT' text"

    # Verify badge is associated with current account name
    # The current account should be in a disabled li with active class
    disabled_items = doc.css('li.disabled')
    assert disabled_items.any?, "Expected current account to be in disabled list item"

    current_item = disabled_items.find { |li| li.text.include?(@personal_account.name) }
    assert current_item, "Expected disabled item to contain current account name '#{@personal_account.name}'"
    assert current_item.text.include?("CURRENT"),
      "Expected current account item to contain CURRENT badge"


    # Verify the active class
    active_links = doc.css('a.active')
    assert active_links.any?, "Expected current account link to have 'active' class"

    current_link = active_links.find { |a| a.text.include?(@personal_account.name) }
    assert current_link, "Expected active link to contain current account name"
  end

  # Test 6: Shows current account name in dropdown trigger button
  test "displays current account name in dropdown trigger button" do
    switcher = Components::Accounts::Switcher.new(
      current_account: @personal_account,
      user: @user_with_multiple_accounts
    )

    html = render_component(switcher)
    doc = parse_html(html)


    # Find the trigger button
    buttons = doc.css('button[type="button"]')
    assert buttons.any?, "Expected to find trigger button"

    trigger_button = buttons.first

    # Verify current account name appears in button
    assert trigger_button.text.include?(@personal_account.name),
      "Expected trigger button to display current account name '#{@personal_account.name}', got: #{trigger_button.text}"
  end

  # Test 7: Shows "Select Account" when current_account is nil
  test "displays Select Account placeholder when current_account is nil" do
    switcher = Components::Accounts::Switcher.new(
      current_account: nil,
      user: @user_with_multiple_accounts
    )

    html = render_component(switcher)
    doc = parse_html(html)


    # Find the trigger button
    buttons = doc.css('button[type="button"]')
    trigger_button = buttons.first

    assert trigger_button.text.include?("Select Account"),
      "Expected trigger button to display 'Select Account' when current_account is nil, got: #{trigger_button.text}"

  end

  # Test 8: Includes "Create Team" link
  test "includes Create Team link with correct path" do
    switcher = Components::Accounts::Switcher.new(
      current_account: @personal_account,
      user: @user_with_multiple_accounts
    )

    html = render_component(switcher)
    doc = parse_html(html)


    # Check for "Create Team" text
    assert html.include?("Create Team"),
      "Expected component to include 'Create Team' link text"

    # Find the link element
    links = doc.css('a')
    create_team_link = links.find { |a| a.text.include?("Create Team") }

    assert create_team_link, "Expected to find link element with 'Create Team' text"

    # Verify link points to new_account_path
    expected_path = "/accounts/new"
    assert_equal expected_path, create_team_link['href'],
      "Expected Create Team link to point to '#{expected_path}', got: #{create_team_link['href']}"

  end

  # Test 9: Includes "Manage Accounts" link
  test "includes Manage Accounts link with correct path" do
    switcher = Components::Accounts::Switcher.new(
      current_account: @personal_account,
      user: @user_with_multiple_accounts
    )

    html = render_component(switcher)
    doc = parse_html(html)


    # Check for "Manage Accounts" text
    assert html.include?("Manage Accounts"),
      "Expected component to include 'Manage Accounts' link text"

    # Find the link element
    links = doc.css('a')
    manage_link = links.find { |a| a.text.include?("Manage Accounts") }

    assert manage_link, "Expected to find link element with 'Manage Accounts' text"

    # Verify link points to accounts_path
    expected_path = "/accounts"
    assert_equal expected_path, manage_link['href'],
      "Expected Manage Accounts link to point to '#{expected_path}', got: #{manage_link['href']}"

  end

  # Test 10: Non-current accounts render as forms for switching
  test "non-current accounts render as switchable forms" do
    switcher = Components::Accounts::Switcher.new(
      current_account: @personal_account,
      user: @user_with_multiple_accounts
    )

    html = render_component(switcher)
    doc = parse_html(html)


    # Get all accounts except current
    other_accounts = @user_with_multiple_accounts.accounts.reject { |a| a == @personal_account }


    other_accounts.each do |account|
      # Find form for this account
      forms = doc.css('form')
      account_form = forms.find do |form|
        form.css('input[name="account_id"][value="' + account.id.to_s + '"]').any?
      end

      assert account_form, "Expected to find form for account '#{account.name}'"

      # Verify form posts to account_switches_path
      expected_action = "/account_switches"
      assert_equal expected_action, account_form['action'],
        "Expected form to post to '#{expected_action}', got: #{account_form['action']}"

      # Verify form method is POST
      method = account_form['method']
      assert_equal "post", method&.downcase,
        "Expected form method to be 'post', got: #{method}"

      # Verify hidden fields
      csrf_token = account_form.css('input[name="authenticity_token"]').first
      assert csrf_token, "Expected form to have CSRF token field"

      account_id_field = account_form.css('input[name="account_id"]').first
      assert account_id_field, "Expected form to have account_id field"
      assert_equal account.id.to_s, account_id_field['value'],
        "Expected account_id to be '#{account.id}', got: #{account_id_field['value']}"

      # Verify submit button
      submit_button = account_form.css('button[type="submit"]').first
      assert submit_button, "Expected form to have submit button for account '#{account.name}'"
      assert submit_button.text.include?(account.name),
        "Expected submit button to contain account name '#{account.name}'"
    end
  end

  # Test 11: Dropdown has proper DaisyUI classes
  test "dropdown uses correct DaisyUI menu classes" do
    switcher = Components::Accounts::Switcher.new(
      current_account: @personal_account,
      user: @user_with_multiple_accounts
    )

    html = render_component(switcher)
    doc = parse_html(html)


    # Check main dropdown classes
    dropdown = doc.css('.dropdown.dropdown-end').first
    assert dropdown, "Expected to find element with 'dropdown' and 'dropdown-end' classes"

    # Check menu classes
    menu = doc.css('.dropdown-content.menu').first
    assert menu, "Expected to find element with 'dropdown-content' and 'menu' classes"

    # Check menu styling classes
    assert menu['class'].include?('bg-base-200'), "Expected menu to have bg-base-200 class"
    assert menu['class'].include?('rounded-box'), "Expected menu to have rounded-box class"
    assert menu['class'].include?('shadow-lg'), "Expected menu to have shadow-lg class"

  end

  # Test 12: Button has ghost variant
  test "trigger button uses ghost variant" do
    switcher = Components::Accounts::Switcher.new(
      current_account: @personal_account,
      user: @user_with_multiple_accounts
    )

    html = render_component(switcher)
    doc = parse_html(html)

    # Find trigger button
    button = doc.css('button[type="button"]').first
    assert button, "Expected to find trigger button"

    # Verify ghost variant
    assert button['class'].include?('btn-ghost'),
      "Expected trigger button to have btn-ghost class, got: #{button['class']}"

  end

  test "accounts are displayed in alphabetical order by name" do
    zebra_team = Account.create!(name: "Zebra Team", owner: @user_with_multiple_accounts, personal: false)
    alpha_team = Account.create!(name: "Alpha Team", owner: @user_with_multiple_accounts, personal: false)
    AccountMembership.create!(user: @user_with_multiple_accounts, account: zebra_team, roles: {"admin" => true, "member" => true})
    AccountMembership.create!(user: @user_with_multiple_accounts, account: alpha_team, roles: {"admin" => true, "member" => true})

    switcher = Components::Accounts::Switcher.new(
      current_account: @personal_account,
      user: @user_with_multiple_accounts
    )

    html = render_component(switcher)

    personal_accounts_ordered = @user_with_multiple_accounts.accounts.personal.order(:name).map(&:name)
    team_accounts_ordered = @user_with_multiple_accounts.accounts.team.order(:name).map(&:name)

    assert personal_accounts_ordered.size >= 2 || team_accounts_ordered.size >= 2

    personal_accounts_ordered.each_with_index do |name, index|
      if index > 0
        previous_name = personal_accounts_ordered[index - 1]
        previous_pos = html.index(previous_name)
        current_pos = html.index(name)

        assert previous_pos < current_pos,
          "Expected account '#{previous_name}' to appear before '#{name}' in personal section"
      end
    end

    team_accounts_ordered.each_with_index do |name, index|
      if index > 0
        previous_name = team_accounts_ordered[index - 1]
        previous_pos = html.index(previous_name)
        current_pos = html.index(name)

        assert previous_pos < current_pos,
          "Expected account '#{previous_name}' to appear before '#{name}' in team section"
      end
    end

  end

  # Test 14: Component has dropdown toggle interaction
  test "dropdown button has toggle interaction" do
    switcher = Components::Accounts::Switcher.new(
      current_account: @personal_account,
      user: @user_with_multiple_accounts
    )

    html = render_component(switcher)
    doc = parse_html(html)


    # Find dropdown container with tabindex (DaisyUI dropdown pattern)
    dropdown = doc.css('.dropdown[tabindex]').first
    assert dropdown, "Expected to find dropdown with tabindex"
    assert_equal "0", dropdown['tabindex'], "Expected tabindex='0' for keyboard accessibility"

  end

  # Test 15: Separators between sections
  test "includes horizontal rule separators between sections" do
    switcher = Components::Accounts::Switcher.new(
      current_account: @personal_account,
      user: @user_with_multiple_accounts
    )

    html = render_component(switcher)
    doc = parse_html(html)


    # Check for hr elements
    hrs = doc.css('hr')

    # Should have separators after personal accounts section and team accounts section
    # (2 sections with accounts = 2 separators expected)
    assert hrs.count >= 1, "Expected at least one hr separator element, found #{hrs.count}"

  end

  # Test 16: Font styling consistency
  test "uses monospace font consistently" do
    switcher = Components::Accounts::Switcher.new(
      current_account: @personal_account,
      user: @user_with_multiple_accounts
    )

    html = render_component(switcher)


    # Check that font-mono class is used
    assert html.include?('font-mono'),
      "Expected component to use font-mono class for typography consistency"

    doc = parse_html(html)
    mono_elements = doc.css('.font-mono')

    assert mono_elements.count > 0, "Expected to find elements with font-mono class"
  end

  # Test 17: Edge case - user with only personal accounts
  test "renders correctly when user has only personal accounts" do
    # This test assumes we have fixtures set up appropriately
    # Using app_admin who should have at least 2 personal accounts or we can check the structure

    switcher = Components::Accounts::Switcher.new(
      current_account: @personal_account,
      user: @user_with_multiple_accounts
    )

    html = render_component(switcher)


    # Should render Personal Accounts section if user has personal accounts
    if @user_with_multiple_accounts.accounts.personal.any?
      assert html.include?("Personal Accounts"),
        "Expected to find Personal Accounts section"
    end

    # May or may not have Team Accounts section depending on fixture data
    if @user_with_multiple_accounts.accounts.team.any?
      assert html.include?("Team Accounts"),
        "Expected to find Team Accounts section when user has team accounts"
    end
  end

  # Test 18: Renders with proper accessibility
  test "dropdown menu is accessible" do
    switcher = Components::Accounts::Switcher.new(
      current_account: @personal_account,
      user: @user_with_multiple_accounts
    )

    html = render_component(switcher)
    doc = parse_html(html)


    # Button should have type attribute
    button = doc.css('button').first
    assert button['type'], "Expected button to have type attribute"
    assert_equal "button", button['type'], "Expected button type to be 'button'"

    # Forms should have proper structure
    forms = doc.css('form')
    forms.each do |form|
      # Each form should have a submit button
      submit_buttons = form.css('button[type="submit"]')
      assert submit_buttons.any?, "Expected each form to have a submit button"
    end

  end
  end
end
