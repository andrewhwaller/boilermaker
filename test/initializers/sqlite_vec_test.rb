# frozen_string_literal: true

require "test_helper"

class SqliteVecTest < ActiveSupport::TestCase
  test "sqlite-vec extension is loaded" do
    result = ActiveRecord::Base.connection.execute("SELECT vec_version()").first
    assert result, "vec_version() should return a value"
    version = result.values.first
    assert version.present?, "sqlite-vec version should not be blank"
    puts "sqlite-vec version: #{version}"
  end
end
