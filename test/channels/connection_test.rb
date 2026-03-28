# frozen_string_literal: true

require "test_helper"

class ApplicationCable::ConnectionTest < ActionCable::Connection::TestCase
  test "connects with authenticated session" do
    user = users(:regular_user)
    session = user.sessions.create!

    cookies.signed[:session_token] = session.id

    connect

    assert_equal user, connection.current_user
  end

  test "rejects connection without session" do
    assert_reject_connection { connect }
  end

  test "rejects connection with invalid session token" do
    cookies.signed[:session_token] = "invalid-token"

    assert_reject_connection { connect }
  end
end
