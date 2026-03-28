# frozen_string_literal: true

require "test_helper"

class SearchesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:app_admin)
    @account = accounts(:one)
    sign_in_as(@user, @account)
  end

  test "index renders search page without query" do
    get searches_path
    assert_response :success, "GET /searches should return 200"
    assert_match(/Search/, response.body, "Page should include 'Search' heading")
  end

  test "index shows empty state prompting a query when no query is given" do
    get searches_path
    assert_response :success
    assert_match(/Enter a query|hasn't been processed/i, response.body,
      "Empty state should prompt user to enter a query or process library")
  end

  test "index with blank query does not show results count" do
    get searches_path, params: { q: "" }
    assert_response :success
    assert_no_match(/results for/i, response.body,
      "Blank query should not display a results count")
  end

  test "index shows no results message when query returns nothing" do
    skip "OpenAI API key not configured" unless Rails.application.credentials.dig(:openai, :api_key).present?

    VCR.use_cassette("searches/no_results_query", record: :new_episodes) do
      get searches_path, params: { q: "xyzzy frob quux nonce" }
      assert_response :success
      assert_match(/No relevant items found|0 results/i, response.body,
        "Query with no matches should show a no-results message")
    end
  end

  test "index renders successfully when query matches library items" do
    skip "OpenAI API key not configured" unless Rails.application.credentials.dig(:openai, :api_key).present?

    VCR.use_cassette("searches/matching_query", record: :new_episodes) do
      get searches_path, params: { q: "research methodology" }
      assert_response :success
    end
  end

  test "index requires authentication" do
    delete session_path("current")
    get searches_path
    assert_redirected_to sign_in_path,
      "Unauthenticated request should redirect to sign in"
  end

  test "index search form is present on the page" do
    get searches_path
    assert_response :success
    assert_match(/name="q"/, response.body,
      "Search form input with name='q' should be present")
    assert_match(/action="\/searches"/, response.body,
      "Search form should action to /searches")
  end

  test "index preserves query value in search form after submission" do
    skip "OpenAI API key not configured" unless Rails.application.credentials.dig(:openai, :api_key).present?

    VCR.use_cassette("searches/preserve_query", record: :new_episodes) do
      get searches_path, params: { q: "test query" }
      assert_response :success
      assert_match(/value="test query"/, response.body,
        "Search input should retain submitted query value")
    end
  end
end
