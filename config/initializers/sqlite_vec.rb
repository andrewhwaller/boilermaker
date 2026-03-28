# frozen_string_literal: true

require "sqlite_vec"

# Load the sqlite-vec extension into every new SQLite database connection.
# This enables vector search via virtual tables (vec0).
# NOTE: Do NOT use the `extensions:` key in database.yml — the Rails 8
# SQLite adapter does not support it.
#
# We hook into configure_connection so the extension is available on every
# connection in the pool, including test worker connections.
ActiveSupport.on_load(:active_record) do
  ActiveRecord::ConnectionAdapters::SQLite3Adapter.prepend(
    Module.new do
      def configure_connection
        super
        raw_connection.enable_load_extension(true)
        SqliteVec.load(raw_connection)
        raw_connection.enable_load_extension(false)
      end
    end
  )
end
